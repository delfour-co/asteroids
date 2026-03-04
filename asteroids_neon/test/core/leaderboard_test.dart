import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:asteroids_neon/core/game_config.dart';
import 'package:asteroids_neon/core/leaderboard.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LeaderboardManager qualifies', () {
    test('returns true for empty leaderboard with score > 0', () async {
      final lb = LeaderboardManager();
      await lb.init();

      expect(lb.qualifies(100), true);
    });

    test('returns false for score 0', () async {
      final lb = LeaderboardManager();
      await lb.init();

      expect(lb.qualifies(0), false);
    });

    test('returns true when leaderboard is not full', () async {
      final lb = LeaderboardManager();
      await lb.init();

      // Add a few entries (less than max)
      await lb.addEntry('AAA', 5000);
      await lb.addEntry('BBB', 3000);

      expect(lb.qualifies(1), true);
    });

    test('returns false when full and score is lower than worst', () async {
      final lb = LeaderboardManager();
      await lb.init();

      // Fill the leaderboard
      for (int i = 0; i < GameConfig.leaderboardMaxEntries; i++) {
        await lb.addEntry('P${i.toString().padLeft(2, '0')}',
            (i + 1) * 1000);
      }

      // The lowest score is 1000; score below should not qualify
      expect(lb.qualifies(500), false);
    });

    test('returns true when full and score beats lowest', () async {
      final lb = LeaderboardManager();
      await lb.init();

      for (int i = 0; i < GameConfig.leaderboardMaxEntries; i++) {
        await lb.addEntry('P${i.toString().padLeft(2, '0')}',
            (i + 1) * 1000);
      }

      // The lowest score is 1000; score above should qualify
      expect(lb.qualifies(1500), true);
    });
  });

  group('LeaderboardManager addEntry', () {
    test('adds entry and returns correct rank', () async {
      final lb = LeaderboardManager();
      await lb.init();

      final rank = await lb.addEntry('AAA', 5000);
      expect(rank, 1);
      expect(lb.entries.length, 1);
      expect(lb.entries.first.name, 'AAA');
      expect(lb.entries.first.score, 5000);
    });

    test('entries are sorted by score descending', () async {
      final lb = LeaderboardManager();
      await lb.init();

      await lb.addEntry('LOW', 1000);
      await lb.addEntry('HIGH', 9000);
      await lb.addEntry('MID', 5000);

      expect(lb.entries[0].score, 9000);
      expect(lb.entries[1].score, 5000);
      expect(lb.entries[2].score, 1000);
    });

    test('limits to max ${GameConfig.leaderboardMaxEntries} entries', () async {
      final lb = LeaderboardManager();
      await lb.init();

      // Add more entries than the max
      for (int i = 0; i < GameConfig.leaderboardMaxEntries + 3; i++) {
        await lb.addEntry('P${i.toString().padLeft(2, '0')}',
            (i + 1) * 100);
      }

      expect(lb.entries.length, GameConfig.leaderboardMaxEntries);
    });

    test('lowest score is evicted when full', () async {
      final lb = LeaderboardManager();
      await lb.init();

      for (int i = 0; i < GameConfig.leaderboardMaxEntries; i++) {
        await lb.addEntry('P${i.toString().padLeft(2, '0')}',
            (i + 1) * 1000);
      }

      // Add a high score; lowest entry (1000) should be evicted
      await lb.addEntry('NEW', 50000);

      expect(lb.entries.length, GameConfig.leaderboardMaxEntries);
      expect(lb.entries.first.name, 'NEW');
      expect(lb.entries.first.score, 50000);
      // Lowest entry should now be 2000, not 1000
      expect(lb.entries.last.score, 2000);
    });
  });

  group('LeaderboardManager persistence', () {
    test('persists and reloads entries', () async {
      final lb1 = LeaderboardManager();
      await lb1.init();
      await lb1.addEntry('AAA', 5000);
      await lb1.addEntry('BBB', 3000);

      // Create a new manager instance — should load persisted data
      final lb2 = LeaderboardManager();
      await lb2.init();

      expect(lb2.entries.length, 2);
      expect(lb2.entries[0].score, 5000);
      expect(lb2.entries[1].score, 3000);
    });
  });
}
