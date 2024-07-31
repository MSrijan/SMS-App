import 'package:flutter/material.dart';
import 'sms_inbox.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MySMS',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const SmsInbox(),
    );
  }
}
