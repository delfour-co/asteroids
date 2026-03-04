import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/event_bus.dart';

// Test events
class TestEvent {
  final String message;
  TestEvent(this.message);
}

class OtherEvent {
  final int value;
  OtherEvent(this.value);
}

void main() {
  late EventBus bus;

  setUp(() {
    bus = EventBus();
  });

  group('EventBus', () {
    test('emits event to listener', () {
      String? received;
      bus.on<TestEvent>((e) => received = e.message);

      bus.emit(TestEvent('hello'));

      expect(received, 'hello');
    });

    test('emits to multiple listeners', () {
      final results = <String>[];
      bus.on<TestEvent>((e) => results.add('a:${e.message}'));
      bus.on<TestEvent>((e) => results.add('b:${e.message}'));

      bus.emit(TestEvent('test'));

      expect(results, ['a:test', 'b:test']);
    });

    test('typed events only reach correct listeners', () {
      String? testResult;
      int? otherResult;
      bus.on<TestEvent>((e) => testResult = e.message);
      bus.on<OtherEvent>((e) => otherResult = e.value);

      bus.emit(OtherEvent(42));

      expect(testResult, isNull);
      expect(otherResult, 42);
    });

    test('off removes listener', () {
      int callCount = 0;
      void listener(TestEvent e) => callCount++;

      bus.on<TestEvent>(listener);
      bus.emit(TestEvent('first'));
      expect(callCount, 1);

      bus.off<TestEvent>(listener);
      bus.emit(TestEvent('second'));
      expect(callCount, 1);
    });

    test('emit with no listeners does not throw', () {
      expect(() => bus.emit(TestEvent('no listeners')), returnsNormally);
    });

    test('clear removes all listeners', () {
      int callCount = 0;
      bus.on<TestEvent>((e) => callCount++);

      bus.clear();
      bus.emit(TestEvent('after clear'));

      expect(callCount, 0);
    });

    test('listener added during emit does not receive current event', () {
      int callCount = 0;
      bus.on<TestEvent>((e) {
        bus.on<TestEvent>((e2) => callCount++);
      });

      bus.emit(TestEvent('trigger'));
      // The nested listener was added during iteration of a copy,
      // so it should not have been called for this emit.
      expect(callCount, 0);

      // But it should be called on the next emit
      bus.emit(TestEvent('second'));
      expect(callCount, 1);
    });
  });
}
