import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../utils/app_theme.dart';
import '../common/loading_indicator.dart';
import '../common/error_view.dart';

// A simple state notifier provider to simulate feed data
final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier();
});

class FeedState {
  final List<FeedItem> items;
  final bool isLoading;
  final String? error;
  final bool hasMore;

  const FeedState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
  });

  FeedState copyWith({
    List<FeedItem>? items,
    bool? isLoading,
    String? error,
    bool? hasMore,
  }) {
    return FeedState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier() : super(const FeedState()) {
    loadFeed();
  }

  Future<void> loadFeed({bool refresh = false}) async {
    try {
      if (refresh) {
        state = state.copyWith(
          isLoading: true,
          items: [],
          hasMore: true,
        );
      } else {
        state = state.copyWith(isLoading: true);
        if (!state.hasMore) return;
      }

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Generate mock data
      final newItems = _generateMockFeedItems(refresh ? 0 : state.items.length, 15);

      state = state.copyWith(
        items: refresh ? newItems : [...state.items, ...newItems],
        isLoading: false,
        hasMore: newItems.length >= 15,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load feed: $e',
      );
    }
  }

  // Helper method to generate mock feed items
  List<FeedItem> _generateMockFeedItems(int offset, int count) {
    final items = <FeedItem>[];
    final types = [
      FeedItemType.billIntroduced,
      FeedItemType.billPassed,
      FeedItemType.politicianStatement,
      FeedItemType.voteResult,
      FeedItemType.newPolitician,
    ];
    
    for (var i = 0; i < count; i++) {
      final index = offset + i;
      final type = types[index % types.length];
      final timestamp = DateTime.now().subtract(Duration(hours: index * 4));
      
      String? politicianId;
      String? billId;
      
      if (type == FeedItemType.billIntroduced || type == FeedItemType.billPassed) {
        billId = 'bill_$index';
      }
      
      if (type == FeedItemType.politicianStatement || type == FeedItemType.newPolitician) {
        politicianId = 'politician_$index';
      }
      
      if (type == FeedItemType.voteResult) {
        billId = 'bill_$index';
        politicianId = 'politician_${index % 10}';
      }
      
      items.add(
        FeedItem(
          id: 'feed_item_$index',
          type: type,
          title: _generateTitle(type, index),
          summary: _generateSummary(type, index),
          timestamp: timestamp,
          politicianId: politicianId,
          billId: billId,
          imageUrl: type == FeedItemType.newPolitician || type == FeedItemType.politicianStatement
              ? 'https://via.placeholder.com/150'
              : null,
        ),
      );
    }
    
    return items;
  }
  
  String _generateTitle(FeedItemType type, int index) {
    switch (type) {
      case FeedItemType.billIntroduced:
        return 'New Bill Introduced: H.R.${1000 + index}';
      case FeedItemType.billPassed:
        return 'Bill Passed: H.R.${1000 + index}';
      case FeedItemType.politicianStatement:
        return 'Statement from ${_getPoliticianName(index)}';
      case FeedItemType.voteResult:
        return 'Vote Results: H.R.${1000 + index}';
      case FeedItemType.newPolitician:
        return 'New Representative: ${_getPoliticianName(index)}';
    }
  }
  
  String _generateSummary(FeedItemType type, int index) {
    switch (type) {
      case FeedItemType.billIntroduced:
        return 'A new bill addressing ${_getRandomTopic()} has been introduced in the House.';
      case FeedItemType.billPassed:
        return 'The bill related to ${_getRandomTopic()} has passed with bipartisan support.';
      case FeedItemType.politicianStatement:
        return '"We must prioritize ${_getRandomTopic()} to ensure a better future for all Americans." - ${_getPoliticianName(index)}';
      case FeedItemType.voteResult:
        return 'The vote on H.R.${1000 + index} has concluded with 234 in favor and 201 against.';
      case FeedItemType.newPolitician:
        return '${_getPoliticianName(index)} has been elected to represent ${_getRandomState()}.';
    }
  }
  
  String _getPoliticianName(int index) {
    final firstNames = ['John', 'Jane', 'Michael', 'Sarah', 'Robert', 'Emily', 'David', 'Lisa'];
    final lastNames = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis'];
    
    final firstName = firstNames[index % firstNames.length];
    final lastName = lastNames[(index + 3) % lastNames.length];
    
    return 'Rep. $firstName $lastName';
  }
  
  String _getRandomTopic() {
    final topics = [
      'healthcare reform',
      'education funding',
      'infrastructure',
      'climate change',
      'tax policy',
      'national security',
      'immigration',
      'economic growth',
    ];
    
    return topics[DateTime.now().millisecondsSinceEpoch % topics.length];
  }
  
  String _getRandomState() {
    final states = ['California', 'Texas', 'Florida', 'New York', 'Pennsylvania', 'Illinois', 'Ohio', 'Georgia'];
    
    return states[DateTime.now().millisecondsSinceEpoch % states.length];
  }
}

