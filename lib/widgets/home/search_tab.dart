import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/bills_riverpod.dart';
import '../../providers/politicians_riverpod.dart';
import '../../utils/app_theme.dart';
import '../common/loading_indicator.dart';
import '../common/error_view.dart';

class SearchTab extends ConsumerStatefulWidget {
  const SearchTab({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends ConsumerState<SearchTab> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging && _searchQuery.isNotEmpty) {
      _performSearch();
    }
  }

  void _performSearch() {
    setState(() {
      _isSearching = true;
    });

    if (_tabController.index == 0) {
      // Bills tab
      ref.read(billsProvider.notifier).searchBills(_searchQuery);
    } else {
      // Politicians tab
      ref.read(politiciansProvider.notifier).applyFilter(_searchQuery);
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      // Clear results when search is cleared
      ref.read(billsProvider.notifier).fetchBills(refresh: true);
      ref.read(politiciansProvider.notifier).fetchPoliticians(refresh: true);
    } else {
      _performSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search bills and politicians...',
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
            onSubmitted: _handleSearch,
            textInputAction: TextInputAction.search,
          ),
        ),
        if (_isSearching || _searchQuery.isNotEmpty) ...[
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.mediumGrey,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'Bills'),
              Tab(text: 'Politicians'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _BillsSearchResultsView(searchQuery: _searchQuery),
                _PoliticiansSearchResultsView(searchQuery: _searchQuery),
              ],
            ),
          ),
        ] else ...[
          // Recent searches and trending topics
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recent searches
                  Text(
                    'Recent Searches',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Immigration',
                      'Healthcare',
                      'Nancy Pelosi',
                      'Infrastructure',
                      'Climate Change',
                    ].map((term) => _buildSearchChip(term)).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Trending topics
                  Text(
                    'Trending Topics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Budget 2023',
                      'Inflation',
                      'Student Loans',
                      'Foreign Policy',
                      'Supreme Court',
                      'Tax Reform',
                      'Energy',
                      'Defense',
                    ].map((topic) => _buildSearchChip(topic)).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Popular filters
                  Text(
                    'Popular Filters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildFilterCard(
                    title: 'Recently Introduced Bills',
                    description: 'Find the latest legislation introduced in Congress',
                    icon: Icons.new_releases_outlined,
                    onTap: () {
                      // TODO: Navigate to recently introduced bills
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildFilterCard(
                    title: 'Bills Passed This Month',
                    description: 'See what Congress has recently passed',
                    icon: Icons.check_circle_outline,
                    onTap: () {
                      // TODO: Navigate to recently passed bills
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildFilterCard(
                    title: 'Republicans in the Senate',
                    description: 'View all Republican senators',
                    icon: Icons.people_outline,
                    onTap: () {
                      // TODO: Navigate to Republican senators
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildFilterCard(
                    title: 'Democrats in the House',
                    description: 'View all Democratic representatives',
                    icon: Icons.people_outline,
                    onTap: () {
                      // TODO: Navigate to Democratic representatives
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchChip(String term) {
    return ActionChip(
      label: Text(term),
      backgroundColor: AppTheme.chipBackground,
      onPressed: () {
        _searchController.text = term;
        _handleSearch(term);
      },
    );
  }

  Widget _buildFilterCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
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
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.mediumGrey,
                          ),
                    ),
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
      ),
    );
  }
}

class _BillsSearchResultsView extends ConsumerWidget {
  final String searchQuery;

  const _BillsSearchResultsView({Key? key, required this.searchQuery}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsState = ref.watch(billsProvider);
    final bills = billsState.bills;
    final isLoading = billsState.isLoading;
    final error = billsState.error;

    if (searchQuery.isEmpty) {
      return const Center(child: Text('Enter a search term'));
    }

    if (error != null && bills.isEmpty) {
      return ErrorView(
        message: error,
        onRetry: () => ref.read(billsProvider.notifier).searchBills(searchQuery),
      );
    }

    if (isLoading && bills.isEmpty) {
      return const ShimmerLoadingList();
    }

    if (bills.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.mediumGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'No bills found for "$searchQuery"',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try using different keywords or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        return _BillResultCard(
          bill: bill,
          onTap: () {
            context.push('/bills/${bill.id}');
          },
        );
      },
    );
  }
}

class _BillResultCard extends StatelessWidget {
  final dynamic bill;
  final VoidCallback onTap;

  const _BillResultCard({
    Key? key,
    required this.bill,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      bill.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(bill.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      bill.status,
                      style: TextStyle(
                        color: _getStatusColor(bill.status),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                bill.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                bill.summary,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'introduced':
      case 'referred to committee':
        return AppTheme.infoColor;
      case 'reported by committee':
      case 'passed house':
      case 'passed senate':
        return AppTheme.warningColor;
      case 'sent to president':
        return AppTheme.primaryColor;
      case 'signed into law':
        return AppTheme.successColor;
      case 'vetoed':
        return AppTheme.errorColor;
      default:
        return AppTheme.mediumGrey;
    }
  }
}

class _PoliticiansSearchResultsView extends ConsumerWidget {
  final String searchQuery;

  const _PoliticiansSearchResultsView({Key? key, required this.searchQuery}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final politiciansState = ref.watch(politiciansProvider);
    final politicians = politiciansState.politicians;
    final isLoading = politiciansState.isLoading;
    final error = politiciansState.error;

    if (searchQuery.isEmpty) {
      return const Center(child: Text('Enter a search term'));
    }

    if (error != null && politicians.isEmpty) {
      return ErrorView(
        message: error,
        onRetry: () => ref.read(politiciansProvider.notifier).applyFilter(searchQuery),
      );
    }

    if (isLoading && politicians.isEmpty) {
      return const ShimmerLoadingList();
    }

    if (politicians.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.mediumGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'No politicians found for "$searchQuery"',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try using different keywords or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: politicians.length,
      itemBuilder: (context, index) {
        final politician = politicians[index];
        return _PoliticianResultCard(
          politician: politician,
          onTap: () {
            context.push('/politicians/${politician.id}');
          },
        );
      },
    );
  }
}

class _PoliticianResultCard extends StatelessWidget {
  final Politician politician;
  final VoidCallback onTap;

  const _PoliticianResultCard({
    Key? key,
    required this.politician,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final partyColor = _getPartyColor(politician.party);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Photo
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: politician.photoUrl != null
                      ? Image.network(
                          politician.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppTheme.lightGrey,
                            child: const Center(
                              child: Icon(Icons.person, size: 32, color: AppTheme.mediumGrey),
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.lightGrey,
                          child: const Center(
                            child: Icon(Icons.person, size: 32, color: AppTheme.mediumGrey),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      politician.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: partyColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getPartyAbbreviation(politician.party),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${politician.title} - ${politician.state}${politician.district != null ? ' ${politician.district}' : ''}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.mediumGrey,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.mediumGrey,
              ),
            ],
          ),
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