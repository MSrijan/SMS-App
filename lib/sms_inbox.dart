import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'messages_list_view.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsInbox extends StatefulWidget {
  final String? selectedBank;

  SmsInbox({Key? key, this.selectedBank}) : super(key: key);

  @override
  _SmsInboxState createState() => _SmsInboxState();
}

class _SmsInboxState extends State<SmsInbox> {
  List<SmsMessage> _messages = [];
  final SmsQuery _query = SmsQuery();
  String _filter = 'all';
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    print('Selected Bank in SmsInbox: ${widget.selectedBank}');
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      final inboxMessages = await _query.querySms(kinds: [SmsQueryKind.inbox]);

      print('Selected Bank: ${widget.selectedBank}');
      print('Total Messages: ${inboxMessages.length}');

      final Map<String, String> bankSenders = {
        'Nabil Bank': 'Nabil_Alert',
        'Sanima Bank': 'SanimaBank',
      };

      final filteredMessages = inboxMessages.where((message) {
        final body = message.body?.toLowerCase() ?? '';
        final sender = message.sender?.toLowerCase() ?? '';
        final messageDate = message.date ?? DateTime.now();

        bool matchesBank = widget.selectedBank == null ||
            (sender.contains(
                bankSenders[widget.selectedBank]?.toLowerCase() ?? ''));

        bool matchesType = _filter == 'all' ||
            (_filter == 'withdrawn' && _matchesWithdrawn(body)) ||
            (_filter == 'deposited' && _matchesDeposited(body));

        bool matchesDateRange = _selectedDateRange == null ||
            (_selectedDateRange!.start.isBefore(messageDate) &&
                _selectedDateRange!.end.isAfter(messageDate));

        return (body.contains('withdrawn') ||
                body.contains('deposited') ||
                body.contains('credited') ||
                body.contains('debited')) &&
            matchesBank &&
            matchesType &&
            matchesDateRange;
      }).toList();

      print('Filtered Messages: ${filteredMessages.length}');

      setState(() {
        _messages = filteredMessages;
      });
    } else {
      await Permission.sms.request();
    }
  }

  void _setDateRange(DateTimeRange? dateRange) {
    setState(() {
      _selectedDateRange = dateRange;
      _fetchMessages();
    });
  }

  Future<void> _selectDateRange() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
      initialDateRange: _selectedDateRange,
    );

    if (picked != null && picked != _selectedDateRange) {
      _setDateRange(picked);
    }
  }

  bool _matchesWithdrawn(String body) {
    final RegExp withdrawnPattern =
        RegExp(r'\b(withdrawn|db|debit|debit\w*)\b', caseSensitive: false);
    return withdrawnPattern.hasMatch(body);
  }

  bool _matchesDeposited(String body) {
    final RegExp depositedPattern =
        RegExp(r'\b(deposited|credit|credit\w*)\b', caseSensitive: false);
    return depositedPattern.hasMatch(body);
  }

  void _setFilter(String filter) {
    print('Setting filter to: $filter');
    setState(() {
      _filter = filter;
      _fetchMessages();
    });
  }

  ElevatedButton _buildFilterButton(String filter, String label) {
    final bool isSelected = _filter == filter;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: isSelected
            ? Color.fromARGB(255, 238, 213, 241)
            : Color.fromARGB(255, 196, 196, 196),
        onPrimary: Colors.white,
        elevation: isSelected ? 8 : 2,
      ),
      onPressed: () {
        print('Button pressed: $label');
        _setFilter(filter);
      },
      child: Text(label),
    );
  }

  // Group messages by date
  Map<DateTime, List<SmsMessage>> _groupMessagesByDate(
      List<SmsMessage> messages) {
    final Map<DateTime, List<SmsMessage>> groupedMessages = {};

    for (var message in messages) {
      final messageDate = message.date ?? DateTime.now();
      final formattedDate =
          DateTime(messageDate.year, messageDate.month, messageDate.day);

      if (groupedMessages.containsKey(formattedDate)) {
        groupedMessages[formattedDate]!.add(message);
      } else {
        groupedMessages[formattedDate] = [message];
      }
    }

    return groupedMessages;
  }

  @override
  Widget build(BuildContext context) {
    final groupedMessages = _groupMessagesByDate(_messages);

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFilterButton('all', 'All'),
                  _buildFilterButton('withdrawn', 'Withdrawn'),
                  _buildFilterButton('deposited', 'Deposited'),
                ],
              ),
              ElevatedButton(
                onPressed: _selectDateRange,
                child: Text(_selectedDateRange == null
                    ? 'Select Date Range'
                    : 'Selected: ${_selectedDateRange!.start.toLocal().toShortDateString()} - ${_selectedDateRange!.end.toLocal().toShortDateString()}'),
              ),
            ],
          ),
          Expanded(
            child: groupedMessages.isNotEmpty
                ? MessagesListView(
                    messagesGroupedByDate: groupedMessages,
                    contactNames: {},
                  )
                : const Center(child: Text('No messages to show')),
          ),
        ],
      ),
    );
  }
}

// Extension should be placed outside the class definition
extension DateFormatting on DateTime {
  String toShortDateString() {
    return '${this.day} ${_monthName(this.month)} ${this.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
