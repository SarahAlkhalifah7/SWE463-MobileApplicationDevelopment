import 'package:flutter/material.dart';

import 'child_mode.dart';
import 'parent_login.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Star
                  const Icon(
                    Icons.star_rounded,
                    size: 60,
                    color: Color(0xFFFFC94A),
                  ),

                  const SizedBox(height: 8),

                  // App name
                  const Text(
                    'Taskarro',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7563E8),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Subtitle
                  const Text(
                    'Ready for your next adventure?',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 50),

                  // Question
                  const Text(
                    "Who's using Taskarro?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 25),

                  // Parent Mode
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ParentLoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Enter Parent Mode',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Child Mode
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChildModeScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Enter Child Mode',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
