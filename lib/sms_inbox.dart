import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'messages_list_view.dart';

class SmsInbox extends StatefulWidget {
  const SmsInbox({Key? key}) : super(key: key);

  @override
  State<SmsInbox> createState() => _SmsInboxState();
}

class _SmsInboxState extends State<SmsInbox> {
  final SmsQuery _query = SmsQuery();
  List<SmsMessage> _messages = [];
  List<SmsMessage> _filteredMessages = [];
  final TextEditingController _filterController = TextEditingController();
  Set<String> _savedFilters = {};
  Map<String, String> _contactNames = {};

  @override
  void initState() {
    super.initState();
    _filterController.addListener(_filterMessages);
    _loadSavedFilters();
    _fetchMessages(); // Automatically fetch messages when the app starts
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedFilters = prefs.getStringList('savedFilters')?.toSet() ?? {};
    });
    _filterMessages();
  }

  Future<void> _saveFilter(String filter) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedFilters.add(filter);
      prefs.setStringList('savedFilters', _savedFilters.toList());
    });
    _filterMessages(); // Apply filters after saving
  }

  Future<void> _removeFilter(String filter) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedFilters.remove(filter);
      prefs.setStringList('savedFilters', _savedFilters.toList());
    });
    _filterMessages();
  }

  Future<void> _fetchMessages() async {
    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      final inboxMessages = await _query.querySms(kinds: [SmsQueryKind.inbox]);

      // Sort messages by date (newest to oldest)
      inboxMessages.sort((a, b) {
        if (a.date != null && b.date != null) {
          return b.date!
              .compareTo(a.date!); // Reverse order for newest to oldest
        }
        return 0; // Handle cases where date might be null (if applicable)
      });

      setState(() {
        _messages = inboxMessages;
        _filterMessages(); // Apply filter after fetching and sorting messages
      });
    } else {
      await Permission.sms.request();
    }
  }

  void _filterMessages() {
    final filterText = _filterController.text.toLowerCase();
    setState(() {
      _filteredMessages = _messages.where((message) {
        final senderNumber = message.sender?.toLowerCase() ?? '';
        final senderName = _contactNames[senderNumber]?.toLowerCase() ?? '';
        final messageContent = message.body?.toLowerCase() ?? '';

        final matchesFilterText = senderNumber.contains(filterText) ||
            senderName.contains(filterText) ||
            messageContent.contains(filterText);
        final matchesSavedFilters = _savedFilters.isEmpty ||
            _savedFilters.any((filter) =>
                senderNumber.contains(filter.toLowerCase()) ||
                senderName.contains(filter.toLowerCase())) ||
            messageContent.contains(filterText);

        return matchesFilterText && matchesSavedFilters;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _filterController,
                    decoration: InputDecoration(
                      labelText: 'Filter by sender',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final filterText = _filterController.text;
                    if (filterText.isNotEmpty) {
                      _saveFilter(filterText);
                      _filterController.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: _savedFilters.map((filter) {
                return Chip(
                  label: Text(filter),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    _removeFilter(filter);
                  },
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _filteredMessages.isNotEmpty
                ? MessagesListView(
                    messages: _filteredMessages, contactNames: _contactNames)
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
        onPressed: _fetchMessages, // Refresh messages on button press
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
