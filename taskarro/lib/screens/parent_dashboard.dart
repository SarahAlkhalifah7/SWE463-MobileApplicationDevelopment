import 'package:flutter/material.dart';

import '../models/parent.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key, required this.parent});

  final ParentAccount parent;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF9F0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(
                  'Hello, ${parent.name}! 👋',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF29283A),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Here's how your little stars are doing.",
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),

                const SizedBox(height: 30),

                // My Children title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Children',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${parent.children.length} children',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Child cards
                ...parent.children.map(
                  (child) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE8E3F5)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Avatar
                            Container(
                              width: 60,
                              height: 60,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF2EFFF),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                child.avatar,
                                style: const TextStyle(fontSize: 34),
                              ),
                            ),

                            const SizedBox(width: 14),

                            // Child name + code
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    child.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    'Child Code: ${child.accessCode}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Temporary progress
                        Row(
                          children: [
                            Expanded(
                              child: _buildStat(
                                icon: '⭐',
                                value: '0',
                                label: 'Stars',
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: _buildStat(
                                icon: '🔥',
                                value: '0',
                                label: 'Day Streak',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Today's Missions
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Today's Missions",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text('0 / 0', style: TextStyle(color: Colors.grey)),
                          ],
                        ),

                        const SizedBox(height: 10),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: const LinearProgressIndicator(
                            value: 0,
                            minHeight: 8,
                            backgroundColor: Color(0xFFEDEAF5),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Reward
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            children: [
                              Text('🎁', style: TextStyle(fontSize: 25)),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Next Reward',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'No reward set yet',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextButton(
                          onPressed: () {
                            // Child progress screen later
                          },
                          child: const Text('View Progress →'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                // Add child button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Add Child screen later
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Child'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat({
    required String icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
