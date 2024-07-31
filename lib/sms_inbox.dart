import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'messages_list_view.dart';
import 'contacts_service.dart';

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
  Map<String, String> _contactNames =
      {}; // Map to store phone numbers and their names

  @override
  void initState() {
    super.initState();
    _filterController.addListener(_filterMessages);
    _loadSavedFilters();
    _loadContactNames();
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

  Future<void> _loadContactNames() async {
    await loadAllContactNames(_contactNames);
    setState(() {});
  }

  void _filterMessages() {
    final filterText = _filterController.text.toLowerCase();
    setState(() {
      _filteredMessages = _messages.where((message) {
        final sender = message.sender?.toLowerCase() ?? '';
        final matchesFilterText = sender.contains(filterText);
        final matchesSavedFilters = _savedFilters.isEmpty ||
            _savedFilters
                .any((filter) => sender.contains(filter.toLowerCase()));
        return matchesFilterText && matchesSavedFilters;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Inbox'),
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
        onPressed: () async {
          var permission = await Permission.sms.status;
          if (permission.isGranted) {
            final messages = await _query.querySms(
              kinds: [
                SmsQueryKind.inbox,
                SmsQueryKind.sent,
              ],
              count: 10,
            );
            debugPrint('sms inbox messages: ${messages.length}');
            setState(() {
              _messages = messages;
              _filterMessages(); // Apply filter after fetching messages
            });
          } else {
            await Permission.sms.request();
          }
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
