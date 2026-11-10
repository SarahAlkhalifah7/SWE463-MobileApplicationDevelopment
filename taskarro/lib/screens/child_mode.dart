import 'package:flutter/material.dart';

import '../models/child.dart';
import 'child_tasks.dart';
import 'placeholder.dart';

class ChildModeScreen extends StatefulWidget {
  const ChildModeScreen({
    super.key,
    required this.child,
  });

  final Child child;

  @override
  State<ChildModeScreen> createState() => _ChildModeScreenState();
}

class _ChildModeScreenState extends State<ChildModeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      ChildTasksScreen(child: widget.child),
      const PlaceholderScreen(
        title: 'Reward Progress',
      ),
      const PlaceholderScreen(
        title: 'Streak and Weekly Challenge',
      ),
      const PlaceholderScreen(
        title: 'Achievements / Badges',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Taskarro Child'),
        backgroundColor: Colors.transparent,
      ),
      body: screens[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_fire_department_outlined),
            selectedIcon: Icon(Icons.local_fire_department),
            label: 'Challenges',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Badges',
          ),
        ],
      ),
    );
  }
}