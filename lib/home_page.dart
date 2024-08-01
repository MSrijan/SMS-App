import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
          //the top part, welcome ra notification
          Container(
            height: 111.0,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: const BoxDecoration(
                color: Color.fromARGB(255, 94, 169, 179),
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
                      onPressed: () {},
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
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white),
                  onPressed: () => _onNotificationPressed(context),
                ),
              ],
            ),
          ),
          //balance part
          Container(
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
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Transaction",
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  "View All >",
                  style: TextStyle(fontSize: 14),
                )
              ],
            ),
          ),
          Column(children: [
            Transaction(),
            Transaction(),
            Transaction(),
            Transaction()
          ])
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  //transaction cards
  Container Transaction() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "MPAY- TEST TESTTEST",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "NPR 10000",
                style: TextStyle(fontSize: 14, color: Colors.green),
              )
            ],
          ),
          Text(
            '24th April 2024',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
