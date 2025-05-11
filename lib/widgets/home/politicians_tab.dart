import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/politicians_riverpod.dart';
import '../../utils/app_theme.dart';
import '../common/loading_indicator.dart';
import '../common/error_view.dart';

class PoliticiansTab extends ConsumerStatefulWidget {
  const PoliticiansTab({Key? key}) : super(key: key);

  @override
  ConsumerState<PoliticiansTab> createState() => _PoliticiansTabState();
}

class _PoliticiansTabState extends ConsumerState<PoliticiansTab> with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  late TabController _tabController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final politiciansState = ref.read(politiciansProvider);
      if (!politiciansState.isLoading && politiciansState.hasMore && !_isSearching) {
        ref.read(politiciansProvider.notifier).fetchPoliticians();
      }
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _applyFilter(_tabController.index);
    }
  }

  void _applyFilter(int tabIndex) {
    String? filter;
    
    switch (tabIndex) {
      case 0: // All
        filter = null;
        break;
      case 1: // House
        filter = 'house';
        break;
      case 2: // Senate
        filter = 'senate';
        break;
    }
    
    ref.read(politiciansProvider.notifier).applyFilter(filter);
  }

  void _handleSearch(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    
    ref.read(politiciansProvider.notifier).applyFilter(
      query.isNotEmpty ? query : null
    );
  }

  @override
  Widget build(BuildContext context) {
    final politiciansState = ref.watch(politiciansProvider);
    final politicians = politiciansState.politicians;
    final isLoading = politiciansState.isLoading;
    final error = politiciansState.error;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search politicians...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _handleSearch('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: _handleSearch,
          ),
        ),
        if (!_isSearching) ...[
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.mediumGrey,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'House'),
              Tab(text: 'Senate'),
            ],
          ),
        ],
        Expanded(
          child: error != null && politicians.isEmpty
              ? ErrorView(
                  message: error,
                  onRetry: () => ref.read(politiciansProvider.notifier).fetchPoliticians(refresh: true),
                )
              : politicians.isEmpty && isLoading
                  ? const ShimmerLoadingList()
                  : politicians.isEmpty
                      ? const Center(child: Text('No politicians found'))
                      : RefreshIndicator(
                          onRefresh: () async {
                            await ref.read(politiciansProvider.notifier).fetchPoliticians(refresh: true);
                          },
                          child: GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: politicians.length + (isLoading ? 2 : 0),
                            itemBuilder: (context, index) {
                              if (index >= politicians.length) {
                                return const PoliticianCardSkeleton();
                              }
                              
                              return PoliticianCard(
                                politician: politicians[index],
                                onTap: () {
                                  context.push('/politicians/${politicians[index].id}');
                                },
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}

class PoliticianCard extends StatelessWidget {
  final Politician politician;
  final VoidCallback onTap;
  
  const PoliticianCard({
    Key? key,
    required this.politician,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final partyColor = _getPartyColor(politician.party);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo with party indicator
            Stack(
              children: [
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: politician.photoUrl != null
                      ? Image.network(
                          politician.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppTheme.lightGrey,
                            child: const Center(
                              child: Icon(Icons.person, size: 64, color: AppTheme.mediumGrey),
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.lightGrey,
                          child: const Center(
                            child: Icon(Icons.person, size: 64, color: AppTheme.mediumGrey),
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: partyColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getPartyAbbreviation(politician.party),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    politician.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${politician.title} - ${politician.state}${politician.district != null ? ' ${politician.district}' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.mediumGrey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getPartyColor(String party) {
    switch (party.toLowerCase()) {
      case 'democrat':
        return AppTheme.democratColor;
      case 'republican':
        return AppTheme.republicanColor;
      case 'independent':
        return AppTheme.independentColor;
      default:
        return AppTheme.mediumGrey;
    }
  }
  
  String _getPartyAbbreviation(String party) {
    switch (party.toLowerCase()) {
      case 'democrat':
        return 'D';
      case 'republican':
        return 'R';
      case 'independent':
        return 'I';
      default:
        return '?';
    }
  }
}

class PoliticianCardSkeleton extends StatelessWidget {
  const PoliticianCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton photo
          Container(
            height: 140,
            width: double.infinity,
            color: AppTheme.shimmerBaseColor,
          ),
          // Skeleton info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 18,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.shimmerBaseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.shimmerBaseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 