class Calculation {
  final String id;
  final double billAmount;
  final double tipPercent;
  final int peopleCount;
  final double totalWithTip;
  final double perPerson;
  final DateTime date;
  final String? placeId;
  final String? groupId;
  final String? note;

  Calculation({
    required this.id,
    required this.billAmount,
    required this.tipPercent,
    required this.peopleCount,
    required this.totalWithTip,
    required this.perPerson,
    required this.date,
    this.placeId,
    this.groupId,
    this.note,
  });

  double get tipAmount => billAmount * tipPercent / 100;

  Map<String, dynamic> toJson() => {
        'id': id,
        'billAmount': billAmount,
        'tipPercent': tipPercent,
        'peopleCount': peopleCount,
        'totalWithTip': totalWithTip,
        'perPerson': perPerson,
        'date': date.toIso8601String(),
        'placeId': placeId,
        'groupId': groupId,
        'note': note,
      };

  factory Calculation.fromJson(Map<String, dynamic> json) => Calculation(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        billAmount: (json['billAmount'] as num).toDouble(),
        tipPercent: (json['tipPercent'] as num).toDouble(),
        peopleCount: json['peopleCount'],
        totalWithTip: (json['totalWithTip'] as num).toDouble(),
        perPerson: (json['perPerson'] as num).toDouble(),
        date: DateTime.parse(json['date']),
        placeId: json['placeId'],
        groupId: json['groupId'],
        note: json['note'],
      );
}