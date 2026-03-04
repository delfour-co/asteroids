import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'game_config.dart';

/// A single leaderboard entry.
class LeaderboardEntry {
  final String name;
  final int score;

  LeaderboardEntry(this.name, this.score);

  Map<String, dynamic> toJson() => {'name': name, 'score': score};

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(json['name'] as String, json['score'] as int);
}

/// Manages the top 10 leaderboard persisted in SharedPreferences.
class LeaderboardManager {
  List<LeaderboardEntry> _entries = [];

  List<LeaderboardEntry> get entries => List.unmodifiable(_entries);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(GameConfig.leaderboardKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _entries = list
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      _entries.sort((a, b) => b.score.compareTo(a.score));
    }
  }

  /// Returns true if the score qualifies for the leaderboard.
  bool qualifies(int score) {
    if (_entries.length < GameConfig.leaderboardMaxEntries) return score > 0;
    return score > _entries.last.score;
  }

  /// Add an entry and persist. Returns the rank (1-based).
  Future<int> addEntry(String name, int score) async {
    _entries.add(LeaderboardEntry(name, score));
    _entries.sort((a, b) => b.score.compareTo(a.score));
    if (_entries.length > GameConfig.leaderboardMaxEntries) {
      _entries = _entries.sublist(0, GameConfig.leaderboardMaxEntries);
    }
    await _save();
    return _entries.indexWhere((e) => e.name == name && e.score == score) + 1;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(GameConfig.leaderboardKey, json);
  }
}
