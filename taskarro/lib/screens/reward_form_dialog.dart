import 'package:flutter/material.dart';

import '../models/reward.dart';
import '../services/reward_storage.dart';

// Pop-up form for adding a new reward or editing an existing one.
// If [reward] is null we are adding, otherwise we are editing.
// Returns the saved Reward, or null if the parent pressed Cancel.
class RewardFormDialog extends StatefulWidget {
  const RewardFormDialog({super.key, required this.childId, this.reward});

  final String childId;
  final Reward? reward;

  @override
  State<RewardFormDialog> createState() => _RewardFormDialogState();
}

class _RewardFormDialogState extends State<RewardFormDialog> {
  static const Color purple = Color(0xFF7563E8);
  static const Color border = Color(0xFFE8E3F5);
  static const Color lightPurple = Color(0xFFF2EFFF);

  // Emojis the parent can choose for a reward
  static const List<String> rewardIcons = [
    '🎁',
    '🍦',
    '🍿',
    '🎮',
    '🧸',
    '🍕',
    '🏞️',
    '📖',
    '🎨',
    '🚲',
    '🍩',
    '🎢',
  ];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _starsController = TextEditingController();

  String _icon = rewardIcons.first;

  bool get _isEditing => widget.reward != null;

  @override
  void initState() {
    super.initState();

    // Editing: fill the form with the reward's current values
    final reward = widget.reward;
    if (reward != null) {
      _titleController.text = reward.title;
      _starsController.text = reward.requiredStars.toString();
      _icon = reward.icon;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final requiredStars = int.parse(_starsController.text.trim());

    Reward saved;

    if (_isEditing) {
      saved = widget.reward!.copyWith(
        title: title,
        icon: _icon,
        requiredStars: requiredStars,
      );
      await RewardStorage.updateReward(saved);
    } else {
      saved = Reward(
        id: RewardStorage.generateId(),
        childId: widget.childId,
        title: title,
        icon: _icon,
        requiredStars: requiredStars,
      );
      await RewardStorage.addReward(saved);
    }

    if (!mounted) return;

    Navigator.pop(context, saved);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        _isEditing ? 'Edit Reward' : 'Add Reward',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reward name',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 30,
                decoration: _inputDecoration('e.g. Ice Cream'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a reward name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              const Text('Icon', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildIconPicker(),
              const SizedBox(height: 16),
              const Text(
                'Stars required',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _starsController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('e.g. 100').copyWith(
                  prefixIcon: const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF5B82E),
                  ),
                  suffixText: 'stars',
                ),
                validator: (value) {
                  final stars = int.tryParse(value?.trim() ?? '');

                  if (stars == null) {
                    return 'Please enter a number of stars';
                  }
                  if (stars < 1 || stars > 1000) {
                    return 'Stars must be between 1 and 1000';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: purple,
            foregroundColor: Colors.white,
          ),
          child: Text(_isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
    );
  }

  Widget _buildIconPicker() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: rewardIcons.map((icon) {
        final isSelected = icon == _icon;

        return GestureDetector(
          onTap: () => setState(() => _icon = icon),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? lightPurple : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? purple : border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
        );
      }).toList(),
    );
  }
}
