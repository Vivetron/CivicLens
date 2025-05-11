class Bill {
  final String id;
  final String number;
  final String title;
  final String summary;
  final String fullText;
  final DateTime introducedDate;
  final DateTime lastActionDate;
  final List<String> sponsors;
  final List<String> cosponsors;
  final List<String> committees;
  final List<String> relatedBills;
  final String status;
  final Map<String, dynamic>? voteData;
  final String aiGeneratedSummary;

  Bill({
    required this.id,
    required this.number,
    required this.title,
    required this.summary,
    required this.fullText,
    required this.introducedDate,
    required this.lastActionDate,
    required this.sponsors,
    required this.cosponsors,
    required this.committees,
    required this.relatedBills,
    required this.status,
    this.voteData,
    required this.aiGeneratedSummary,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      number: json['number'],
      title: json['title'],
      summary: json['summary'],
      fullText: json['fullText'],
      introducedDate: DateTime.parse(json['introducedDate']),
      lastActionDate: DateTime.parse(json['lastActionDate']),
      sponsors: List<String>.from(json['sponsors']),
      cosponsors: List<String>.from(json['cosponsors']),
      committees: List<String>.from(json['committees']),
      relatedBills: List<String>.from(json['relatedBills']),
      status: json['status'],
      voteData: json['voteData'],
      aiGeneratedSummary: json['aiGeneratedSummary'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'title': title,
      'summary': summary,
      'fullText': fullText,
      'introducedDate': introducedDate.toIso8601String(),
      'lastActionDate': lastActionDate.toIso8601String(),
      'sponsors': sponsors,
      'cosponsors': cosponsors,
      'committees': committees,
      'relatedBills': relatedBills,
      'status': status,
      'voteData': voteData,
      'aiGeneratedSummary': aiGeneratedSummary,
    };
  }
} 