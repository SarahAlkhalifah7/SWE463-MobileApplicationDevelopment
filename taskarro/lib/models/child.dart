class Child {
  final String name;
  final String avatar;
  final String accessCode;
  final String? photoPath;

  Child({
    required this.name,
    required this.avatar,
    required this.accessCode,
    this.photoPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatar': avatar,
      'accessCode': accessCode,
      'photoPath': photoPath,
    };
  }

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      accessCode: json['accessCode'] as String,
      photoPath: json['photoPath'] as String?,
    );
  }
}
