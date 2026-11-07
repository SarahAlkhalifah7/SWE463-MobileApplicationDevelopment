import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';

void main() {
  runApp(const TaskarroApp());
}

class TaskarroApp extends StatelessWidget {
  const TaskarroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taskarro',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7563E8)),
        scaffoldBackgroundColor: const Color(0xFFFFF9F0),
      ),
      home: const WelcomeScreen(),
    );
  }
}
