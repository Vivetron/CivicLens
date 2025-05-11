import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/bill_detail_screen.dart';
import '../providers/auth_riverpod.dart';

// Router provider that can be accessed through Riverpod
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // If the user is not authenticated and not on login, redirect to login
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.location == '/login';
      
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }
      
      // If user is authenticated and going to login, redirect to home
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Bill routes
          GoRoute(
            path: 'bills',
            builder: (context, state) => const HomeScreen(initialTab: 1),
          ),
          GoRoute(
            path: 'bills/:id',
            builder: (context, state) {
              final billId = state.pathParameters['id']!;
              return BillDetailScreen(billId: billId);
            },
          ),
          
          // Politician routes
          GoRoute(
            path: 'politicians',
            builder: (context, state) => const HomeScreen(initialTab: 2),
          ),
          GoRoute(
            path: 'politicians/:id',
            builder: (context, state) {
              final politicianId = state.pathParameters['id']!;
              // TODO: Implement PoliticianDetailScreen
              return Scaffold(
                appBar: AppBar(title: Text('Politician $politicianId')),
                body: Center(child: Text('Politician Details $politicianId')),
              );
            },
          ),
          
          // Search route
          GoRoute(
            path: 'search',
            builder: (context, state) => const HomeScreen(initialTab: 3),
          ),
          
          // Profile routes
          GoRoute(
            path: 'profile',
            builder: (context, state) => const HomeScreen(initialTab: 4),
          ),
          
          // Other routes
          GoRoute(
            path: 'notifications',
            builder: (context, state) {
              // TODO: Implement NotificationsScreen
              return Scaffold(
                appBar: AppBar(title: const Text('Notifications')),
                body: const Center(child: Text('Notifications')),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text('No route defined for ${state.location}'),
      ),
    ),
  );
}); 