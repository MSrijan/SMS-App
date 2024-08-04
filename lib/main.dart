import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'sms_inbox.dart';

final GlobalKey<_MainNavigationState> mainNavKey =
    GlobalKey<_MainNavigationState>();

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
        primarySwatch: Colors.cyan,
        primaryColor: const Color.fromARGB(255, 197, 197, 197),
        scaffoldBackgroundColor: const Color.fromARGB(255, 236, 236, 236),
      ),
      home: MainNavigation(key: mainNavKey),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentPage = 0;

  final List<Widget> _pages = [
    HomePage(),
    SmsInbox(),
    const ProfilePage(),
  ];

  void onDestinationSelected(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void navigateToPage(int pageIndex) {
    setState(() {
      _currentPage = pageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentPage],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        onDestinationSelected: onDestinationSelected,
        selectedIndex: _currentPage,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(
              Icons.home,
              color: Color.fromARGB(255, 217, 192, 233),
            ),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.currency_exchange_outlined,
              color: Color.fromARGB(255, 217, 192, 233),
            ),
            icon: Icon(Icons.currency_exchange),
            label: 'Transactions',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.account_circle_rounded,
              color: Color.fromARGB(255, 217, 192, 233),
            ),
            icon: Icon(
              Icons.account_circle_outlined,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
