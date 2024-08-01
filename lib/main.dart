import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'transactions_page.dart';

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
        primaryColor: Color.fromARGB(255, 197, 197, 197),
        scaffoldBackgroundColor: Color.fromARGB(255, 228, 228, 228),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 94, 169, 179),
          foregroundColor: Colors.white, // Text color in the AppBar
        ),
      ),
      home: const MainNavigation(),
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
    const HomePage(),
    const TransactionsPage(),
    const ProfilePage(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentPage],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        onDestinationSelected: _onDestinationSelected,
        selectedIndex: _currentPage,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(
              Icons.home,
              color: Color.fromARGB(255, 94, 169, 179),
            ),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.currency_exchange_outlined,
              color: Color.fromARGB(255, 94, 169, 179),
            ),
            icon: Icon(Icons.currency_exchange),
            label: 'Transactions',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.account_circle_rounded,
              color: Color.fromARGB(255, 94, 169, 179),
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
