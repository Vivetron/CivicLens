import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/bill.dart';

class BillsProvider with ChangeNotifier {
  List<Bill> _bills = [];
  Bill? _selectedBill;
  bool _isLoading = false;
  String? _error;
  Map<String, List<Bill>> _filteredBills = {};
  
  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  bool _hasMoreItems = true;
  
  // Search and filter
  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _selectedChamber = 'all';
  String _selectedTopic = 'all';
  String _selectedParty = 'all';
  String _sortBy = 'latest';
  
  List<Bill> get bills => _bills;
  Bill? get selectedBill => _selectedBill;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreItems => _hasMoreItems;
  
  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;
  String get selectedChamber => _selectedChamber;
  String get selectedTopic => _selectedTopic;
  String get selectedParty => _selectedParty;
  String get sortBy => _sortBy;
  
  // Mock data API URLs (normally these would point to a real API)
  final String _baseUrl = 'https://api.example.com';
  
  // Initialize the provider and load initial data
  Future<void> initialize() async {
    await fetchBills();
  }
  
  // Fetch bills with pagination and filtering
  Future<void> fetchBills({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasMoreItems = true;
        _bills = [];
      }
      
      if (!_hasMoreItems) return;
      
      _setLoading(true);
      _clearError();
      
      // In a real app, this would be an API call with query parameters
      // Here we're simulating the API with a delay and mock data
      await Future.delayed(const Duration(seconds: 1));
      
      final List<Bill> newBills = _generateMockBills();
      
      // Apply filters and search to mock data
      final filteredNewBills = _applyFiltersToMockData(newBills);
      
      // If no more items returned, update hasMoreItems
      if (filteredNewBills.isEmpty) {
        _hasMoreItems = false;
      } else {
        _bills.addAll(filteredNewBills);
        _currentPage++;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch bills: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  // Get bill details by ID
  Future<Bill?> getBillDetails(String billId) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Check if we already have this bill with complete details
      final existingBill = _bills.firstWhere(
        (bill) => bill.id == billId,
        orElse: () => {} as Bill,
      );
      
      if (existingBill is Bill) {
        _selectedBill = existingBill;
        notifyListeners();
        return existingBill;
      }
      
      // In a real app, this would be an API call to get detailed bill information
      await Future.delayed(const Duration(seconds: 1));
      
      // For mock data, create a detailed bill
      final Bill mockBill = _createDetailedMockBill(billId);
      
      _selectedBill = mockBill;
      
      // Add to bills list if not already there
      if (!_bills.any((bill) => bill.id == mockBill.id)) {
        _bills.add(mockBill);
      }
      
      notifyListeners();
      return mockBill;
    } catch (e) {
      _error = 'Failed to get bill details: ${e.toString()}';
      debugPrint(_error);
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Search bills
  Future<void> searchBills(String query) async {
    _searchQuery = query;
    await fetchBills(refresh: true);
  }
  
  // Apply filters
  Future<void> applyFilters({
    String? status,
    String? chamber,
    String? topic,
    String? party,
    String? sortOrder,
  }) async {
    if (status != null) _selectedStatus = status;
    if (chamber != null) _selectedChamber = chamber;
    if (topic != null) _selectedTopic = topic;
    if (party != null) _selectedParty = party;
    if (sortOrder != null) _sortBy = sortOrder;
    
    await fetchBills(refresh: true);
  }
  
  // Reset filters
  Future<void> resetFilters() async {
    _searchQuery = '';
    _selectedStatus = 'all';
    _selectedChamber = 'all';
    _selectedTopic = 'all';
    _selectedParty = 'all';
    _sortBy = 'latest';
    
    await fetchBills(refresh: true);
  }
  
  // Get bills by topic
  List<Bill> getBillsByTopic(String topic) {
    if (_filteredBills.containsKey(topic)) {
      return _filteredBills[topic]!;
    }
    
    final topicBills = _bills.where((bill) => 
      bill.tags.contains(topic) || bill.policyArea == topic
    ).toList();
    
    _filteredBills[topic] = topicBills;
    return topicBills;
  }
  
  // Get trending bills (most discussed/viewed)
  List<Bill> getTrendingBills() {
    // Normally this would come from an API with analytics
    // For mock data, just return the first few bills
    final trendingBills = _bills.take(5).toList();
    return trendingBills;
  }
  
  // Get recent bills
  List<Bill> getRecentBills() {
    final sortedBills = List<Bill>.from(_bills);
    sortedBills.sort((a, b) => 
      DateTime.parse(b.introducedDate).compareTo(DateTime.parse(a.introducedDate))
    );
    return sortedBills.take(10).toList();
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
  
  // Mock data generation
  List<Bill> _generateMockBills() {
    // Simulating pagination
    final int startIndex = (_currentPage - 1) * _itemsPerPage;
    final int endIndex = startIndex + _itemsPerPage;
    
    // Create 100 mock bills in total
    final int totalBills = 100;
    
    // If we've reached the end, return empty array
    if (startIndex >= totalBills) {
      return [];
    }
    
    // Calculate actual end index (in case we're at the last page)
    final int actualEndIndex = endIndex > totalBills ? totalBills : endIndex;
    
    List<Bill> mockBills = [];
    
    for (int i = startIndex; i < actualEndIndex; i++) {
      final String id = 'bill_${i + 1}';
      final String number = 'H.R.${1000 + i}';
      
      // Create bill statuses in a cycle
      final List<String> statuses = ['introduced', 'passed_house', 'passed_senate', 'enacted', 'failed'];
      final String status = statuses[i % statuses.length];
      
      // Create bill topics in a cycle
      final List<String> topics = ['Healthcare', 'Economy', 'Environment', 'Defense', 'Education', 'Immigration', 'Technology', 'Infrastructure'];
      final String topic = topics[i % topics.length];
      
      // Create bill parties in a cycle
      final List<String> parties = ['Democratic', 'Republican'];
      final String party = parties[i % parties.length];
      
      final Bill bill = Bill(
        id: id,
        title: 'Bill to ${topic} Reform Act of 2023',
        aiSummary: 'This bill aims to reform aspects of $topic by implementing new regulations and funding for related programs.',
        aiHeadline: '${topic} Reform Bill Introduced by ${party} Lawmakers',
        number: number,
        congress: '118',
        billType: 'hr',
        sponsor: 'Rep. ${party == 'Democratic' ? 'John Smith' : 'Jane Doe'}',
        sponsorId: 'sponsor_${i % 10 + 1}',
        sponsorParty: party,
        sponsorState: ['CA', 'NY', 'TX', 'FL', 'IL'][i % 5],
        introducedDate: DateTime.now().subtract(Duration(days: i * 2)).toIso8601String(),
        cosponsors: List.generate(i % 10 + 1, (index) => 'cosponsor_${index + 1}'),
        latestAction: 'Referred to the Committee on ${topic}',
        latestActionDate: DateTime.now().subtract(Duration(days: i)).toIso8601String(),
        url: 'https://www.congress.gov/bill/118th-congress/house-bill/${1000 + i}',
        billStatus: status,
        policyArea: topic,
        voteBreakdown: {
          'democratic': {'yes': 220 - (i % 40), 'no': i % 40, 'not_voting': i % 5},
          'republican': {'yes': i % 30, 'no': 212 - (i % 30), 'not_voting': i % 5},
          'independent': {'yes': i % 2, 'no': 3 - (i % 2), 'not_voting': 0},
        },
        tags: [topic, '118th', status.replaceAll('_', ' ')],
      );
      
      mockBills.add(bill);
    }
    
    return mockBills;
  }
  
  List<Bill> _applyFiltersToMockData(List<Bill> bills) {
    // Apply search query
    if (_searchQuery.isNotEmpty) {
      bills = bills.where((bill) => 
        bill.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        bill.number.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        bill.sponsor.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Apply status filter
    if (_selectedStatus != 'all') {
      bills = bills.where((bill) => bill.billStatus == _selectedStatus).toList();
    }
    
    // Apply chamber filter
    if (_selectedChamber != 'all') {
      bills = bills.where((bill) => 
        _selectedChamber == 'house' ? bill.billType.contains('h') : bill.billType.contains('s')
      ).toList();
    }
    
    // Apply topic filter
    if (_selectedTopic != 'all') {
      bills = bills.where((bill) => 
        bill.policyArea == _selectedTopic || bill.tags.contains(_selectedTopic)
      ).toList();
    }
    
    // Apply party filter
    if (_selectedParty != 'all') {
      bills = bills.where((bill) => bill.sponsorParty == _selectedParty).toList();
    }
    
    // Apply sorting
    if (_sortBy == 'latest') {
      bills.sort((a, b) => 
        DateTime.parse(b.introducedDate).compareTo(DateTime.parse(a.introducedDate))
      );
    } else if (_sortBy == 'oldest') {
      bills.sort((a, b) => 
        DateTime.parse(a.introducedDate).compareTo(DateTime.parse(b.introducedDate))
      );
    }
    
    return bills;
  }
  
  Bill _createDetailedMockBill(String billId) {
    // Extract bill number from the ID
    final billNumber = int.parse(billId.split('_')[1]);
    
    final List<String> topics = ['Healthcare', 'Economy', 'Environment', 'Defense', 'Education', 'Immigration', 'Technology', 'Infrastructure'];
    final List<String> statuses = ['introduced', 'passed_house', 'passed_senate', 'enacted', 'failed'];
    final List<String> parties = ['Democratic', 'Republican'];
    
    final String topic = topics[billNumber % topics.length];
    final String status = statuses[billNumber % statuses.length];
    final String party = parties[billNumber % parties.length];
    
    return Bill(
      id: billId,
      title: 'Bill to ${topic} Reform Act of 2023',
      aiSummary: '''
This bill proposes comprehensive reforms to the ${topic.toLowerCase()} sector. Key provisions include:

1. Establishing new regulatory frameworks for ${topic.toLowerCase()} providers and industries
2. Allocating \$500 million in funding for research and development
3. Creating tax incentives for businesses that adopt sustainable ${topic.toLowerCase()} practices
4. Forming an oversight committee to monitor implementation and compliance
5. Setting national standards for ${topic.toLowerCase()} quality and access

The bill aims to address growing concerns about ${topic.toLowerCase()} affordability and accessibility while promoting innovation and economic growth in the sector.
      ''',
      aiHeadline: '${topic} Reform Bill Introduced by ${party} Lawmakers',
      number: 'H.R.${1000 + billNumber}',
      congress: '118',
      billType: 'hr',
      sponsor: 'Rep. ${party == 'Democratic' ? 'John Smith' : 'Jane Doe'}',
      sponsorId: 'sponsor_${billNumber % 10 + 1}',
      sponsorParty: party,
      sponsorState: ['CA', 'NY', 'TX', 'FL', 'IL'][billNumber % 5],
      introducedDate: DateTime.now().subtract(Duration(days: billNumber * 2)).toIso8601String(),
      cosponsors: List.generate(billNumber % 10 + 1, (index) => 'cosponsor_${index + 1}'),
      latestAction: 'Referred to the Committee on ${topic}',
      latestActionDate: DateTime.now().subtract(Duration(days: billNumber)).toIso8601String(),
      url: 'https://www.congress.gov/bill/118th-congress/house-bill/${1000 + billNumber}',
      billStatus: status,
      policyArea: topic,
      voteBreakdown: {
        'democratic': {'yes': 220 - (billNumber % 40), 'no': billNumber % 40, 'not_voting': billNumber % 5},
        'republican': {'yes': billNumber % 30, 'no': 212 - (billNumber % 30), 'not_voting': billNumber % 5},
        'independent': {'yes': billNumber % 2, 'no': 3 - (billNumber % 2), 'not_voting': 0},
      },
      tags: [topic, '118th', status.replaceAll('_', ' ')],
    );
  }
} 