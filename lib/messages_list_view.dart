import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:intl/intl.dart';

class MessagesListView extends StatelessWidget {
  const MessagesListView({
    Key? key,
    required this.messagesGroupedByDate,
    required this.contactNames,
  }) : super(key: key);

  final Map<DateTime, List<SmsMessage>> messagesGroupedByDate;
  final Map<String, String> contactNames;

  // Format a single date to '1 January 2024'
  String formatGroupedDate(DateTime date) {
    try {
      final DateFormat dateFormat = DateFormat('d MMMM yyyy');
      return dateFormat.format(date);
    } catch (e) {
      print('Error formatting grouped date: $e');
      return 'Invalid Date';
    }
  }

  // Format a date from the message body to '1 Jan 2024 1:20 PM'
  String formatMessageDate(String dateStr) {
    try {
      final List<DateFormat> formats = [
        DateFormat('dd/MM/yyyy HH:mm'),
        DateFormat('dd/MM/yyyy HH:mm:ss'),
        DateFormat('dd-MM-yyyy HH:mm'),
        DateFormat('dd-MM-yyyy HH:mm:ss'),
        DateFormat('yyyy/MM/dd HH:mm'),
        DateFormat('yyyy/MM/dd HH:mm:ss'),
        DateFormat('dd/MM/yyyy'),
        DateFormat('dd-MM-yyyy'),
        DateFormat('yyyy/MM/dd'),
      ];

      for (var format in formats) {
        try {
          final dateTime = format.parse(dateStr, true);
          return DateFormat('d MMM yyyy h:mm a').format(dateTime);
        } catch (_) {
          // Ignore parsing errors
        }
      }
    } catch (e) {
      print('Error formatting date: $e');
    }
    return 'Invalid Date';
  }

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
        final dateStr = match.group(0) ?? '';
        return formatMessageDate(dateStr);
      }
    }
    return 'No Date';
  }

  String extractRemarksFromMessage(String messageBody) {
    final lowerCaseMessageBody = messageBody.toLowerCase();
    if (lowerCaseMessageBody.contains('deposited') ||
        lowerCaseMessageBody.contains('withdrawn') ||
        lowerCaseMessageBody.contains('debited') ||
        lowerCaseMessageBody.contains('credited')) {
      if (lowerCaseMessageBody.contains('remarks:')) {
        final startIndex = messageBody.indexOf('Remarks:') + 'Remarks:'.length;
        final endIndex = messageBody.indexOf('Activate', startIndex);
        return endIndex != -1
            ? messageBody.substring(startIndex, endIndex).trim()
            : messageBody.substring(startIndex).trim();
      }
      if (lowerCaseMessageBody.contains('re:')) {
        final startIndex = messageBody.indexOf('Re:') + 'Re:'.length;
        final endIndex = messageBody.indexOf('Activate', startIndex);
        return endIndex != -1
            ? messageBody.substring(startIndex, endIndex).trim()
            : messageBody.substring(startIndex).trim();
      }
    }
    return '';
  }

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
    return ListView(
      children: messagesGroupedByDate.entries.map((entry) {
        final date = entry.key;
        final messages = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                formatGroupedDate(date),
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            ...messages.map((message) {
              final sender = message.sender ?? '';
              final senderName = contactNames[sender] ?? sender;

              final messageContent = message.body?.toLowerCase() ?? '';
              final dateFromBody = extractDateFromMessage(message.body ?? '');

              final remarksFromBody =
                  extractRemarksFromMessage(message.body ?? '');
              final amountFromBody =
                  extractAmountFromMessage(message.body ?? '');

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
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            remarksFromBody.isNotEmpty
                                ? remarksFromBody
                                : 'No Remarks',
                            style: const TextStyle(fontSize: 16),
                          ),
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
            }).toList(),
          ],
        );
      }).toList(),
    );
  }
}
