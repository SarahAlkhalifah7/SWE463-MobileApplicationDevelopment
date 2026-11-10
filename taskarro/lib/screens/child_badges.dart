import 'package:flutter/material.dart';

import '../models/child.dart';

class ChildBadgesScreen extends StatelessWidget {
  const ChildBadgesScreen({
    super.key,
    required this.child,
  });

  final Child child;

  @override
  Widget build(BuildContext context) {
    final badges = [
      {
        'emoji': '⭐',
        'name': 'First Task',
        'description': 'Complete your first task',
        'unlocked': true,
      },
      {
        'emoji': '🔥',
        'name': 'On Fire',
        'description': 'Reach a 7-day streak',
        'unlocked': true,
      },
      {
        'emoji': '🏆',
        'name': 'Task Master',
        'description': 'Complete 50 tasks',
        'unlocked': false,
      },
      {
        'emoji': '🌟',
        'name': 'Star Collector',
        'description': 'Earn 100 stars',
        'unlocked': true,
      },
      {
        'emoji': '🚀',
        'name': 'Super Helper',
        'description': 'Complete 10 tasks',
        'unlocked': false,
      },
      {
        'emoji': '🎯',
        'name': 'Perfect Week',
        'description': 'Finish a weekly challenge',
        'unlocked': false,
      },
    ];

    final unlockedCount =
        badges.where((badge) => badge['unlocked'] == true).length;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9F0),
        elevation: 0,
        foregroundColor: const Color(0xFF292640),
        title: const Text(
          'Achievements & Badges',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: const Color(0xFFEDE8FF),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Text(
                      '🏅',
                      style: TextStyle(fontSize: 42),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$unlockedCount / ${badges.length} badges collected',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF292640),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Keep going to collect them all!',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: unlockedCount / badges.length,
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(10),
                            backgroundColor: Colors.white,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                              Color(0xFF7563E8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'My Badges ⭐',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF292640),
                  ),
            ),

            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: badges.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final badge = badges[index];
                final isUnlocked = badge['unlocked'] == true;

                return Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(
                      color: Color(0xFFE5DFFF),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Opacity(
                          opacity: isUnlocked ? 1 : 0.35,
                          child: Text(
                            badge['emoji'] as String,
                            style: const TextStyle(fontSize: 58),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          badge['name'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF292640),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          badge['description'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isUnlocked
                                ? const Color(0xFFDDF5E8)
                                : const Color(0xFFF3F0F0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isUnlocked ? 'UNLOCKED' : 'LOCKED',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked
                                  ? Colors.green.shade700
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                'Keep going, ${child.name}! Every little step counts.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF7563E8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}