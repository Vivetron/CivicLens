import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_riverpod.dart';
import '../../utils/app_theme.dart';
import '../common/loading_indicator.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;
    final isLoading = authState.isLoading;

    if (isLoading) {
      return const LoadingIndicator();
    }

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle,
              size: 80,
              color: AppTheme.mediumGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'Not logged in',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Please log in to access your profile',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.go('/login');
              },
              child: const Text('Log In'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(context, user),
          const SizedBox(height: 24),

          // Account Section
          _buildSectionHeader(context, 'Account'),
          _buildSettingsCard(
            context,
            [
              _buildSettingsItem(
                icon: Icons.person_outline,
                title: 'Personal Information',
                onTap: () {
                  // TODO: Navigate to personal information screen
                },
              ),
              _buildSettingsItem(
                icon: Icons.notifications_outlined,
                title: 'Notification Settings',
                onTap: () {
                  // TODO: Navigate to notification settings
                },
              ),
              _buildSettingsItem(
                icon: Icons.lock_outline,
                title: 'Privacy & Security',
                onTap: () {
                  // TODO: Navigate to privacy settings
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Content Section
          _buildSectionHeader(context, 'Content'),
          _buildSettingsCard(
            context,
            [
              _buildSettingsItem(
                icon: Icons.bookmark_outline,
                title: 'Saved Items',
                subtitle: 'View your saved bills and articles',
                onTap: () {
                  // TODO: Navigate to saved items
                },
              ),
              _buildSettingsItem(
                icon: Icons.star_outline,
                title: 'Following',
                subtitle: 'Manage politicians and topics you follow',
                onTap: () {
                  // TODO: Navigate to following screen
                },
              ),
              _buildSettingsItem(
                icon: Icons.history,
                title: 'Recent Activity',
                subtitle: 'View your recent activity in the app',
                onTap: () {
                  // TODO: Navigate to recent activity
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Support Section
          _buildSectionHeader(context, 'Support'),
          _buildSettingsCard(
            context,
            [
              _buildSettingsItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {
                  // TODO: Navigate to help & support
                },
              ),
              _buildSettingsItem(
                icon: Icons.policy_outlined,
                title: 'Terms & Policies',
                onTap: () {
                  // TODO: Navigate to terms & policies
                },
              ),
              _buildSettingsItem(
                icon: Icons.info_outline,
                title: 'About PoliSense',
                onTap: () {
                  // TODO: Navigate to about screen
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Log Out Button
          Center(
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
                side: BorderSide(color: AppTheme.errorColor),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: AppTheme.primaryColor,
          child: Icon(
            Icons.person,
            size: 64,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.displayName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email.isNotEmpty ? user.email : 'Anonymous User',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGrey,
              ),
        ),
        if (user.alias != null && user.alias!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '@${user.alias}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mediumGrey,
                ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatColumn(
              context,
              user.followedPoliticians?.length ?? 0,
              'Following',
            ),
            Container(
              height: 40,
              width: 1,
              color: AppTheme.lightGrey,
              margin: const EdgeInsets.symmetric(horizontal: 24),
            ),
            _buildStatColumn(
              context,
              user.savedItems?.length ?? 0,
              'Saved',
            ),
            Container(
              height: 40,
              width: 1,
              color: AppTheme.lightGrey,
              margin: const EdgeInsets.symmetric(horizontal: 24),
            ),
            _buildStatColumn(
              context,
              user.followedTopics?.length ?? 0,
              'Topics',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatColumn(BuildContext context, int count, String label) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGrey,
              ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> items) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppTheme.mediumGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.mediumGrey,
            ),
          ],
        ),
      ),
    );
  }
} 