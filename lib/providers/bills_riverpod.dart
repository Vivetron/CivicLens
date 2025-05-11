import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import '../models/bill.dart';

// State class to store bills data
class BillsState {
  final List<Bill> bills;
  final Bill? selectedBill;
  final bool isLoading;
  final String? error;
  final int page;
  final bool hasMore;

  const BillsState({
    this.bills = const [],
    this.selectedBill,
    this.isLoading = false,
    this.error,
    this.page = 1,
    this.hasMore = true,
  });

  // Create a copy of this state with specified fields updated
  BillsState copyWith({
    List<Bill>? bills,
    Bill? selectedBill,
    bool? isLoading,
    String? error,
    int? page,
    bool? hasMore,
  }) {
    return BillsState(
      bills: bills ?? this.bills,
      selectedBill: selectedBill ?? this.selectedBill,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  // Clear error
  BillsState clearError() {
    return copyWith(error: null);
  }
}

// Notifier class to manage bill data
class BillsNotifier extends StateNotifier<BillsState> {
  BillsNotifier() : super(const BillsState()) {
    initialize();
  }

  Future<void> initialize() async {
    await fetchBills();
  }

  Future<void> fetchBills({bool refresh = false}) async {
    try {
      if (refresh) {
        state = state.copyWith(
          isLoading: true,
          page: 1,
          hasMore: true,
          bills: [],
        );
      } else {
        // If we're loading more data, keep existing bills
        state = state.copyWith(isLoading: true);
        
        // If there's no more data to load, return
        if (!state.hasMore) return;
      }

      // Mock API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate some mock bills data
      final newBills = _generateMockBills(state.page, 15);
      
      // Update the state with new bills
      final hasMore = newBills.length >= 15; // If we received fewer than requested, there's no more data
      
      state = state.copyWith(
        bills: [...state.bills, ...newBills],
        isLoading: false,
        page: state.page + 1,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch bills: ${e.toString()}',
      );
      debugPrint(state.error);
    }
  }

  Future<void> fetchBillDetails(String billId) async {
    try {
      state = state.clearError();
      state = state.copyWith(isLoading: true);
      
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Try to find the bill in our current list
      final bill = state.bills.firstWhere(
        (bill) => bill.id == billId,
        orElse: () => _generateDetailedMockBill(billId),
      );
      
      state = state.copyWith(
        selectedBill: bill,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch bill details: ${e.toString()}',
      );
      debugPrint(state.error);
    }
  }

  Future<void> searchBills(String query) async {
    try {
      state = state.clearError();
      state = state.copyWith(
        isLoading: true,
        bills: [], // Clear existing bills
        page: 1,
      );
      
      // Mock API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate some mock bills data with titles containing the query
      final searchResults = _generateMockBills(1, 10)
        .where((bill) => bill.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
      
      state = state.copyWith(
        bills: searchResults,
        isLoading: false,
        hasMore: false, // No pagination for search results in this example
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to search bills: ${e.toString()}',
      );
      debugPrint(state.error);
    }
  }

  // Helper method to generate mock bills
  List<Bill> _generateMockBills(int page, int count) {
    final bills = <Bill>[];
    final startIndex = (page - 1) * count;
    
    for (var i = 0; i < count; i++) {
      final id = 'bill_${startIndex + i}';
      bills.add(
        Bill(
          id: id,
          number: 'H.R.${1000 + startIndex + i}',
          title: 'Bill to ${_getRandomBillTitle()}',
          summary: 'This bill aims to address issues related to ${_getRandomBillTitle()}.',
          fullText: 'Full text of bill ${id}...',
          introducedDate: DateTime.now().subtract(Duration(days: (startIndex + i) % 30 + 1)),
          lastActionDate: DateTime.now().subtract(Duration(days: (startIndex + i) % 15)),
          sponsors: ['Sen. John Doe', 'Rep. Jane Smith'],
          cosponsors: ['Rep. Bob Johnson', 'Sen. Alice Williams'],
          committees: ['Committee on ${_getRandomCommittee()}'],
          relatedBills: ['H.R.${1000 + (startIndex + i + 10) % 100}'],
          status: _getRandomStatus(),
          voteData: null,
          aiGeneratedSummary: 'This bill proposes changes to ${_getRandomBillTitle()}. It would impact several areas including funding, regulation, and oversight.',
        ),
      );
    }
    
    return bills;
  }
  
  // Helper method to generate a detailed mock bill
  Bill _generateDetailedMockBill(String id) {
    return Bill(
      id: id,
      number: 'H.R.${1000 + int.parse(id.split('_')[1])}',
      title: 'Bill to ${_getRandomBillTitle()}',
      summary: 'This bill aims to address issues related to ${_getRandomBillTitle()}.',
      fullText: 'Full detailed text of bill ${id}...',
      introducedDate: DateTime.now().subtract(const Duration(days: 45)),
      lastActionDate: DateTime.now().subtract(const Duration(days: 5)),
      sponsors: ['Sen. John Doe', 'Rep. Jane Smith'],
      cosponsors: ['Rep. Bob Johnson', 'Sen. Alice Williams', 'Rep. Michael Brown'],
      committees: ['Committee on ${_getRandomCommittee()}', 'Committee on ${_getRandomCommittee()}'],
      relatedBills: ['H.R.1005', 'H.R.1050', 'S.442'],
      status: _getRandomStatus(),
      voteData: {
        'houseVotes': {'yea': 230, 'nay': 198, 'present': 5, 'absent': 2},
        'senateVotes': {'yea': 52, 'nay': 46, 'present': 1, 'absent': 1},
      },
      aiGeneratedSummary: 'This bill proposes comprehensive changes to ${_getRandomBillTitle()}. It would impact several areas including funding, regulation, and oversight. The bill includes provisions for increased transparency and accountability in the sector. It also establishes new guidelines for implementation and enforcement.',
    );
  }
  
  // Helper method to get a random bill title
  String _getRandomBillTitle() {
    final titles = [
      'improve healthcare accessibility',
      'reform education funding',
      'address climate change',
      'strengthen national security',
      'support small businesses',
      'enhance infrastructure',
      'protect consumer rights',
      'reform immigration policies',
      'regulate financial institutions',
      'expand broadband access',
    ];
    
    return titles[DateTime.now().millisecondsSinceEpoch % titles.length];
  }
  
  // Helper method to get a random committee name
  String _getRandomCommittee() {
    final committees = [
      'Health and Human Services',
      'Education and Labor',
      'Energy and Commerce',
      'Homeland Security',
      'Small Business',
      'Transportation and Infrastructure',
      'Financial Services',
      'Judiciary',
      'Agriculture',
      'Veterans Affairs',
    ];
    
    return committees[DateTime.now().millisecondsSinceEpoch % committees.length];
  }
  
  // Helper method to get a random status
  String _getRandomStatus() {
    final statuses = [
      'Introduced',
      'Referred to Committee',
      'Reported by Committee',
      'Passed House',
      'Passed Senate',
      'Sent to President',
      'Signed into Law',
      'Vetoed',
    ];
    
    return statuses[DateTime.now().millisecondsSinceEpoch % statuses.length];
  }
}

// Provider for bills state
final billsProvider = StateNotifierProvider<BillsNotifier, BillsState>((ref) {
  return BillsNotifier();
}); 