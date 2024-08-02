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

  // Function to extract date from message body
  String extractDateFromMessage(String messageBody) {
    final List<RegExp> datePatterns = [
      RegExp(r'\b\d{2}/\d{2}/\d{4} \d{2}:\d{2}\b'), // dd/MM/yyyy HH:mm
      RegExp(r'\b\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2}\b'), // dd/MM/yyyy HH:mm:ss
      RegExp(r'\b\d{2}-\d{2}-\d{4} \d{2}:\d{2}\b'), // dd-MM-yyyy HH:mm
      RegExp(r'\b\d{2}-\d{2}-\d{4} \d{2}:\d{2}:\d{2}\b'), // dd-MM-yyyy HH:mm:ss
      RegExp(r'\b\d{4}/\d{2}/\d{2} \d{2}:\d{2}\b'), // yyyy/MM/dd HH:mm
      RegExp(r'\b\d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}\b'), // yyyy/MM/dd HH:mm:ss
      RegExp(r'\b\d{2}/\d{2}/\d{4}\b'), // dd/MM/yyyy
      RegExp(r'\b\d{2}-\d{2}-\d{4}\b'), // dd-MM-yyyy
      RegExp(r'\b\d{4}/\d{2}/\d{2}\b'), // yyyy/MM/dd
    ];

    for (var pattern in datePatterns) {
      final match = pattern.firstMatch(messageBody);
      if (match != null) {
        return match.group(0) ?? '';
      }
    }
    return '';
  }

  String extractRemarksFromMessage(String messageBody) {
    // Normalize the message body to lower case for easier comparison
    final lowerCaseMessageBody = messageBody.toLowerCase();

    // Check if the body contains "deposited" or "withdrawn"
    if (lowerCaseMessageBody.contains('deposited') ||
        lowerCaseMessageBody.contains('withdrawn')) {
      // Check for "Remarks:" keyword
      if (lowerCaseMessageBody.contains('remarks:')) {
        final startIndex = messageBody.indexOf('Remarks:') +
            'Remarks:'.length; // Start after "Remarks: "
        final endIndex = messageBody.indexOf(
            'Activate', startIndex); // Find "Activate" keyword

        // Extract text between startIndex and endIndex (if "Activate" is found), otherwise till the end
        if (endIndex != -1) {
          return messageBody.substring(startIndex, endIndex).trim();
        } else {
          return messageBody.substring(startIndex).trim();
        }
      }

      // Check for "Re:" keyword if "Remarks:" is not found
      if (lowerCaseMessageBody.contains('re:')) {
        final startIndex =
            messageBody.indexOf('Re:') + 'Re:'.length; // Start after "Re: "
        final endIndex = messageBody.indexOf(
            'Activate', startIndex); // Find "Activate" keyword

        // Extract text between startIndex and endIndex (if "Activate" is found), otherwise till the end
        if (endIndex != -1) {
          return messageBody.substring(startIndex, endIndex).trim();
        } else {
          return messageBody.substring(startIndex).trim();
        }
      }
    }
    return '';
  }

  // Function to extract amount from message body based on provided templates
  String extractAmountFromMessage(String messageBody) {
    final RegExp amountPattern = RegExp(r'\bNPR\s*[\d,]+(?:\.\d{1,2})?\b');
    final match = amountPattern.firstMatch(messageBody);
    if (match != null) {
      return match.group(0) ?? '';
    } else {
      final RegExp alternativeAmountPattern = RegExp(r'\b[\d,]+\.\d{1,2}\b');
      final alternativeMatch = alternativeAmountPattern.firstMatch(messageBody);
      if (alternativeMatch != null) {
        return 'NPR ' + (alternativeMatch.group(0) ?? '');
      }
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int i) {
        var message = messages[i];
        final sender = message.sender ?? '';
        final senderName = contactNames[sender] ?? sender;

        final messageContent = message.body?.toLowerCase() ?? '';
        final dateFromBody = extractDateFromMessage(message.body ?? '');
        final remarksFromBody = extractRemarksFromMessage(message.body ?? '');
        final amountFromBody = extractAmountFromMessage(message.body ?? '');
        IconData iconData;
        Color iconColor;

        if (messageContent.contains("deposited") ||
            messageContent.contains("debited")) {
          iconData = Icons.arrow_downward;
          iconColor = Colors.green;
        } else if (messageContent.contains("withdrawn") ||
            messageContent.contains("credited")) {
          iconData = Icons.arrow_upward;
          iconColor = Colors.red;
        } else {
          iconData = Icons.message;
          iconColor = Colors.grey;
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 5, 16, 5),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    remarksFromBody.isNotEmpty ? remarksFromBody : 'No Remarks',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    amountFromBody.isNotEmpty ? amountFromBody : 'N/A',
                    style: TextStyle(fontSize: 14, color: iconColor),
                  ),
                ],
              ),
              Text(
                dateFromBody.isNotEmpty ? dateFromBody : 'No Date',
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 12),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sender: $senderName',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Icon(
                    iconData,
                    color: iconColor,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
