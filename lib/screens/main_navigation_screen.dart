import 'package:flutter/material.dart';
import 'package:clickfix/screens/home_tab.dart';
import 'package:clickfix/screens/services_tab.dart';
import 'package:clickfix/screens/booking_screen.dart';
import 'package:clickfix/screens/support_tab.dart';
import 'package:clickfix/theme.dart';
import 'package:clickfix/widgets/clickfix_logo.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const ServicesTab(),
    const BookingScreen(),
    const SupportTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const ClickFixLogo(
          vertical: false,
          iconSize: 32,
          fontSize: 18,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              setState(() {
                _currentIndex = 3; // Switch to profile/support tab
              });
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: isDark ? Colors.white.withOpacity(0.08) : ClickFixTheme.borderGray,
            height: 1.0,
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: isDark ? ClickFixTheme.primaryDark : Colors.white,
          indicatorColor: ClickFixTheme.primaryAmber.withOpacity(0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: ClickFixTheme.primaryAmber),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.category_outlined),
              selectedIcon: Icon(Icons.category_rounded, color: ClickFixTheme.primaryAmber),
              label: 'Services',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded, color: ClickFixTheme.primaryAmber),
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: Icon(Icons.support_agent_outlined),
              selectedIcon: Icon(Icons.support_agent_rounded, color: ClickFixTheme.primaryAmber),
              label: 'Support',
            ),
          ],
        ),
      ),
    );
  }
}
