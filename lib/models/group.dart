class Group {
  final String id;
  final String name;
  final String emoji;
  final DateTime createdAt;

  Group({
    required this.id,
    required this.name,
    required this.emoji,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json['id'],
        name: json['name'],
        emoji: json['emoji'] ?? '👥',
        createdAt: DateTime.parse(json['createdAt']),
      );
}