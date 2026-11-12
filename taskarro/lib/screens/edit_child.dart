import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/child.dart';

import 'package:flutter/services.dart';

class EditChildScreen extends StatefulWidget {
  const EditChildScreen({super.key, required this.child});

  final Child child;

  @override
  State<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends State<EditChildScreen> {
  late TextEditingController _nameController;

  final ImagePicker _imagePicker = ImagePicker();

  late String selectedAvatar;
  XFile? selectedPhoto;

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

  // Camera / Library menu
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

  // Pick image
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

      // Keep same child code
      accessCode: widget.child.accessCode,

      // New photo if selected,
      // otherwise keep old photo
      photoPath: selectedPhoto?.path ?? widget.child.photoPath,
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
                      'Update the child name or profile.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Child name
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
                    'Choose Profile',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Choose an icon or add a photo',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 14),

                  // Avatars + Camera
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ...avatars.map((avatar) {
                        final isSelected =
                            selectedPhoto == null && selectedAvatar == avatar;

                        return InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            setState(() {
                              selectedAvatar = avatar;

                              // Choosing icon
                              // removes new photo
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

                      // Camera
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
                          icon: const Icon(Icons.copy_rounded),
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: widget.child.accessCode),
                            );

                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Child code copied!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
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
