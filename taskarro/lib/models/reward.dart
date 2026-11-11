class Reward {
  Reward({
    required this.id,
    required this.childId,
    required this.title,
    required this.requiredStars,
    this.icon = '🎁',
    this.isRedeemed = false,
    this.redeemedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;

  // The child this reward belongs to (we use the child's access code).
  final String childId;

  // e.g. "Ice Cream" or "Movie Night"
  final String title;

  // Emoji shown next to the reward, e.g. '🍦'
  final String icon;

  // How many stars the child needs to unlock this reward
  final int requiredStars;

  // true after the parent gives the reward to the child
  final bool isRedeemed;
  final DateTime? redeemedAt;

  final DateTime createdAt;

  // The child can get the reward when they have enough stars
  bool isAvailable(int childStars) {
    return childStars >= requiredStars;
  }

  // How many more stars the child needs (0 if they already have enough)
  int starsNeeded(int childStars) {
    final needed = requiredStars - childStars;
    return needed > 0 ? needed : 0;
  }

  // Progress from 0.0 to 1.0, used for progress bars
  double progress(int childStars) {
    if (requiredStars <= 0) return 1.0;
    return (childStars / requiredStars).clamp(0.0, 1.0);
  }

  // Creates a copy of this reward with some fields changed.
  // Used when the parent edits a reward or marks it as redeemed.
  Reward copyWith({
    String? childId,
    String? title,
    String? icon,
    int? requiredStars,
    bool? isRedeemed,
    DateTime? redeemedAt,
  }) {
    return Reward(
      id: id,
      childId: childId ?? this.childId,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      requiredStars: requiredStars ?? this.requiredStars,
      isRedeemed: isRedeemed ?? this.isRedeemed,
      redeemedAt: redeemedAt ?? this.redeemedAt,
      createdAt: createdAt,
    );
  }

  // Convert Reward object to JSON (to save it in SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'title': title,
      'icon': icon,
      'requiredStars': requiredStars,
      'isRedeemed': isRedeemed,
      'redeemedAt': redeemedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert JSON back to Reward object
  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String,
      childId: json['childId'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String? ?? '🎁',
      requiredStars: json['requiredStars'] as int,
      isRedeemed: json['isRedeemed'] as bool? ?? false,
      redeemedAt: json['redeemedAt'] == null
          ? null
          : DateTime.parse(json['redeemedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
