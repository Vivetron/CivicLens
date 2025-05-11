import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/bills_riverpod.dart';
import '../../utils/app_theme.dart';
import '../common/loading_indicator.dart';
import '../common/error_view.dart';

class BillsTab extends ConsumerStatefulWidget {
  const BillsTab({Key? key}) : super(key: key);

  @override
  ConsumerState<BillsTab> createState() => _BillsTabState();
}

class _BillsTabState extends ConsumerState<BillsTab> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final billsState = ref.read(billsProvider);
      if (!billsState.isLoading && billsState.hasMore && !_isSearching) {
        ref.read(billsProvider.notifier).fetchBills();
      }
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    
    if (query.isEmpty) {
      // Reset to normal state
      ref.read(billsProvider.notifier).fetchBills(refresh: true);
    } else {
      // Search for bills
      ref.read(billsProvider.notifier).searchBills(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final billsState = ref.watch(billsProvider);
    final bills = billsState.bills;
    final isLoading = billsState.isLoading;
    final error = billsState.error;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search bills...',
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
        Expanded(
          child: error != null && bills.isEmpty
              ? ErrorView(
                  message: error,
                  onRetry: () => ref.read(billsProvider.notifier).fetchBills(refresh: true),
                )
              : bills.isEmpty && isLoading
                  ? const ShimmerLoadingList()
                  : bills.isEmpty
                      ? const Center(child: Text('No bills found'))
                      : RefreshIndicator(
                          onRefresh: () async {
                            await ref.read(billsProvider.notifier).fetchBills(refresh: true);
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: bills.length + (isLoading && bills.isNotEmpty ? 1 : 0),
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              if (index == bills.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              
                              final bill = bills[index];
                              return _BillCard(
                                bill: bill,
                                onTap: () {
                                  context.push('/bills/${bill.id}');
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

class _BillCard extends StatelessWidget {
  final dynamic bill;
  final VoidCallback onTap;
  
  const _BillCard({
    Key? key,
    required this.bill,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                  Text(
                    bill.status,
                    style: TextStyle(
                      color: _getStatusColor(bill.status),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppTheme.mediumGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Introduced: ${dateFormat.format(bill.introducedDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.mediumGrey,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppTheme.mediumGrey,
                  ),
                ],
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