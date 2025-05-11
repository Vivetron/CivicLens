import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/comment.dart';

class CommentsProvider with ChangeNotifier {
  Map<String, List<Comment>> _comments = {};
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get comments for an item (bill or politician)
  List<Comment> getItemComments(String itemId) {
    return _comments[itemId] ?? [];
  }
  
  // Fetch comments for an item
  Future<List<Comment>> fetchComments(String itemId, String itemType) async {
    try {
      _setLoading(true);
      _clearError();
      
      // In a real app, this would be an API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate mock comments for this item
      final comments = _generateMockComments(itemId, itemType);
      
      // Store in the cache
      _comments[itemId] = comments;
      
      notifyListeners();
      return comments;
    } catch (e) {
      _error = 'Failed to fetch comments: ${e.toString()}';
      debugPrint(_error);
      return [];
    } finally {
      _setLoading(false);
    }
  }
  
  // Add a new comment
  Future<bool> addComment(
    String userId, 
    String userAlias, 
    String content, 
    String itemId, 
    String itemType
  ) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Create new comment
      final comment = Comment(
        id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        userAlias: userAlias,
        content: content,
        timestamp: DateTime.now(),
        itemId: itemId,
        itemType: itemType,
        likes: 0,
        likedBy: [],
        replies: [],
      );
      
      // In a real app, this would be an API call to save the comment
      await Future.delayed(const Duration(seconds: 1));
      
