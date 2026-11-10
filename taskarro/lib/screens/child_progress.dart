import 'package:flutter/material.dart';

import '../models/child.dart';

class ChildProgressScreen extends StatelessWidget {
  const ChildProgressScreen({
    super.key,
    required this.child,
  });

  final Child child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          children: [
            Text(
              '${child.name}’s Reward Journey',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF29283A),
              ),
            ),
            const SizedBox(height: 18),
            _RewardProgressCard(),
            const SizedBox(height: 18),
            _JourneyCard(),
            const SizedBox(height: 18),
            _StreakCard(),
            const SizedBox(height: 18),
            _WeeklyChallengeCard(),
          ],
        ),
      ),
    );
  }
}

class _RewardProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const currentStars = 80;
    const requiredStars = 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '🍦',
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(width: 10),
              Text(
                'Ice Cream Trip',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Your next reward',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: currentStars / requiredStars,
            minHeight: 9,
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFF7563E8),
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 8),
          const Text(
            '80 / 100 stars',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF7563E8),
            ),
          ),
          const SizedBox(height: 4),
          const Text('20 more stars to unlock!'),
        ],
      ),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE8E3F5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your adventure',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Keep completing missions to move forward.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _JourneyStep(
                    icon: Icons.flag,
                    label: 'Start',
                    completed: true,
                  ),
                  _JourneyLine(completed: true),
                  _JourneyStep(
                    icon: Icons.star,
                    label: 'Progress',
                    completed: true,
                  ),
                  _JourneyLine(completed: false),
                  _JourneyStep(
                    icon: Icons.card_giftcard,
                    label: 'Reward',
                    completed: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyStep extends StatelessWidget {
  const _JourneyStep({
    required this.icon,
    required this.label,
    required this.completed,
  });

  final IconData icon;
  final String label;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: completed
              ? const Color(0xFF7563E8)
              : const Color(0xFFEAE7F8),
          child: Icon(
            icon,
            color: completed ? Colors.white : Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: completed
                ? const Color(0xFF7563E8)
                : Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _JourneyLine extends StatelessWidget {
  const _JourneyLine({
    required this.completed,
  });

  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35,
      height: 5,
      color: completed
          ? const Color(0xFF7563E8)
          : const Color(0xFFEAE7F8),
    );
  }
}

class _StreakCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0B9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Text(
            '🔥',
            style: TextStyle(fontSize: 38),
          ),
          SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Streak',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '4 days',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE09D00),
                ),
              ),
              Text('Keep going!'),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyChallengeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE8E3F5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Color(0xFFFFC94A),
                  size: 30,
                ),
                SizedBox(width: 10),
                Text(
                  'Weekly Challenge',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Complete tasks for 5 days this week.',
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: 4 / 5,
              minHeight: 9,
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFF7563E8),
              backgroundColor: const Color(0xFFEAE7F8),
            ),
            const SizedBox(height: 8),
            const Text(
              '4 of 5 days completed',
              style: TextStyle(
                color: Color(0xFF7563E8),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Mystery reward: 50 stars 🎁',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}