import 'package:flutter/material.dart';
import 'messages_list_view.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'main.dart'; // Make sure to import main.dart to access the GlobalKey

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SmsQuery _query = SmsQuery();
  List<SmsMessage> _messages = [];
  final Map<String, String> _contactNames = {};

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      final inboxMessages = await _query.querySms(kinds: [SmsQueryKind.inbox]);

      // Filter messages based on keywords
      final filteredMessages = inboxMessages.where((message) {
        final body = message.body?.toLowerCase() ?? '';
        return body.contains('withdrawn') ||
            body.contains('deposited') ||
            body.contains('credited') ||
            body.contains('debited');
      }).toList();

      // Sort messages by date (newest to oldest)
      filteredMessages.sort((a, b) {
        if (a.date != null && b.date != null) {
          return b.date!.compareTo(a.date!);
        }
        return 0;
      });

      setState(() {
        _messages = filteredMessages.take(5).toList(); // Get top 5 messages
      });
    } else {
      await Permission.sms.request();
    }
  }

  void _onNotificationPressed(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification icon pressed'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // the top part, welcome and notification
          Top(context),
          // balance part
          Balance(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Transactions ",
                  style: TextStyle(fontSize: 18),
                ),
                TextButton(
                  onPressed: () {
                    mainNavKey.currentState?.onDestinationSelected(1);
                  },
                  child: const Text("View All"),
                ),
              ],
            ),
          ),
          Expanded(
            child: _messages.isNotEmpty
                ? MessagesListView(
                    messages: _messages, contactNames: _contactNames)
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
        onPressed: _fetchMessages,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Container Balance() {
    return Container(
      width: 411,
      height: 144,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Balance',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            "Rs 100000000",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            "Credit this month",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Container Top(BuildContext context) {
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
                  mainNavKey.currentState?.onDestinationSelected(2);
                },
                iconSize: 50,
                icon: const Icon(Icons.account_circle_rounded,
                    color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment
                    .center, // Center align the text vertically
                children: [
                  Text(
                    'Welcome Back,',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  Text(
                    'User',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            iconSize: 32,
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => _onNotificationPressed(context),
          ),
        ],
      ),
    );
  }
}
