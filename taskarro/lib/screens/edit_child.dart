import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/child.dart';

class EditChildScreen extends StatefulWidget {
  const EditChildScreen({super.key, required this.child});

  final Child child;

  @override
  State<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends State<EditChildScreen> {
  late TextEditingController _nameController;
  late String selectedAvatar;

  final List<String> avatars = ['🐰', '🐼', '🦊', '🐱', '🐻'];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.child.name);

    selectedAvatar = widget.child.avatar;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the child name.')),
      );

      return;
    }

    final updatedChild = Child(
      name: name,
      avatar: selectedAvatar,

      // Keep the same generated code
      accessCode: widget.child.accessCode,

      // Keep existing photo if there is one
      photoPath: widget.child.photoPath,
    );

    Navigator.pop(context, updatedChild);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),

      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Edit Child',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Edit Child Profile',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7563E8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Center(
                    child: Text(
                      'Update the child name or profile icon.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Child Name',
                      prefixIcon: Icon(Icons.child_care),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Choose Profile Icon',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 14),

                  // Avatars
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: avatars.map((avatar) {
                      final isSelected = selectedAvatar == avatar;

                      return InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          setState(() {
                            selectedAvatar = avatar;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 58,
                          height: 58,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : const Color(0xFFF5F2FF),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : const Color(0xFFE2DDF5),
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: Text(
                            avatar,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 30),

                  // Child code
                  const Text(
                    'Child Access Code',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE8E3F5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline, color: Colors.grey),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            widget.child.accessCode,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        IconButton(
                          tooltip: 'Copy child code',
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: widget.child.accessCode),
                            );

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Child code copied!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'The access code cannot be edited.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 35),

                  // Save
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _saveChanges,
                      child: const Text(
                        'Save Changes',
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
