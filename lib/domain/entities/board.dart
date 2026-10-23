class Board {
  const Board({
    required this.id,
    required this.name,
    this.description = '',
    this.isSecret = false,
  });
  final String id, name, description;
  final bool isSecret;
  factory Board.fromJson(Map<String, dynamic> j) => Board(
    id: j['id'] as String,
    name: j['name'] as String,
    description: j['description'] as String? ?? '',
    isSecret: j['isSecret'] == true,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'isSecret': isSecret,
  };
}
