import 'package:flutter/material.dart';

import 'child_progress.dart';
import '../models/child.dart';
import 'child_tasks.dart';
import 'child_challenges.dart';
import 'child_badges.dart';

class ChildModeScreen extends StatefulWidget {
  const ChildModeScreen({super.key, required this.child});

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
      ChildProgressScreen(child: widget.child),
      ChildChallengesScreen(child: widget.child),
      ChildBadgesScreen(child: widget.child),
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
