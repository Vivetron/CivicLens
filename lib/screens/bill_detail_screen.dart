import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/bills_riverpod.dart';
import '../utils/app_theme.dart';
import '../widgets/bills/bill_vote_summary.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/error_view.dart';

class BillDetailScreen extends ConsumerStatefulWidget {
  final String billId;
  
  const BillDetailScreen({
    Key? key,
    required this.billId,
  }) : super(key: key);

  @override
  ConsumerState<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends ConsumerState<BillDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch bill details when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(billsProvider.notifier).fetchBillDetails(widget.billId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final billsState = ref.watch(billsProvider);
    final bill = billsState.selectedBill;
    final isLoading = billsState.isLoading;
    final error = billsState.error;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(bill?.number ?? 'Bill Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border_outlined),
            onPressed: () {
              // TODO: Implement bookmark functionality
            },
          ),
        ],
      ),
      body: isLoading
          ? const LoadingIndicator()
          : error != null
              ? ErrorView(
                  message: error,
                  onRetry: () => ref.read(billsProvider.notifier).fetchBillDetails(widget.billId),
                )
              : bill == null
                  ? const Center(child: Text('Bill not found'))
                  : _buildBillDetails(bill),
    );
  }
  
  Widget _buildBillDetails(bill) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bill.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Status and date info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Status:', bill.status),
                const SizedBox(height: 4),
                _buildInfoRow(
                  'Introduced:',
                  dateFormat.format(bill.introducedDate),
                ),
                const SizedBox(height: 4),
                _buildInfoRow(
                  'Last Action:',
                  dateFormat.format(bill.lastActionDate),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // AI Summary
          Text(
            'AI Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(bill.aiGeneratedSummary),
          
          const SizedBox(height: 24),
          
          // Sponsors
          Text(
            'Sponsors',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildListWithChips(bill.sponsors),
          
          const SizedBox(height: 16),
          
          // Cosponsors
          Text(
            'Cosponsors',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildListWithChips(bill.cosponsors),
          
          const SizedBox(height: 24),
          
          // Votes if available
          if (bill.voteData != null) ...[
            Text(
              'Votes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            // The BillVoteSummary widget (yet to be implemented)
            // BillVoteSummary(voteData: bill.voteData),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'House Votes',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildVoteCount('Yea', bill.voteData['houseVotes']['yea'], Colors.green),
                        _buildVoteCount('Nay', bill.voteData['houseVotes']['nay'], Colors.red),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Senate Votes',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildVoteCount('Yea', bill.voteData['senateVotes']['yea'], Colors.green),
                        _buildVoteCount('Nay', bill.voteData['senateVotes']['nay'], Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Committees
          Text(
            'Committees',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildList(bill.committees),
          
          const SizedBox(height: 24),
          
          // Related Bills
          Text(
            'Related Bills',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildRelatedBills(bill.relatedBills),
          
          const SizedBox(height: 24),
          
          // Full Text
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to bill full text screen
            },
            icon: const Icon(Icons.article_outlined),
            label: const Text('View Full Text'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
  
  Widget _buildListWithChips(List<String> items) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: items.map((item) {
        return InkWell(
          onTap: () {
            // TODO: Navigate to politician details
          },
          child: Chip(
            label: Text(item),
            backgroundColor: AppTheme.chipBackground,
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildList(List<String> items) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text('• ${items[index]}'),
        );
      },
    );
  }
  
  Widget _buildRelatedBills(List<String> relatedBills) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: relatedBills.map((billNumber) {
        return ActionChip(
          label: Text(billNumber),
          backgroundColor: AppTheme.chipBackground,
          onPressed: () {
            // TODO: Navigate to related bill details
            // For now, just show a snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Navigate to $billNumber')),
            );
          },
        );
      }).toList(),
    );
  }
  
  Widget _buildVoteCount(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
} 