enum FeedItemType {
  billIntroduced,
  billPassed,
  politicianStatement,
  voteResult,
  newPolitician,
}

class FeedItem {
  final String id;
  final FeedItemType type;
  final String title;
  final String summary;
  final DateTime timestamp;
  final String? politicianId;
  final String? billId;
  final String? imageUrl;

  const FeedItem({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    required this.timestamp,
    this.politicianId,
    this.billId,
    this.imageUrl,
  });
}

class FeedTab extends ConsumerStatefulWidget {
  const FeedTab({Key? key}) : super(key: key);

  @override
  ConsumerState<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends ConsumerState<FeedTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final feedState = ref.read(feedProvider);
      if (!feedState.isLoading && feedState.hasMore) {
        ref.read(feedProvider.notifier).loadFeed();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final items = feedState.items;
    final isLoading = feedState.isLoading;
    final error = feedState.error;

    if (error != null && items.isEmpty) {
      return ErrorView(
        message: error,
        onRetry: () => ref.read(feedProvider.notifier).loadFeed(refresh: true),
      );
    }

    if (items.isEmpty && isLoading) {
      return const ShimmerLoadingList();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(feedProvider.notifier).loadFeed(refresh: true);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: items.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          return FeedItemCard(
            item: items[index],
            onTap: () => _handleFeedItemTap(items[index]),
          );
        },
      ),
    );
  }

  void _handleFeedItemTap(FeedItem item) {
    if (item.billId != null) {
      context.push('/bills/${item.billId}');
    } else if (item.politicianId != null) {
      context.push('/politicians/${item.politicianId}');
    }
  }
}

class FeedItemCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback onTap;

  const FeedItemCard({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final iconData = _getIconForType(item.type);
    final iconColor = _getColorForType(item.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      iconData,
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(item.timestamp),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.mediumGrey,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.summary,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (item.imageUrl != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: AppTheme.lightGrey,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 48, color: AppTheme.mediumGrey),
                      ),
                    ),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.thumb_up_outlined,
                          size: 16,
                          color: AppTheme.mediumGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(item.id.hashCode % 100) + 10}',
                          style: TextStyle(
                            color: AppTheme.mediumGrey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.comment_outlined,
                          size: 16,
                          color: AppTheme.mediumGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(item.id.hashCode % 20) + 5}',
                          style: TextStyle(
                            color: AppTheme.mediumGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.bookmark_border,
                      size: 18,
                      color: AppTheme.mediumGrey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(FeedItemType type) {
    switch (type) {
      case FeedItemType.billIntroduced:
        return Icons.description_outlined;
      case FeedItemType.billPassed:
        return Icons.check_circle_outlined;
      case FeedItemType.politicianStatement:
        return Icons.forum_outlined;
      case FeedItemType.voteResult:
        return Icons.how_to_vote_outlined;
      case FeedItemType.newPolitician:
        return Icons.person_add_outlined;
    }
  }

  Color _getColorForType(FeedItemType type) {
    switch (type) {
      case FeedItemType.billIntroduced:
        return AppTheme.infoColor;
      case FeedItemType.billPassed:
        return AppTheme.successColor;
      case FeedItemType.politicianStatement:
        return AppTheme.primaryColor;
      case FeedItemType.voteResult:
        return AppTheme.secondaryColor;
      case FeedItemType.newPolitician:
        return AppTheme.warningColor;
    }
  }
} 