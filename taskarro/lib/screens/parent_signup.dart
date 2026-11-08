import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'account_created.dart';

class ParentSignUpScreen extends StatefulWidget {
  const ParentSignUpScreen({super.key});

  @override
  State<ParentSignUpScreen> createState() => _ParentSignUpScreenState();
}

class _ParentSignUpScreenState extends State<ParentSignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  bool _hidePassword = true;
  int numberOfChildren = 1;

  // Available icons
  final List<String> avatars = ['🐰', '🐼', '🦊', '🐱', '🐻'];

  // Child names
  final List<TextEditingController> childControllers = [
    TextEditingController(),
  ];

  // Selected icon for each child
  final List<String> selectedAvatars = ['🐰'];

  // Selected photo for each child
  final List<XFile?> selectedPhotos = [null];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    for (final controller in childControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // Add another child
  void _addChild() {
    setState(() {
      numberOfChildren++;

      childControllers.add(TextEditingController());

      selectedAvatars.add('🐰');
      selectedPhotos.add(null);
    });
  }

  // Remove last child
  void _removeChild() {
    if (numberOfChildren > 1) {
      setState(() {
        childControllers.last.dispose();

        childControllers.removeLast();
        selectedAvatars.removeLast();
        selectedPhotos.removeLast();

        numberOfChildren--;
      });
    }
  }

  // Show photo options
  void _showPhotoOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(sheetContext);

                  _pickPhoto(index, ImageSource.camera);
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Library'),
                onTap: () {
                  Navigator.pop(sheetContext);

                  _pickPhoto(index, ImageSource.gallery);
                },
              ),

              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () {
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Pick photo from camera or gallery
  Future<void> _pickPhoto(int index, ImageSource source) async {
    final XFile? photo = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (photo != null && mounted) {
      setState(() {
        selectedPhotos[index] = photo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),

      // Purple upper bar
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Create Parent Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),

              child: Form(
                key: _formKey,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Star
                    const Icon(
                      Icons.star_rounded,
                      size: 55,
                      color: Color(0xFFFFC94A),
                    ),

                    const SizedBox(height: 10),

                    // Title
                    const Text(
                      "Start your family's adventure",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7563E8),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'A little teamwork. A lot of big wins.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 30),

                    // Parent name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Parent Name',
                        hintText: 'Enter your name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }

                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Create a password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }

                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 25),

                    // Number of children
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Number of Children',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Row(
                          children: [
                            IconButton(
                              onPressed: _removeChild,
                              icon: const Icon(Icons.remove_circle_outline),
                            ),

                            Text(
                              '$numberOfChildren',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            IconButton(
                              onPressed: _addChild,
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Children
                    ...List.generate(numberOfChildren, (index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2DDF5)),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Child number
                            Text(
                              'Child ${index + 1}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7563E8),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Child name
                            TextFormField(
                              controller: childControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Child ${index + 1} Name',
                                hintText: 'Enter child name',
                                prefixIcon: const Icon(Icons.child_care),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter the child name';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            const Text(
                              'Choose Profile',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(
                              'Choose an icon or add a photo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Icons + camera
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                // Avatar icons
                                ...avatars.map((avatar) {
                                  final isSelected =
                                      selectedPhotos[index] == null &&
                                      selectedAvatars[index] == avatar;

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(50),
                                    onTap: () {
                                      setState(() {
                                        selectedAvatars[index] = avatar;

                                        // Remove photo
                                        // when icon selected
                                        selectedPhotos[index] = null;
                                      });
                                    },

                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      width: 55,
                                      height: 55,
                                      alignment: Alignment.center,

                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,

                                        color: isSelected
                                            ? Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer
                                            : const Color(0xFFF5F2FF),

                                        border: Border.all(
                                          color: isSelected
                                              ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                              : const Color(0xFFE2DDF5),
                                          width: isSelected ? 3 : 1,
                                        ),
                                      ),

                                      child: Text(
                                        avatar,
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                    ),
                                  );
                                }),

                                // Camera / photo
                                InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () {
                                    _showPhotoOptions(index);
                                  },

                                  child: Container(
                                    width: 55,
                                    height: 55,

                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,

                                      color: const Color(0xFFF5F2FF),

                                      border: Border.all(
                                        color: selectedPhotos[index] != null
                                            ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                            : const Color(0xFFE2DDF5),
                                        width: selectedPhotos[index] != null
                                            ? 3
                                            : 1,
                                      ),
                                    ),

                                    child: selectedPhotos[index] != null
                                        // Selected photo
                                        ? ClipOval(
                                            child: Image.file(
                                              File(selectedPhotos[index]!.path),
                                              width: 55,
                                              height: 55,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        // Camera icon
                                        : const Icon(
                                            Icons.camera_alt_outlined,
                                            color: Color(0xFF7563E8),
                                          ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Selected profile preview
                            Row(
                              children: [
                                const Text(
                                  'Selected profile: ',
                                  style: TextStyle(color: Colors.grey),
                                ),

                                if (selectedPhotos[index] == null)
                                  Text(
                                    selectedAvatars[index],
                                    style: const TextStyle(fontSize: 25),
                                  )
                                else
                                  ClipOval(
                                    child: Image.file(
                                      File(selectedPhotos[index]!.path),
                                      width: 35,
                                      height: 35,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 10),

                    // Create account
                    SizedBox(
                      width: double.infinity,
                      height: 52,

                      child: FilledButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AccountCreatedScreen(),
                              ),
                            );
                          }
                        },

                        child: const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Back to login
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Already have an account? Log in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
