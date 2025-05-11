import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../models/user.dart';

// Auth state class to hold the current authentication state
class AuthState {
  final User? currentUser;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.currentUser,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  // Create a copy of the current state with updated fields
  AuthState copyWith({
    User? currentUser,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Clear error
  AuthState clearError() {
    return copyWith(error: null);
  }
}

// Auth notifier class to handle authentication logic
class AuthNotifier extends StateNotifier<AuthState> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthNotifier() : super(const AuthState()) {
    // Initialize on creation
    init();
  }

  Future<void> init() async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Check if user data is in secure storage
      final userData = await _secureStorage.read(key: 'user_data');
      if (userData != null) {
        final user = User.fromJson(json.decode(userData));
        state = state.copyWith(
          currentUser: user,
          isAuthenticated: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to initialize: ${e.toString()}',
      );
      debugPrint(state.error);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    try {
      state = state.clearError();
      state = state.copyWith(isLoading: true);
      
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
      
      // Save user data in secure storage
      await _secureStorage.write(
        key: 'user_data',
        value: json.encode(user.toJson()),
      );
      
      state = state.copyWith(
        currentUser: user,
        isAuthenticated: true,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Login failed: ${e.toString()}',
      );
      debugPrint(state.error);
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> loginWithGoogle() async {
    try {
      state = state.clearError();
      state = state.copyWith(isLoading: true);
      
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
      
      // Save user data in secure storage
      await _secureStorage.write(
        key: 'user_data',
        value: json.encode(user.toJson()),
      );
      
      state = state.copyWith(
        currentUser: user,
        isAuthenticated: true,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Google login failed: ${e.toString()}',
      );
      debugPrint(state.error);
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> logout() async {
    try {
      state = state.clearError();
      state = state.copyWith(isLoading: true);
      
      await _secureStorage.delete(key: 'user_data');
      
      state = state.copyWith(
        currentUser: null,
        isAuthenticated: false,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Logout failed: ${e.toString()}',
      );
      debugPrint(state.error);
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

// Provider for accessing the auth state throughout the app
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
}); 