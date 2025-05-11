class Politician {
  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String party;
  final String state;
  final String district;
  final String chamber;
  final String title;
  final String phone;
  final String office;
  final String website;
  final String twitter;
  final String facebook;
  final String youtube;
  final String photoUrl;
  final String nextElection;
  final String birthdate;
  final int seniority;
  final double missedVotesPct;
  final double votesWithPartyPct;
  final List<dynamic> recentVotes;
  final List<String> committees;
  final List<String> sponsoredBills;

  Politician({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.party,
    required this.state,
    required this.district,
    required this.chamber,
    required this.title,
    required this.phone,
    required this.office,
    required this.website,
    required this.twitter,
    required this.facebook,
    required this.youtube,
    required this.photoUrl,
    required this.nextElection,
    required this.birthdate,
    required this.seniority,
    required this.missedVotesPct,
    required this.votesWithPartyPct,
    required this.recentVotes,
    required this.committees,
    required this.sponsoredBills,
  });

  factory Politician.fromJson(Map<String, dynamic> json) {
    return Politician(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}',
      party: json['party'] ?? '',
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      chamber: json['chamber'] ?? '',
      title: json['title'] ?? '',
      phone: json['phone'] ?? '',
      office: json['office'] ?? '',
      website: json['website'] ?? '',
      twitter: json['twitter'] ?? '',
      facebook: json['facebook'] ?? '',
      youtube: json['youtube'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      nextElection: json['next_election'] ?? '',
      birthdate: json['birthdate'] ?? '',
      seniority: json['seniority'] ?? 0,
      missedVotesPct: (json['missed_votes_pct'] ?? 0).toDouble(),
      votesWithPartyPct: (json['votes_with_party_pct'] ?? 0).toDouble(),
      recentVotes: List<dynamic>.from(json['recent_votes'] ?? []),
      committees: List<String>.from(json['committees'] ?? []),
      sponsoredBills: List<String>.from(json['sponsored_bills'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'party': party,
      'state': state,
      'district': district,
      'chamber': chamber,
      'title': title,
      'phone': phone,
      'office': office,
      'website': website,
      'twitter': twitter,
      'facebook': facebook,
      'youtube': youtube,
      'photo_url': photoUrl,
      'next_election': nextElection,
      'birthdate': birthdate,
      'seniority': seniority,
      'missed_votes_pct': missedVotesPct,
      'votes_with_party_pct': votesWithPartyPct,
      'recent_votes': recentVotes,
      'committees': committees,
      'sponsored_bills': sponsoredBills,
    };
  }

  String get partyAbbreviation {
    switch (party) {
      case 'Democratic':
        return 'D';
      case 'Republican':
        return 'R';
      case 'Independent':
        return 'I';
      default:
        return party;
    }
  }

  String get stateDistrict {
    if (chamber == 'Senate') {
      return '$state';
    } else {
      return '$state-$district';
    }
  }

  String get roleName {
    return chamber == 'Senate' ? 'Senator' : 'Representative';
  }
} 