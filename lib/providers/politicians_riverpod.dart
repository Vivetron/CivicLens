import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Politician {
  final String id;
  final String name;
  final String party;
  final String state;
  final String chamber;
  final String? photoUrl;
  final String title;
  final String? district;
  final String? biography;
  final String? website;
  final String? twitterHandle;
  final Map<String, dynamic>? contactInfo;
  final Map<String, dynamic>? votingRecord;
  final List<String>? committees;

  const Politician({
    required this.id,
    required this.name,
    required this.party,
    required this.state,
    required this.chamber,
    this.photoUrl,
    required this.title,
    this.district,
    this.biography,
    this.website,
    this.twitterHandle,
    this.contactInfo,
    this.votingRecord,
    this.committees,
  });
}

class PoliticiansState {
  final List<Politician> politicians;
  final Politician? selectedPolitician;
  final bool isLoading;
  final String? error;
  final int page;
  final bool hasMore;
  final String? filter;

  const PoliticiansState({
    this.politicians = const [],
    this.selectedPolitician,
    this.isLoading = false,
    this.error,
    this.page = 1,
    this.hasMore = true,
    this.filter,
  });

  PoliticiansState copyWith({
    List<Politician>? politicians,
    Politician? selectedPolitician,
    bool? isLoading,
    String? error,
    int? page,
    bool? hasMore,
    String? filter,
  }) {
    return PoliticiansState(
      politicians: politicians ?? this.politicians,
      selectedPolitician: selectedPolitician ?? this.selectedPolitician,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      filter: filter ?? this.filter,
    );
  }

  PoliticiansState clearError() {
    return copyWith(error: null);
  }
}

class PoliticiansNotifier extends StateNotifier<PoliticiansState> {
  PoliticiansNotifier() : super(const PoliticiansState()) {
    initialize();
  }

  Future<void> initialize() async {
    await fetchPoliticians();
  }

  Future<void> fetchPoliticians({bool refresh = false, String? filter}) async {
    try {
      if (refresh) {
        state = state.copyWith(
          isLoading: true,
          page: 1,
          hasMore: true,
          politicians: [],
          filter: filter ?? state.filter,
        );
      } else {
        state = state.copyWith(isLoading: true);
        if (!state.hasMore) return;
      }

      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      // Generate mock politicians data
      final newPoliticians = _generateMockPoliticians(state.page, 15, state.filter);

      // Apply filter if needed
      final hasMore = newPoliticians.length >= 15;

      state = state.copyWith(
        politicians: [...state.politicians, ...newPoliticians],
        isLoading: false,
        page: state.page + 1,
        hasMore: hasMore,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch politicians: ${e.toString()}',
      );
      debugPrint(state.error);
    }
  }

  Future<void> fetchPoliticianDetails(String id) async {
    try {
      state = state.clearError();
      state = state.copyWith(isLoading: true);

      // Mock API call
      await Future.delayed(const Duration(seconds: 1));

      // Try to find the politician in our current list
      final politician = state.politicians.firstWhere(
        (politician) => politician.id == id,
        orElse: () => _generateDetailedMockPolitician(id),
      );

      state = state.copyWith(
        selectedPolitician: politician,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch politician details: ${e.toString()}',
      );
      debugPrint(state.error);
    }
  }

  void applyFilter(String? filter) {
    fetchPoliticians(refresh: true, filter: filter);
  }

  // Helper method to generate mock politicians
  List<Politician> _generateMockPoliticians(int page, int count, String? filter) {
    final politicians = <Politician>[];
    final startIndex = (page - 1) * count;

    for (var i = 0; i < count; i++) {
      final index = startIndex + i;
      final id = 'politician_$index';
      final party = _getRandomParty(index);
      final chamber = _getRandomChamber(index);
      final state = _getRandomState(index);
      final name = _getRandomName(index);
      
      // Apply filter if present
      if (filter != null && filter.isNotEmpty) {
        final filterLower = filter.toLowerCase();
        // Skip if doesn't match filter
        if (!name.toLowerCase().contains(filterLower) &&
            !state.toLowerCase().contains(filterLower) &&
            !party.toLowerCase().contains(filterLower)) {
          continue;
        }
      }

      politicians.add(
        Politician(
          id: id,
          name: name,
          party: party,
          state: state,
          chamber: chamber,
          photoUrl: 'https://via.placeholder.com/150',
          title: chamber == 'senate' ? 'Senator' : 'Representative',
          district: chamber == 'house' ? '${index % 30 + 1}' : null,
        ),
      );
    }

    return politicians;
  }

