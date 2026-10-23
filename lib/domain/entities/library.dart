import 'board.dart';
import 'pin.dart';

class Library {
  const Library({
    this.boards = const [],
    this.pins = const {},
    this.saved = const {},
    this.likes = const {},
    this.hidden = const {},
    this.searches = const [],
    this.activity = const [],
    this.name = 'Your name',
    this.bio = 'Collecting a little inspiration, every day.',
    this.username = 'daydreamer',
    this.darkMode = false,
  });
  final List<Board> boards;
  final Map<String, Pin> pins;
  final Map<String, List<String>> saved;
  final Set<String> likes, hidden;
  final List<String> searches, activity;
  final String name, username, bio;
  final bool darkMode;
  bool isSaved(String pinId) => saved.values.any((ids) => ids.contains(pinId));
  List<Pin> pinsFor(String? boardId) {
    final ids = boardId == null
        ? saved.values.expand((e) => e).toSet()
        : saved[boardId] ?? <String>[];
    return ids
        .map((id) => pins[id])
        .whereType<Pin>()
        .toList()
        .reversed
        .toList();
  }

  Library copyWith({
    List<Board>? boards,
    Map<String, Pin>? pins,
    Map<String, List<String>>? saved,
    Set<String>? likes,
    Set<String>? hidden,
    List<String>? searches,
    List<String>? activity,
    String? name,
    String? username,
    String? bio,
    bool? darkMode,
  }) => Library(
    boards: boards ?? this.boards,
    pins: pins ?? this.pins,
    saved: saved ?? this.saved,
    likes: likes ?? this.likes,
    hidden: hidden ?? this.hidden,
    searches: searches ?? this.searches,
    activity: activity ?? this.activity,
    name: name ?? this.name,
    username: username ?? this.username,
    bio: bio ?? this.bio,
    darkMode: darkMode ?? this.darkMode,
  );
  factory Library.fromJson(Map<String, dynamic> j) => Library(
    boards: (j['boards'] as List? ?? [])
        .map((e) => Board.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    pins: (j['pins'] as Map? ?? {}).map(
      (k, v) =>
          MapEntry(k.toString(), Pin.fromJson(Map<String, dynamic>.from(v))),
    ),
    saved: (j['saved'] as Map? ?? {}).map(
      (k, v) => MapEntry(k.toString(), List<String>.from(v)),
    ),
    likes: Set<String>.from(j['likes'] ?? []),
    hidden: Set<String>.from(j['hidden'] ?? []),
    searches: List<String>.from(j['searches'] ?? []),
    activity: List<String>.from(j['activity'] ?? []),
    name: j['name'] as String? ?? 'Your name',
    username: j['username'] as String? ?? 'daydreamer',
    bio: j['bio'] as String? ?? '',
    darkMode: j['darkMode'] == true,
  );
  Map<String, dynamic> toJson() => {
    'boards': boards.map((e) => e.toJson()).toList(),
    'pins': pins.map((k, v) => MapEntry(k, v.toJson())),
    'saved': saved,
    'likes': likes.toList(),
    'hidden': hidden.toList(),
    'searches': searches,
    'activity': activity,
    'name': name,
    'username': username,
    'bio': bio,
    'darkMode': darkMode,
  };
}
