import 'package:flutter/material.dart';

import '../models/parent.dart';
import 'welcome_screen.dart';
import '../models/child.dart';
import '../services/account_storage.dart';
import 'edit_child.dart';

class ParentProfileScreen extends StatelessWidget {
  const ParentProfileScreen({
    super.key,
    required this.parent,
    required this.onParentUpdated,
  });

  final ParentAccount parent;
  final ValueChanged<ParentAccount> onParentUpdated;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF9F0),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Parent profile
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        parent.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        parent.email,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // Account information title
                const Text(
                  'Account Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                // Account information card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE8E3F5)),
                  ),
                  child: Column(
                    children: [
                      _infoRow(
                        icon: Icons.person_outline,
                        title: 'Name',
                        value: parent.name,
                      ),

                      const Divider(height: 25),

                      _infoRow(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        value: parent.email,
                      ),

                      const Divider(height: 25),

                      _infoRow(
                        icon: Icons.child_care,
                        title: 'Children',
                        value: '${parent.children.length}',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // My Children title
                const Text(
                  'My Children',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                // Children list
                if (parent.children.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE8E3F5)),
                    ),
                    child: const Text(
                      'No children added yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...parent.children.map(
                    (child) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE8E3F5)),
                      ),
                      child: Row(
                        children: [
                          // Child avatar
                          Container(
                            width: 52,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF2EFFF),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              child.avatar,
                              style: const TextStyle(fontSize: 29),
                            ),
                          ),

                          const SizedBox(width: 14),

                          // Child information
                          // Child information
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  child.name,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  'Child Code: ${child.accessCode}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Copy + Edit buttons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit child
                              IconButton(
                                tooltip: 'Edit child',
                                icon: const Icon(Icons.edit_outlined, size: 22),
                                color: Theme.of(context).colorScheme.primary,
                                onPressed: () async {
                                  final updatedChild =
                                      await Navigator.push<Child>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              EditChildScreen(child: child),
                                        ),
                                      );

                                  if (updatedChild == null) {
                                    return;
                                  }

                                  // Replace the edited child
                                  final updatedChildren = parent.children.map((
                                    currentChild,
                                  ) {
                                    if (currentChild.accessCode ==
                                        child.accessCode) {
                                      return updatedChild;
                                    }

                                    return currentChild;
                                  }).toList();

                                  // Create updated parent
                                  final updatedParent = ParentAccount(
                                    name: parent.name,
                                    email: parent.email,
                                    password: parent.password,
                                    children: updatedChildren,
                                  );

                                  // Save changes
                                  await AccountStorage.updateAccount(
                                    updatedParent,
                                  );

                                  // Update Home + Profile
                                  onParentUpdated(updatedParent);

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Child profile updated!'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 25),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Log Out'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7563E8)),

        const SizedBox(width: 12),

        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

        const Spacer(),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}
