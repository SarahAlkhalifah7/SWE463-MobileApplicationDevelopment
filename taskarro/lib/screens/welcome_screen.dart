import 'package:flutter/material.dart';

import 'child_mode.dart';
import 'parent_login.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 60,
                  color: Color(0xFFFFC94A),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Taskarro',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7563E8),
                  ),
                ),
                const Text('Ready for your next adventure?'),
                const SizedBox(height: 40),
                const Text(
                  "Who's using Taskarro?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ParentLoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Enter Parent Mode'),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChildModeScreen(),
                        ),
                      );
                    },
                    child: const Text('Enter Child Mode'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
