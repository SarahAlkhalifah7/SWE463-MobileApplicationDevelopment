class Child {
  final String name;
  final String avatar;
  final String accessCode;

  Child({required this.name, required this.avatar, required this.accessCode});

  // Convert Child object to JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'avatar': avatar, 'accessCode': accessCode};
  }

  // Convert JSON back to Child object
  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      accessCode: json['accessCode'] as String,
    );
  }
}
