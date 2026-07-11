import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Clips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.queue),
            label: 'Queue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.style),
            label: 'Presets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/clips')) {
      return 0;
    }
    if (location.startsWith('/queue')) {
      return 1;
    }
    if (location.startsWith('/presets')) {
      return 2;
    }
    if (location.startsWith('/profile')) {
      return 3;
    }
    return 1; // Default to Queue (Home)
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/clips');
        break;
      case 1:
        context.go('/queue');
        break;
      case 2:
        context.go('/presets');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
}
