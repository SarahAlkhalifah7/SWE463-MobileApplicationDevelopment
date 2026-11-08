import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/parent.dart';

class AccountStorage {
  static const String _accountsKey = 'parent_accounts';

  // Get all saved parent accounts
  static Future<List<ParentAccount>> getAccounts() async {
    final prefs = await SharedPreferences.getInstance();

    final accountsData = prefs.getStringList(_accountsKey) ?? [];

    return accountsData.map((accountString) {
      final Map<String, dynamic> data = jsonDecode(accountString);

      return ParentAccount.fromJson(data);
    }).toList();
  }

  // Save all parent accounts
  static Future<void> _saveAccounts(List<ParentAccount> accounts) async {
    final prefs = await SharedPreferences.getInstance();

    final accountsData = accounts
        .map((account) => jsonEncode(account.toJson()))
        .toList();

    await prefs.setStringList(_accountsKey, accountsData);
  }

  // Create a new account
  static Future<bool> createAccount(ParentAccount account) async {
    final accounts = await getAccounts();

    final emailExists = accounts.any(
      (existingParent) =>
          existingParent.email.trim().toLowerCase() ==
          account.email.trim().toLowerCase(),
    );

    // Do not allow duplicate emails
    if (emailExists) {
      return false;
    }

    accounts.add(account);

    await _saveAccounts(accounts);

    return true;
  }

  // Parent login
  static Future<ParentAccount?> login({
    required String email,
    required String password,
  }) async {
    final accounts = await getAccounts();

    for (final parent in accounts) {
      if (parent.email.trim().toLowerCase() == email.trim().toLowerCase() &&
          parent.password == password) {
        return parent;
      }
    }

    return null;
  }

  static Future<void> updateAccount(ParentAccount updatedAccount) async {
    final accounts = await getAccounts();

    final index = accounts.indexWhere(
      (account) =>
          account.email.trim().toLowerCase() ==
          updatedAccount.email.trim().toLowerCase(),
    );

    if (index != -1) {
      accounts[index] = updatedAccount;

      await _saveAccounts(accounts);
    }
  }
}
