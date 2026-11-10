import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/child.dart';
import '../models/parent.dart';
import '../services/account_storage.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key, required this.parent});

  final ParentAccount parent;

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  final List<String> avatars = ['🐰', '🐼', '🦊', '🐱', '🐻'];

  String selectedAvatar = '🐰';

  XFile? selectedPhoto;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Show camera / library options
  void _showPhotoOptions() {
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

                  _pickPhoto(ImageSource.camera);
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Library'),
                onTap: () {
                  Navigator.pop(sheetContext);

                  _pickPhoto(ImageSource.gallery);
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

  // Pick photo
  Future<void> _pickPhoto(ImageSource source) async {
    final XFile? photo = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (photo != null && mounted) {
      setState(() {
        selectedPhoto = photo;
      });
    }
  }

  // Generate unique 4-digit child code
  Future<String> _generateUniqueCode() async {
    final accounts = await AccountStorage.getAccounts();

    final Set<String> usedCodes = {};

    for (final account in accounts) {
      for (final child in account.children) {
        usedCodes.add(child.accessCode);
      }
    }

    final random = Random();

    String code;

    do {
      code = (1000 + random.nextInt(9000)).toString();
    } while (usedCodes.contains(code));

    return code;
  }

  // Save child
  Future<void> _saveChild() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final code = await _generateUniqueCode();

    final newChild = Child(
      name: _nameController.text.trim(),
      avatar: selectedAvatar,
      accessCode: code,
      photoPath: selectedPhoto?.path,
    );

    final updatedChildren = [...widget.parent.children, newChild];

    final updatedParent = ParentAccount(
      name: widget.parent.name,
      email: widget.parent.email,
      password: widget.parent.password,
      children: updatedChildren,
    );

    await AccountStorage.updateAccount(updatedParent);

    if (!mounted) return;

    await showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (dialogContext) {
    return AlertDialog(
      title: const Text('Child Added Successfully!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Give this access code to your child:',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            code,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              color: Color(0xFF7563E8),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Use this code to enter Child Mode.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Done'),
        ),
      ],
    );
  },
);

if (!mounted) return;

Navigator.pop(context, updatedParent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),

      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Add Child',
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
                    const Icon(
                      Icons.child_care,
                      size: 60,
                      color: Color(0xFF7563E8),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Add a New Child',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7563E8),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Create their Taskarro profile.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 30),

                    // Child name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Child Name',
                        hintText: 'Enter child name',
                        prefixIcon: Icon(Icons.child_care),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the child name';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 25),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Choose Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Choose an icon or add a photo',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Icons + camera
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        ...avatars.map((avatar) {
                          final isSelected =
                              selectedPhoto == null && selectedAvatar == avatar;

                          return InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () {
                              setState(() {
                                selectedAvatar = avatar;

                                // Remove photo selection
                                // when an icon is selected
                                selectedPhoto = null;
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
                                    ? Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
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
                        }),

                        // Camera / selected photo
                        InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: _showPhotoOptions,
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF5F2FF),
                              border: Border.all(
                                color: selectedPhoto != null
                                    ? Theme.of(context).colorScheme.primary
                                    : const Color(0xFFE2DDF5),
                                width: selectedPhoto != null ? 3 : 1,
                              ),
                            ),

                            child: selectedPhoto != null
                                ? ClipOval(
                                    child: Image.file(
                                      File(selectedPhoto!.path),
                                      width: 58,
                                      height: 58,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt_outlined,
                                    color: Color(0xFF7563E8),
                                  ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Selected profile preview
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Selected profile: ',
                          style: TextStyle(color: Colors.grey),
                        ),

                        if (selectedPhoto == null)
                          Text(
                            selectedAvatar,
                            style: const TextStyle(fontSize: 27),
                          )
                        else
                          ClipOval(
                            child: Image.file(
                              File(selectedPhoto!.path),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    // Add Child
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _saveChild,
                        child: const Text(
                          'Add Child',
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
      ),
    );
  }
}