  // Helper method to generate a detailed mock politician
  Politician _generateDetailedMockPolitician(String id) {
    final index = int.tryParse(id.split('_').last) ?? 0;
    final party = _getRandomParty(index);
    final chamber = _getRandomChamber(index);
    final state = _getRandomState(index);
    final name = _getRandomName(index);

    return Politician(
      id: id,
      name: name,
      party: party,
      state: state,
      chamber: chamber,
      photoUrl: 'https://via.placeholder.com/150',
      title: chamber == 'senate' ? 'Senator' : 'Representative',
      district: chamber == 'house' ? '${index % 30 + 1}' : null,
      biography: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed euismod, nisl vel ultricies lacinia, nisl nisl aliquet nisl, eget aliquet nisl nisl eget nisl. Sed euismod, nisl vel ultricies lacinia, nisl nisl aliquet nisl, eget aliquet nisl nisl eget nisl.',
      website: 'https://www.senate.gov/senators/example',
      twitterHandle: '@senator_$index',
      contactInfo: {
        'phone': '(202) 224-${1000 + index}',
        'office': '${100 + index} Senate Office Building, Washington, DC 20510',
        'email': 'senator$index@senate.gov',
      },
      votingRecord: {
        'total': 432,
        'missed': 12,
        'present': 420,
        'withParty': 380,
        'againstParty': 40,
      },
      committees: [
        'Committee on ${_getRandomCommittee()}',
        'Committee on ${_getRandomCommittee()}',
        'Subcommittee on ${_getRandomCommittee()}',
      ],
    );
  }

  String _getRandomParty(int index) {
    final parties = ['Democrat', 'Republican', 'Independent'];
    return parties[index % parties.length];
  }

  String _getRandomChamber(int index) {
    return index % 3 == 0 ? 'senate' : 'house';
  }

  String _getRandomState(int index) {
    final states = [
      'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California',
      'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia',
      'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa',
      'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland',
      'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri',
      'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey',
      'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio',
      'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina',
      'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont',
      'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'
    ];
    return states[index % states.length];
  }

  String _getRandomName(int index) {
    final firstNames = ['John', 'Jane', 'Michael', 'Sarah', 'Robert', 'Emily', 'David', 'Lisa', 'Daniel', 'Marie'];
    final lastNames = ['Smith', 'Johnson', 'Brown', 'Williams', 'Jones', 'Miller', 'Davis', 'Garcia', 'Rodriguez', 'Wilson'];
    
    final firstName = firstNames[index % firstNames.length];
    final lastName = lastNames[(index + 3) % lastNames.length];
    
    return '$firstName $lastName';
  }

  String _getRandomCommittee() {
    final committees = [
      'Agriculture, Nutrition, and Forestry',
      'Appropriations',
      'Armed Services',
      'Banking, Housing, and Urban Affairs',
      'Budget',
      'Commerce, Science, and Transportation',
      'Energy and Natural Resources',
      'Environment and Public Works',
      'Finance',
      'Foreign Relations',
      'Health, Education, Labor, and Pensions',
      'Homeland Security and Governmental Affairs',
      'Judiciary',
      'Rules and Administration',
      'Small Business and Entrepreneurship',
      'Veterans\' Affairs',
    ];
    
    return committees[DateTime.now().millisecondsSinceEpoch % committees.length];
  }
}

final politiciansProvider = StateNotifierProvider<PoliticiansNotifier, PoliticiansState>((ref) {
  return PoliticiansNotifier();
}); 