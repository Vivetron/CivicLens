class Comment {
  final String id;
  final String userId;
  final String userAlias;
  final String content;
  final DateTime timestamp;
  final String itemId;
  final String itemType;
  final int likes;
  final List<String> likedBy;
  final List<Reply> replies;

  Comment({
    required this.id,
    required this.userId,
    required this.userAlias,
    required this.content,
    required this.timestamp,
    required this.itemId,
    required this.itemType,
    required this.likes,
    required this.likedBy,
    required this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userAlias: json['user_alias'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      itemId: json['item_id'] ?? '',
      itemType: json['item_type'] ?? '',
      likes: json['likes'] ?? 0,
      likedBy: List<String>.from(json['liked_by'] ?? []),
      replies: json['replies'] != null
          ? List<Reply>.from(
              json['replies'].map((x) => Reply.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_alias': userAlias,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'item_id': itemId,
      'item_type': itemType,
      'likes': likes,
      'liked_by': likedBy,
      'replies': replies.map((x) => x.toJson()).toList(),
    };
  }
}

class Reply {
  final String id;
  final String userId;
  final String userAlias;
  final String content;
  final DateTime timestamp;
  final int likes;
  final List<String> likedBy;

  Reply({
    required this.id,
    required this.userId,
    required this.userAlias,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.likedBy,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userAlias: json['user_alias'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      likes: json['likes'] ?? 0,
      likedBy: List<String>.from(json['liked_by'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_alias': userAlias,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'liked_by': likedBy,
    };
  }
} 