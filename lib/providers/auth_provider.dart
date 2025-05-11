import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
  String? get error => _error;

  Future<void> init() async {
    try {
      _setLoading(true);
      
      // Check if user data is in secure storage
      final userData = await _secureStorage.read(key: 'user_data');
      if (userData != null) {
        _currentUser = User.fromJson(json.decode(userData));
        _isAuthenticated = true;
      }
    } catch (e) {
      _error = 'Failed to initialize: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Mock login - in a real app, this would call your authentication API
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock user data
      final user = User(
        id: 'user_123',
        email: email,
        displayName: 'Demo User',
        alias: 'Citizen123',
        state: 'NY',
        followedPoliticians: [],
        followedBills: [],
        followedTopics: ['Healthcare', 'Economy'],
        savedItems: [],
        notificationSettings: NotificationSettings(),
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      
      _currentUser = user;
      _isAuthenticated = true;
      
      // Save user data in secure storage
      await _secureStorage.write(
        key: 'user_data',
        value: json.encode(user.toJson()),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loginWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();
      
      // Mock Google login
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock user data
      final user = User(
        id: 'google_user_456',
        email: 'google_user@example.com',
        displayName: 'Google User',
        alias: 'GoogleCitizen',
        state: 'CA',
        followedPoliticians: [],
        followedBills: [],
        followedTopics: ['Environment', 'Technology'],
        savedItems: [],
        notificationSettings: NotificationSettings(),
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      
      _currentUser = user;
      _isAuthenticated = true;
      
      // Save user data in secure storage
      await _secureStorage.write(
        key: 'user_data',
        value: json.encode(user.toJson()),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Google login failed: ${e.toString()}';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loginWithApple() async {
    try {
      _setLoading(true);
      _clearError();
      
      // Mock Apple login
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock user data
      final user = User(
        id: 'apple_user_789',
        email: 'apple_user@example.com',
        displayName: 'Apple User',
        alias: 'AppleCitizen',
        state: 'WA',
        followedPoliticians: [],
        followedBills: [],
        followedTopics: ['Education', 'Defense'],
        savedItems: [],
        notificationSettings: NotificationSettings(),
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      
      _currentUser = user;
      _isAuthenticated = true;
      
      // Save user data in secure storage
      await _secureStorage.write(
        key: 'user_data',
        value: json.encode(user.toJson()),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Apple login failed: ${e.toString()}';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loginAnonymously() async {
    try {
      _setLoading(true);
      _clearError();
      
      // Mock anonymous login
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock user data
      final user = User(
        id: 'anon_user_${DateTime.now().millisecondsSinceEpoch}',
        email: '',
        displayName: 'Anonymous',
        alias: 'Anonymous Citizen',
        followedPoliticians: [],
        followedBills: [],
        followedTopics: [],
        savedItems: [],
        notificationSettings: NotificationSettings(),
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      
      _currentUser = user;
      _isAuthenticated = true;
      
      // Save user data in secure storage
      await _secureStorage.write(
        key: 'user_data',
        value: json.encode(user.toJson()),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Anonymous login failed: ${e.toString()}';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      _setLoading(true);
      
      // Clear secure storage
      await _secureStorage.delete(key: 'user_data');
      
      _currentUser = null;
      _isAuthenticated = false;
      
      notifyListeners();
    } catch (e) {
      _error = 'Logout failed: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUserProfile({
    String? displayName,
    String? alias,
    String? state,
    String? ageGroup,
    String? gender,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_currentUser == null) {
        _error = 'No user logged in';
        return false;
      }
      
      // Update user data
      _currentUser = _currentUser!.copyWith(
        displayName: displayName,
        alias: alias,
        state: state,
        ageGroup: ageGroup,
        gender: gender,
      );
      
      // Save updated user data
      await _secureStorage.write(
        key: 'user_data',
        value: json.encode(_currentUser!.toJson()),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Update profile failed: ${e.toString()}';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateNotificationSettings(NotificationSettings settings) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_currentUser == null) {
        _error = 'No user logged in';
        return false;
      }
      
      // Update notification settings
      _currentUser = _currentUser!.copyWith(
        notificationSettings: settings,
      );
      
      // Save updated user data
      await _secureStorage.write(
        key: 'user_data',
        value: json.encode(_currentUser!.toJson()),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Update notification settings failed: ${e.toString()}';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleFollowPolitician(String politicianId) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_currentUser == null) {
        _error = 'No user logged in';
        return false;
      }
      
      List<String> updatedList = List.from(_currentUser!.followedPoliticians);
      
      // Toggle politician in followed list
      if (updatedList.contains(politicianId)) {
        updatedList.remove(politicianId);
      } else {
        updatedList.add(politicianId);
      }
      
      // Update user data
      _currentUser = _currentUser!.copyWith(
        followedPoliticians: updatedList,
      );
      
      // Save updated user data
      await _secureStorage.write(
        key: 'user_data',
        value: json.encode(_currentUser!.toJson()),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Toggle follow politician failed: ${e.toString()}';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleFollowBill(String billId) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_currentUser == null) {
        _error = 'No user logged in';
        return false;
      }
      
      List<String> updatedList = List.from(_currentUser!.followedBills);
      
      // Toggle bill in followed list
      if (updatedList.contains(billId)) {
        updatedList.remove(billId);
      } else {
        updatedList.add(billId);
      }
      
      // Update user data
      _currentUser = _currentUser!.copyWith(
        followedBills: updatedList,
      );
      
      // Save updated user data
      await _secureStorage.write(
        key: 'user_data',
        value: json.encode(_currentUser!.toJson()),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Toggle follow bill failed: ${e.toString()}';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleFollowTopic(String topic) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_currentUser == null) {
        _error = 'No user logged in';
        return false;
      }
      
      List<String> updatedList = List.from(_currentUser!.followedTopics);
      
      // Toggle topic in followed list
      if (updatedList.contains(topic)) {
        updatedList.remove(topic);
      } else {
        updatedList.add(topic);
      }
      
      // Update user data
      _currentUser = _currentUser!.copyWith(
        followedTopics: updatedList,
      );
      
      // Save updated user data
      await _secureStorage.write(
        key: 'user_data',
        value: json.encode(_currentUser!.toJson()),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Toggle follow topic failed: ${e.toString()}';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleSaveItem(String itemId) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_currentUser == null) {
        _error = 'No user logged in';
        return false;
      }
      
      List<String> updatedList = List.from(_currentUser!.savedItems);
      
      // Toggle item in saved list
      if (updatedList.contains(itemId)) {
        updatedList.remove(itemId);
      } else {
        updatedList.add(itemId);
      }
      
      // Update user data
      _currentUser = _currentUser!.copyWith(
        savedItems: updatedList,
      );
      
      // Save updated user data
      await _secureStorage.write(
        key: 'user_data',
        value: json.encode(_currentUser!.toJson()),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Toggle save item failed: ${e.toString()}';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
} 