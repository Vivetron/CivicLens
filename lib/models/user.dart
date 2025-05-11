class User {
  final String id;
  final String email;
  final String displayName;
  final String? alias;
  final String? state;
  final List<String> followedPoliticians;
  final List<String> followedBills;
  final List<String> followedTopics;
  final List<String> savedItems;
  final NotificationSettings notificationSettings;
  final DateTime createdAt;
  final DateTime lastLogin;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.alias,
    this.state,
    this.followedPoliticians = const [],
    this.followedBills = const [],
    this.followedTopics = const [],
    this.savedItems = const [],
    required this.notificationSettings,
    required this.createdAt,
    required this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      alias: json['alias'],
      state: json['state'],
      followedPoliticians: List<String>.from(json['followedPoliticians'] ?? []),
      followedBills: List<String>.from(json['followedBills'] ?? []),
      followedTopics: List<String>.from(json['followedTopics'] ?? []),
      savedItems: List<String>.from(json['savedItems'] ?? []),
      notificationSettings: NotificationSettings.fromJson(json['notificationSettings'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: DateTime.parse(json['lastLogin']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'alias': alias,
      'state': state,
      'followedPoliticians': followedPoliticians,
      'followedBills': followedBills,
      'followedTopics': followedTopics,
      'savedItems': savedItems,
      'notificationSettings': notificationSettings.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  // Create a new instance with updated values
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? alias,
    String? state,
    List<String>? followedPoliticians,
    List<String>? followedBills,
    List<String>? followedTopics,
    List<String>? savedItems,
    NotificationSettings? notificationSettings,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      alias: alias ?? this.alias,
      state: state ?? this.state,
      followedPoliticians: followedPoliticians ?? this.followedPoliticians,
      followedBills: followedBills ?? this.followedBills,
      followedTopics: followedTopics ?? this.followedTopics,
      savedItems: savedItems ?? this.savedItems,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

class NotificationSettings {
  final bool enablePush;
  final bool enableEmail;
  final bool billUpdates;
  final bool politicianUpdates;
  final bool commentReplies;
  final bool dailyDigest;

  NotificationSettings({
    this.enablePush = true,
    this.enableEmail = true,
    this.billUpdates = true,
    this.politicianUpdates = true,
    this.commentReplies = true,
    this.dailyDigest = false,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enablePush: json['enablePush'] ?? true,
      enableEmail: json['enableEmail'] ?? true,
      billUpdates: json['billUpdates'] ?? true,
      politicianUpdates: json['politicianUpdates'] ?? true,
      commentReplies: json['commentReplies'] ?? true,
      dailyDigest: json['dailyDigest'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enablePush': enablePush,
      'enableEmail': enableEmail,
      'billUpdates': billUpdates,
      'politicianUpdates': politicianUpdates,
      'commentReplies': commentReplies,
      'dailyDigest': dailyDigest,
    };
  }

  NotificationSettings copyWith({
    bool? enablePush,
    bool? enableEmail,
    bool? billUpdates,
    bool? politicianUpdates,
    bool? commentReplies,
    bool? dailyDigest,
  }) {
    return NotificationSettings(
      enablePush: enablePush ?? this.enablePush,
      enableEmail: enableEmail ?? this.enableEmail,
      billUpdates: billUpdates ?? this.billUpdates,
      politicianUpdates: politicianUpdates ?? this.politicianUpdates,
      commentReplies: commentReplies ?? this.commentReplies,
      dailyDigest: dailyDigest ?? this.dailyDigest,
    );
  }
} 