      // Add to local cache
      if (_comments.containsKey(itemId)) {
        _comments[itemId]!.insert(0, comment);
      } else {
        _comments[itemId] = [comment];
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add comment: ${e.toString()}';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Add a reply to a comment
  Future<bool> addReply(
    String commentId,
    String itemId,
    String userId,
    String userAlias,
    String content
  ) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Find the comment to reply to
      if (!_comments.containsKey(itemId)) {
        _error = 'Item not found';
        return false;
      }
      
      final commentIndex = _comments[itemId]!.indexWhere((c) => c.id == commentId);
      if (commentIndex == -1) {
        _error = 'Comment not found';
        return false;
      }
      
      // Create the reply
      final reply = Reply(
        id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        userAlias: userAlias,
        content: content,
        timestamp: DateTime.now(),
        likes: 0,
        likedBy: [],
      );
      
      // In a real app, this would be an API call to save the reply
      await Future.delayed(const Duration(seconds: 1));
      
      // Add to the comment's replies
      final comment = _comments[itemId]![commentIndex];
      final updatedReplies = List<Reply>.from(comment.replies)..add(reply);
      
      // Update the comment with the new reply
      _comments[itemId]![commentIndex] = Comment(
        id: comment.id,
        userId: comment.userId,
        userAlias: comment.userAlias,
        content: comment.content,
        timestamp: comment.timestamp,
        itemId: comment.itemId,
        itemType: comment.itemType,
        likes: comment.likes,
        likedBy: comment.likedBy,
        replies: updatedReplies,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add reply: ${e.toString()}';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Like/unlike a comment
  Future<bool> toggleLikeComment(String commentId, String itemId, String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Find the comment
      if (!_comments.containsKey(itemId)) {
        _error = 'Item not found';
        return false;
      }
      
      final commentIndex = _comments[itemId]!.indexWhere((c) => c.id == commentId);
      if (commentIndex == -1) {
        _error = 'Comment not found';
        return false;
      }
      
      final comment = _comments[itemId]![commentIndex];
      List<String> updatedLikedBy = List.from(comment.likedBy);
      int updatedLikes = comment.likes;
      
      // Toggle like
      if (updatedLikedBy.contains(userId)) {
        updatedLikedBy.remove(userId);
        updatedLikes--;
      } else {
        updatedLikedBy.add(userId);
        updatedLikes++;
      }
      
      // In a real app, this would be an API call to update the like status
      await Future.delayed(const Duration(seconds: 1));
      
      // Update the comment
      _comments[itemId]![commentIndex] = Comment(
        id: comment.id,
        userId: comment.userId,
        userAlias: comment.userAlias,
        content: comment.content,
        timestamp: comment.timestamp,
        itemId: comment.itemId,
        itemType: comment.itemType,
        likes: updatedLikes,
        likedBy: updatedLikedBy,
        replies: comment.replies,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to toggle like: ${e.toString()}';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Like/unlike a reply
  Future<bool> toggleLikeReply(String commentId, String replyId, String itemId, String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Find the comment that contains the reply
      if (!_comments.containsKey(itemId)) {
        _error = 'Item not found';
        return false;
      }
      
      final commentIndex = _comments[itemId]!.indexWhere((c) => c.id == commentId);
      if (commentIndex == -1) {
        _error = 'Comment not found';
        return false;
      }
      
      final comment = _comments[itemId]![commentIndex];
      final replyIndex = comment.replies.indexWhere((r) => r.id == replyId);
      
      if (replyIndex == -1) {
        _error = 'Reply not found';
        return false;
      }
      
      final reply = comment.replies[replyIndex];
      List<String> updatedLikedBy = List.from(reply.likedBy);
      int updatedLikes = reply.likes;
      
      // Toggle like
      if (updatedLikedBy.contains(userId)) {
        updatedLikedBy.remove(userId);
        updatedLikes--;
      } else {
        updatedLikedBy.add(userId);
        updatedLikes++;
      }
      
      // In a real app, this would be an API call to update the like status
      await Future.delayed(const Duration(seconds: 1));
      
      // Create updated reply
      final updatedReply = Reply(
        id: reply.id,
        userId: reply.userId,
        userAlias: reply.userAlias,
        content: reply.content,
        timestamp: reply.timestamp,
        likes: updatedLikes,
        likedBy: updatedLikedBy,
      );
      
      // Update the replies list
      List<Reply> updatedReplies = List.from(comment.replies);
      updatedReplies[replyIndex] = updatedReply;
      
      // Update the comment with new replies list
      _comments[itemId]![commentIndex] = Comment(
        id: comment.id,
        userId: comment.userId,
        userAlias: comment.userAlias,
        content: comment.content,
        timestamp: comment.timestamp,
        itemId: comment.itemId,
        itemType: comment.itemType,
        likes: comment.likes,
        likedBy: comment.likedBy,
        replies: updatedReplies,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to toggle like on reply: ${e.toString()}';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Generate mock comments for testing
  List<Comment> _generateMockComments(String itemId, String itemType) {
    // Number of comments is based on the item ID to make it deterministic
    int idNumber = int.tryParse(itemId.split('_').last) ?? 1;
    int commentCount = (idNumber % 10) + 3; // 3-12 comments per item
    
    List<Comment> mockComments = [];
    
    // Sample user aliases
    final List<String> userAliases = [
      'ConstitutionalCat',
      'DemocracyDefender',
      'PatrioticPenguin',
      'PoliticalPanda',
      'RepublicanRaccoon',
      'LibertarianLion',
      'ProgressivePelican',
      'ConservativeCrow',
      'ModerateMonkey',
      'IndependentIguana',
    ];
    
    for (int i = 0; i < commentCount; i++) {
      final String commentId = 'comment_${itemId}_$i';
      final String userId = 'user_${i + 1}';
      final String userAlias = userAliases[i % userAliases.length];
      
      // Generate content based on the type of item
      String content = '';
      if (itemType == 'bill') {
        final List<String> billComments = [
          'I think this bill addresses important issues, but I\'m concerned about section 3.',
          'This legislation doesn\'t go far enough to address the root causes.',
          'Finally! This is exactly what we need right now.',
          'I have reservations about the funding mechanism proposed here.',
          'Has anyone read the full text? There are some concerning provisions.',
          'I support the intent but question the implementation details.',
          'This seems like a bipartisan solution that could actually pass.',
          'The committee should hold public hearings on this before moving forward.',
          'We need more analysis on the economic impact.',
          'Why isn\'t this getting more media coverage?',
        ];
        content = billComments[i % billComments.length];
      } else {
        final List<String> politicianComments = [
          'I appreciate their consistent voting record on key issues.',
          'I disagree with their stance on recent legislation.',
          'They need to be more accessible to constituents.',
          'Their committee work has been impressive lately.',
          'I wish they would focus more on local issues.',
          'Their recent speech on policy reform was very insightful.',
          'They haven\'t delivered on their campaign promises.',
          'I value their pragmatic approach to governance.',
          'Their voting record contradicts their public statements.',
          'They\'ve been a strong advocate for our community.',
        ];
        content = politicianComments[i % politicianComments.length];
      }
      
      // Create some mock replies
      int replyCount = (i % 4); // 0-3 replies per comment
      List<Reply> replies = [];
      
      for (int j = 0; j < replyCount; j++) {
        final List<String> replyContents = [
          'I completely agree with your assessment.',
          'I see your point, but have you considered...',
          'Thanks for sharing this perspective.',
          'That\'s not accurate based on the facts.',
          'Do you have a source for that claim?',
          'This is an important point that many are overlooking.',
        ];
        
        replies.add(Reply(
          id: 'reply_${commentId}_$j',
          userId: 'user_${commentCount + j}',
          userAlias: userAliases[(i + j + 1) % userAliases.length],
          content: replyContents[j % replyContents.length],
          timestamp: DateTime.now().subtract(Duration(hours: j * 2)),
          likes: j % 5,
          likedBy: List.generate(j % 5, (index) => 'user_${index + 100}'),
        ));
      }
      
      mockComments.add(Comment(
        id: commentId,
        userId: userId,
        userAlias: userAlias,
        content: content,
        timestamp: DateTime.now().subtract(Duration(days: i)),
        itemId: itemId,
        itemType: itemType,
        likes: (i % 15), // 0-14 likes
        likedBy: List.generate(i % 15, (index) => 'user_${index + 50}'),
        replies: replies,
      ));
    }
    
    // Sort by timestamp (newest first)
    mockComments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return mockComments;
  }
} 