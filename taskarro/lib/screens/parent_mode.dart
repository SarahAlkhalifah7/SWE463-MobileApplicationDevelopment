import 'package:flutter/material.dart';

import '../models/parent.dart';
import 'parent_dashboard.dart';
import 'placeholder.dart';
import 'parent_profile.dart';
import 'task_management.dart';

class ParentModeScreen extends StatefulWidget {
  const ParentModeScreen({super.key, required this.parent});

  final ParentAccount parent;

  @override
  State<ParentModeScreen> createState() => _ParentModeScreenState();
}

class _ParentModeScreenState extends State<ParentModeScreen> {
  int selectedIndex = 0;
  late ParentAccount currentParent;

  @override
  void initState() {
    super.initState();
    currentParent = widget.parent;
  }

  @override
  Widget build(BuildContext context) {
    // Screens for the bottom navigation
    final screens = [
      // Real Parent Dashboard
      ParentDashboard(
        parent: currentParent,
        onParentUpdated: (updatedParent) {
          setState(() {
            currentParent = updatedParent;
          });
        },
      ),

      TaskManagementScreen(parent: currentParent),

      // We will implement this later
      const PlaceholderScreen(title: 'Rewards Management'),

      ParentProfileScreen(
        parent: currentParent,
        onParentUpdated: (updatedParent) {
          setState(() {
            currentParent = updatedParent;
          });
        },
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),

      appBar: AppBar(
        title: const Text(
          'Taskarro Parent',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: 'Tasks',
          ),

          NavigationDestination(
            icon: Icon(Icons.card_giftcard_outlined),
            selectedIcon: Icon(Icons.card_giftcard),
            label: 'Rewards',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
