import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../utils/app_theme.dart';
import '../widgets/home/feed_tab.dart';
import '../widgets/home/bills_tab.dart';
import '../widgets/home/politicians_tab.dart';
import '../widgets/home/search_tab.dart';
import '../widgets/home/profile_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final int initialTab;
  
  const HomeScreen({
    Key? key,
    this.initialTab = 0,
  }) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _currentIndex;
  late PageController _pageController;
  
  final List<Widget> _tabs = [
    const FeedTab(),
    const BillsTab(),
    const PoliticiansTab(),
    const SearchTab(),
    const ProfileTab(),
  ];
  
  final List<String> _tabTitles = [
    'Feed',
    'Bills',
    'Politicians',
    'Search',
    'Profile',
  ];
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _pageController = PageController(initialPage: _currentIndex);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToTab(int index) {
    switch (index) {
      case 0:
        context.go('/'); // Home/Feed
        break;
      case 1:
        context.go('/bills'); // Bills tab
        break;
      case 2:
        context.go('/politicians'); // Politicians tab
        break;
      case 3:
        context.go('/search'); // Search tab
        break;
      case 4:
        context.go('/profile'); // Profile tab
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTitles[_currentIndex]),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_currentIndex != 4) // Don't show on profile tab
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                context.push('/notifications');
              },
            ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.mediumGrey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gavel_outlined),
            activeIcon: Icon(Icons.gavel),
            label: 'Bills',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Politicians',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
