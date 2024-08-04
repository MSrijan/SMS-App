import 'dart:convert'; // Import this for JSON encoding/decoding
import 'package:MyMessages/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'messages_list_view.dart';
import 'add_source.dart'; // Adjust the path as needed

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedBank;
  final SmsQuery _query = SmsQuery();
  List<SmsMessage> _messages = [];
  final Map<String, String> _contactNames = {};
  List<String> _availableBanks = ['Nabil Bank', 'Sanima Bank'];
  Map<String, List<String>> _sourceData = {};

  @override
  void initState() {
    super.initState();
    _loadSourceData();
    if (_selectedBank != null) {
      _fetchMessages(bankName: _selectedBank);
    }
  }

  Future<void> _fetchMessages({String? bankName}) async {
    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      final inboxMessages = await _query.querySms(kinds: [SmsQueryKind.inbox]);

      final Map<String, String> bankSenders = {
        'Nabil Bank': 'Nabil_Alert',
        'Sanima Bank': 'SanimaBank',
      };

      final filteredMessages = inboxMessages.where((message) {
        final body = message.body?.toLowerCase() ?? '';
        final sender = message.sender?.toLowerCase() ?? '';

        bool matchesBank = bankName == null ||
            (sender.contains(bankSenders[bankName]?.toLowerCase() ?? ''));

        return (body.contains('withdrawn') ||
                body.contains('deposited') ||
                body.contains('credited') ||
                body.contains('debited')) &&
            matchesBank;
      }).toList();

      filteredMessages.sort((a, b) {
        if (a.date != null && b.date != null) {
          return b.date!.compareTo(a.date!);
        }
        return 0;
      });

      setState(() {
        _messages = filteredMessages.take(10).toList();
      });
    } else {
      await Permission.sms.request();
    }
  }

  void _filterMessagesByBank(String? bankName) {
    setState(() {
      _selectedBank = bankName;
      _fetchMessages(bankName: bankName);
    });
  }

  Future<void> _loadSourceData() async {
    final prefs = await SharedPreferences.getInstance();
    final sourceDataString = prefs.getString('sourceData') ?? '{}';

    try {
      final Map<String, dynamic> sourceDataMap = jsonDecode(sourceDataString);
      final Map<String, List<String>> parsedSourceData =
          sourceDataMap.map((key, value) {
        if (value is List) {
          return MapEntry(key, List<String>.from(value));
        } else {
          return MapEntry(key, []);
        }
      });

      setState(() {
        _sourceData = parsedSourceData;
        _availableBanks = ['Nabil Bank', 'Sanima Bank']
          ..removeWhere((bank) => _sourceData['Bank']?.contains(bank) ?? false);
      });
    } catch (e) {
      print('Error loading source data: $e');
      setState(() {
        _sourceData = {};
        _availableBanks = ['Nabil Bank', 'Sanima Bank'];
      });
    }
  }

  void _onAddSource(String key, String value) {
    setState(() {
      if (key == 'Bank') {
        if (!_sourceData.containsKey('Bank')) {
          _sourceData['Bank'] = [];
        }
        _sourceData['Bank']?.add(value);
        _availableBanks.remove(value);
      } else if (key == 'Cash') {
        if (!_sourceData.containsKey('Cash')) {
          _sourceData['Cash'] = [];
        }
        _sourceData['Cash']?.add(value);
      } else {
        _sourceData[key] = [value];
      }
      _saveSourceData();
    });
  }

  Future<void> _saveSourceData() async {
    final prefs = await SharedPreferences.getInstance();
    final sourceDataString = jsonEncode(_sourceData);
    await prefs.setString('sourceData', sourceDataString);
  }

  String _getTotalBalance() {
    double totalBalance = 0.0;
    _sourceData.forEach((key, values) {
      if (key == 'Cash') {
        for (var value in values) {
          totalBalance += double.tryParse(value) ?? 0.0;
        }
      }
    });
    return totalBalance.toStringAsFixed(2);
  }

  String _getTotalCash() {
    double totalCash = 0.0;
    if (_sourceData.containsKey('Cash')) {
      for (var value in _sourceData['Cash']!) {
        totalCash += double.tryParse(value) ?? 0.0;
      }
    }
    return totalCash.toStringAsFixed(2);
  }

  Map<DateTime, List<SmsMessage>> _groupMessagesByDate(
      List<SmsMessage> messages) {
    final Map<DateTime, List<SmsMessage>> grouped = {};

    for (var message in messages) {
      final date = DateTime(
          message.date?.year ?? DateTime.now().year,
          message.date?.month ?? DateTime.now().month,
          message.date?.day ?? DateTime.now().day);

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(message);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topSection(context),
          _balanceSection(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Transactions",
                  style: TextStyle(fontSize: 18),
                ),
                TextButton(
                  onPressed: () {
                    final navigationState = mainNavKey.currentState;
                    if (navigationState != null) {
                      navigationState.navigateToPage(1);
                    }
                  },
                  child: const Text("View All"),
                ),
              ],
            ),
          ),
          Expanded(
            child: _messages.isNotEmpty
                ? MessagesListView(
                    messagesGroupedByDate: _groupMessagesByDate(_messages),
                    contactNames: _contactNames,
                  )
                : Center(
                    child: Text(
                      'No messages to show.\nTap refresh button...',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AddSourceDialog(
                  availableBanks: _availableBanks,
                  onAddSource: (key, value) {
                    _onAddSource(key, value);
                    if (key == 'Bank') {
                      setState(() {
                        _selectedBank = value;
                        _filterMessagesByBank(value);
                      });
                    }
                  },
                  selectedBanks: _sourceData['Bank'] ?? [],
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Container _balanceSection(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 144,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Balance',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            "Rs ${_getTotalBalance()}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          if (_sourceData.containsKey('Cash') &&
              _sourceData['Cash']!.isNotEmpty)
            Text(
              'Cash: Rs ${_getTotalCash()}',
              style: const TextStyle(fontSize: 14),
            ),
          if (_sourceData.containsKey('Bank') &&
              _sourceData['Bank']!.isNotEmpty)
            Text(
              'Bank: ${_sourceData['Bank']?.join(', ')}',
              style: const TextStyle(fontSize: 14),
            ),
        ],
      ),
    );
  }

  Container _topSection(BuildContext context) {
    return Container(
      height: 111.0,
      padding: const EdgeInsets.fromLTRB(10, 35, 10, 10),
      decoration: const BoxDecoration(
          color: Color.fromARGB(255, 217, 192, 233),
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(26),
              bottomLeft: Radius.circular(26))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  final navigationState = mainNavKey.currentState;
                  if (navigationState != null) {
                    navigationState.navigateToPage(2);
                  }
                },
                iconSize: 50,
                icon: const Icon(Icons.account_circle_rounded,
                    color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome back!',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    'Uesr',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _fetchMessages(bankName: _selectedBank);
            },
          ),
        ],
      ),
    );
  }
}
