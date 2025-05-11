import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/politician.dart';

class PoliticiansProvider with ChangeNotifier {
  List<Politician> _politicians = [];
  Politician? _selectedPolitician;
  bool _isLoading = false;
  String? _error;
  Map<String, List<Politician>> _filteredPoliticians = {};
  
  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  bool _hasMoreItems = true;
  
  // Search and filter
  String _searchQuery = '';
  String _selectedParty = 'all';
  String _selectedState = 'all';
  String _selectedChamber = 'all';
  String _sortBy = 'alphabetical';
  
  List<Politician> get politicians => _politicians;
  Politician? get selectedPolitician => _selectedPolitician;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreItems => _hasMoreItems;
  
  String get searchQuery => _searchQuery;
  String get selectedParty => _selectedParty;
  String get selectedState => _selectedState;
  String get selectedChamber => _selectedChamber;
  String get sortBy => _sortBy;
  
  // Mock data API URLs (normally these would point to a real API)
  final String _baseUrl = 'https://api.example.com';
  
  // Initialize the provider and load initial data
  Future<void> initialize() async {
    await fetchPoliticians();
  }
  
  // Fetch politicians with pagination and filtering
  Future<void> fetchPoliticians({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasMoreItems = true;
        _politicians = [];
      }
      
      if (!_hasMoreItems) return;
      
      _setLoading(true);
      _clearError();
      
      // In a real app, this would be an API call with query parameters
      // Here we're simulating the API with a delay and mock data
      await Future.delayed(const Duration(seconds: 1));
      
      final List<Politician> newPoliticians = _generateMockPoliticians();
      
      // Apply filters and search to mock data
      final filteredNewPoliticians = _applyFiltersToMockData(newPoliticians);
      
      // If no more items returned, update hasMoreItems
      if (filteredNewPoliticians.isEmpty) {
        _hasMoreItems = false;
      } else {
        _politicians.addAll(filteredNewPoliticians);
        _currentPage++;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch politicians: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  // Get politician details by ID
  Future<Politician?> getPoliticianDetails(String politicianId) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Check if we already have this politician with complete details
      final existingPolitician = _politicians.firstWhere(
        (politician) => politician.id == politicianId,
        orElse: () => {} as Politician,
      );
      
      if (existingPolitician is Politician) {
        _selectedPolitician = existingPolitician;
        notifyListeners();
        return existingPolitician;
      }
      
      // In a real app, this would be an API call to get detailed politician information
      await Future.delayed(const Duration(seconds: 1));
      
      // For mock data, create a detailed politician
      final Politician mockPolitician = _createDetailedMockPolitician(politicianId);
      
      _selectedPolitician = mockPolitician;
      
      // Add to politicians list if not already there
      if (!_politicians.any((politician) => politician.id == mockPolitician.id)) {
        _politicians.add(mockPolitician);
      }
      
      notifyListeners();
      return mockPolitician;
    } catch (e) {
      _error = 'Failed to get politician details: ${e.toString()}';
      debugPrint(_error);
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Search politicians
  Future<void> searchPoliticians(String query) async {
    _searchQuery = query;
    await fetchPoliticians(refresh: true);
  }
  
  // Apply filters
  Future<void> applyFilters({
    String? party,
    String? state,
    String? chamber,
    String? sortOrder,
  }) async {
    if (party != null) _selectedParty = party;
    if (state != null) _selectedState = state;
    if (chamber != null) _selectedChamber = chamber;
    if (sortOrder != null) _sortBy = sortOrder;
    
    await fetchPoliticians(refresh: true);
  }
  
  // Reset filters
  Future<void> resetFilters() async {
    _searchQuery = '';
    _selectedParty = 'all';
    _selectedState = 'all';
    _selectedChamber = 'all';
    _sortBy = 'alphabetical';
    
    await fetchPoliticians(refresh: true);
  }
  
  // Get politicians by party
  List<Politician> getPoliticiansByParty(String party) {
    if (_filteredPoliticians.containsKey('party_$party')) {
      return _filteredPoliticians['party_$party']!;
    }
    
    final partyPoliticians = _politicians.where((politician) => 
      politician.party == party
    ).toList();
    
    _filteredPoliticians['party_$party'] = partyPoliticians;
    return partyPoliticians;
  }
  
  // Get politicians by state
  List<Politician> getPoliticiansByState(String state) {
    if (_filteredPoliticians.containsKey('state_$state')) {
      return _filteredPoliticians['state_$state']!;
    }
    
    final statePoliticians = _politicians.where((politician) => 
      politician.state == state
    ).toList();
    
    _filteredPoliticians['state_$state'] = statePoliticians;
    return statePoliticians;
  }
  
  // Get politicians by chamber
  List<Politician> getPoliticiansByChamber(String chamber) {
    if (_filteredPoliticians.containsKey('chamber_$chamber')) {
      return _filteredPoliticians['chamber_$chamber']!;
    }
    
    final chamberPoliticians = _politicians.where((politician) => 
      politician.chamber == chamber
    ).toList();
    
    _filteredPoliticians['chamber_$chamber'] = chamberPoliticians;
    return chamberPoliticians;
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
  List<Politician> _generateMockPoliticians() {
    // Simulating pagination
    final int startIndex = (_currentPage - 1) * _itemsPerPage;
    final int endIndex = startIndex + _itemsPerPage;
    
    // Create 100 mock politicians in total
    final int totalPoliticians = 100;
    
    // If we've reached the end, return empty array
    if (startIndex >= totalPoliticians) {
      return [];
    }
    
    // Calculate actual end index (in case we're at the last page)
    final int actualEndIndex = endIndex > totalPoliticians ? totalPoliticians : endIndex;
    
    List<Politician> mockPoliticians = [];
    
    final List<String> firstNames = ['James', 'John', 'Robert', 'Michael', 'William', 'David', 'Mary', 'Patricia', 'Jennifer', 'Linda', 'Elizabeth', 'Barbara'];
    final List<String> lastNames = ['Smith', 'Johnson', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor', 'Anderson', 'Thomas'];
    final List<String> states = ['AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY'];
    final List<String> parties = ['Democratic', 'Republican', 'Independent'];
    final List<String> chambers = ['Senate', 'House'];
    
    for (int i = startIndex; i < actualEndIndex; i++) {
      final String id = 'politician_${i + 1}';
      final String firstName = firstNames[i % firstNames.length];
      final String lastName = lastNames[i % lastNames.length];
      final String state = states[i % states.length];
      final String party = i % 10 == 0 ? 'Independent' : (i % 2 == 0 ? 'Democratic' : 'Republican');
      final String chamber = i % 5 == 0 ? 'Senate' : 'House';
      final String district = chamber == 'Senate' ? '' : '${(i % 20) + 1}';
      
      final Politician politician = Politician(
        id: id,
        firstName: firstName,
        lastName: lastName,
        fullName: '$firstName $lastName',
        party: party,
        state: state,
        district: district,
        chamber: chamber,
        title: chamber == 'Senate' ? 'Senator' : 'Representative',
        phone: '(202) 555-${1000 + i}',
        office: '${100 + i} Senate/House Office Building',
        website: 'https://www.${lastName.toLowerCase()}.senate/house.gov',
        twitter: '@${firstName.toLowerCase()}${lastName.toLowerCase()}',
        facebook: 'facebook.com/${firstName.toLowerCase()}${lastName.toLowerCase()}',
        youtube: 'youtube.com/${firstName.toLowerCase()}${lastName.toLowerCase()}',
        photoUrl: 'https://randomuser.me/api/portraits/${i % 2 == 0 ? 'men' : 'women'}/${i % 70}.jpg',
        nextElection: '${2024 + (i % 6)}',
        birthdate: '${1940 + (i % 40)}-${(i % 12) + 1}-${(i % 28) + 1}',
        seniority: i % 30 + 1,
        missedVotesPct: (i % 10) / 10,
        votesWithPartyPct: 80 + (i % 20),
        recentVotes: List.generate(5, (index) => {'bill_id': 'bill_${index + 1}', 'position': index % 2 == 0 ? 'Yes' : 'No'}),
        committees: List.generate(i % 5 + 1, (index) => 'Committee on ${['Finance', 'Energy', 'Agriculture', 'Education', 'Health', 'Foreign Relations', 'Armed Services'][index % 7]}'),
        sponsoredBills: List.generate(i % 10 + 1, (index) => 'bill_${i * 10 + index + 1}'),
      );
      
      mockPoliticians.add(politician);
    }
    
    return mockPoliticians;
  }
  
  List<Politician> _applyFiltersToMockData(List<Politician> politicians) {
    // Apply search query
    if (_searchQuery.isNotEmpty) {
      politicians = politicians.where((politician) => 
        politician.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        politician.state.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (politician.district.isNotEmpty && politician.district.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }
    
    // Apply party filter
    if (_selectedParty != 'all') {
      politicians = politicians.where((politician) => politician.party == _selectedParty).toList();
    }
    
    // Apply state filter
    if (_selectedState != 'all') {
      politicians = politicians.where((politician) => politician.state == _selectedState).toList();
    }
    
    // Apply chamber filter
    if (_selectedChamber != 'all') {
      politicians = politicians.where((politician) => politician.chamber == _selectedChamber).toList();
    }
    
    // Apply sorting
    if (_sortBy == 'alphabetical') {
      politicians.sort((a, b) => a.lastName.compareTo(b.lastName));
    } else if (_sortBy == 'seniority') {
      politicians.sort((a, b) => b.seniority.compareTo(a.seniority));
    } else if (_sortBy == 'state') {
      politicians.sort((a, b) => a.state.compareTo(b.state));
    }
    
    return politicians;
  }
  
  Politician _createDetailedMockPolitician(String politicianId) {
    // Extract politician number from the ID
    final politicianNumber = int.parse(politicianId.split('_')[1]);
    
    final List<String> firstNames = ['James', 'John', 'Robert', 'Michael', 'William', 'David', 'Mary', 'Patricia', 'Jennifer', 'Linda', 'Elizabeth', 'Barbara'];
    final List<String> lastNames = ['Smith', 'Johnson', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor', 'Anderson', 'Thomas'];
    final List<String> states = ['AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 'HI', 'ID'];
    final List<String> parties = ['Democratic', 'Republican', 'Independent'];
    final List<String> chambers = ['Senate', 'House'];
    
    final String firstName = firstNames[politicianNumber % firstNames.length];
    final String lastName = lastNames[politicianNumber % lastNames.length];
    final String state = states[politicianNumber % states.length];
    final String party = politicianNumber % 10 == 0 ? 'Independent' : (politicianNumber % 2 == 0 ? 'Democratic' : 'Republican');
    final String chamber = politicianNumber % 5 == 0 ? 'Senate' : 'House';
    final String district = chamber == 'Senate' ? '' : '${(politicianNumber % 20) + 1}';
    
    return Politician(
      id: politicianId,
      firstName: firstName,
      lastName: lastName,
      fullName: '$firstName $lastName',
      party: party,
      state: state,
      district: district,
      chamber: chamber,
      title: chamber == 'Senate' ? 'Senator' : 'Representative',
      phone: '(202) 555-${1000 + politicianNumber}',
      office: '${100 + politicianNumber} ${chamber == 'Senate' ? 'Senate' : 'House'} Office Building',
      website: 'https://www.${lastName.toLowerCase()}.${chamber.toLowerCase()}.gov',
      twitter: '@${firstName.toLowerCase()}${lastName.toLowerCase()}',
      facebook: 'facebook.com/${firstName.toLowerCase()}${lastName.toLowerCase()}',
      youtube: 'youtube.com/${firstName.toLowerCase()}${lastName.toLowerCase()}',
      photoUrl: 'https://randomuser.me/api/portraits/${politicianNumber % 2 == 0 ? 'men' : 'women'}/${politicianNumber % 70}.jpg',
      nextElection: '${2024 + (politicianNumber % 6)}',
      birthdate: '${1940 + (politicianNumber % 40)}-${(politicianNumber % 12) + 1}-${(politicianNumber % 28) + 1}',
      seniority: politicianNumber % 30 + 1,
      missedVotesPct: (politicianNumber % 10) / 10,
      votesWithPartyPct: 80 + (politicianNumber % 20),
      recentVotes: List.generate(20, (index) => {
        'bill_id': 'bill_${index + 1}',
        'bill_title': 'Bill to Reform Act of 2023 (H.R.${1000 + index})',
        'position': index % 2 == 0 ? 'Yes' : 'No',
        'date': DateTime.now().subtract(Duration(days: index * 7)).toIso8601String(),
      }),
      committees: List.generate(politicianNumber % 5 + 1, (index) => 
        'Committee on ${['Finance', 'Energy', 'Agriculture', 'Education', 'Health', 'Foreign Relations', 'Armed Services'][index % 7]}'
      ),
      sponsoredBills: List.generate(politicianNumber % 10 + 1, (index) => 
        'bill_${politicianNumber * 10 + index + 1}'
      ),
    );
  }
} 