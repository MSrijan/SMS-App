import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class MessagesListView extends StatelessWidget {
  const MessagesListView({
    Key? key,
    required this.messages,
    required this.contactNames,
  }) : super(key: key);

  final List<SmsMessage> messages;
  final Map<String, String> contactNames;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int i) {
        var message = messages[i];
        final sender = message.sender ?? '';
        final senderName = contactNames[sender] ?? sender;

        return ListTile(
          leading: Icon(
            message.kind == SmsMessageKind.sent
                ? Icons.arrow_upward
                : Icons.arrow_downward,
            color:
                message.kind == SmsMessageKind.sent ? Colors.green : Colors.red,
          ),
          title: Text('$senderName [${message.date}]'),
          subtitle: Text('${message.body}'),
        );
      },
    );
  }
}
