import 'child.dart';

class ParentAccount {
  final String name;
  final String email;
  final String password;
  final List<Child> children;

  ParentAccount({
    required this.name,
    required this.email,
    required this.password,
    required this.children,
  });

  // Convert ParentAccount object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  // Convert JSON back to ParentAccount object
  factory ParentAccount.fromJson(Map<String, dynamic> json) {
    return ParentAccount(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      children: (json['children'] as List)
          .map((child) => Child.fromJson(Map<String, dynamic>.from(child)))
          .toList(),
    );
  }
}
