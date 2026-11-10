import 'package:flutter/material.dart';

import '../models/child.dart';
import '../services/account_storage.dart';
import 'child_mode.dart';

class ChildCodeLoginScreen extends StatefulWidget {
  const ChildCodeLoginScreen({super.key});

  @override
  State<ChildCodeLoginScreen> createState() => _ChildCodeLoginScreenState();
}

class _ChildCodeLoginScreenState extends State<ChildCodeLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<Child?> _findChildByCode(String code) async {
    final accounts = await AccountStorage.getAccounts();

    for (final account in accounts) {
      for (final child in account.children) {
        if (child.accessCode == code) {
          return child;
        }
      }
    }

    return null;
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final child = await _findChildByCode(
      _codeController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (child == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Child code not found. Please try again.',
          ),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChildModeScreen(child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      appBar: AppBar(
        title: const Text('Child Login'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Icon(
                      Icons.child_care_rounded,
                      size: 70,
                      color: Color(0xFF7563E8),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Welcome, little star!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7563E8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter the 4-digit code your parent gave you.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        letterSpacing: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Child Access Code',
                        hintText: '0000',
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your child code';
                        }

                        if (!RegExp(r'^\d{4}$')
                            .hasMatch(value.trim())) {
                          return 'Code must contain exactly 4 digits';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _continue,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Continue'),
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