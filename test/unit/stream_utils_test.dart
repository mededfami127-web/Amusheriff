import 'dart:async';

import 'package:amu_sharif_majlis/core/utils/stream_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('combineLatest', () {
    test('emits only once both sources have produced a value', () async {
      final StreamController<List<int>> a = StreamController<List<int>>();
      final StreamController<List<String>> b = StreamController<List<String>>();
      addTearDown(() async {
        await a.close();
        await b.close();
      });

      final List<String> emitted = <String>[];
      final StreamSubscription<String> sub =
          combineLatest<List<int>, List<String>, String>(
            a.stream,
            b.stream,
            (List<int> x, List<String> y) => '${x.join(",")}|${y.join(",")}',
          ).listen(emitted.add);

      a.add(<int>[1]);
      await Future<void>.delayed(Duration.zero);
      expect(emitted, isEmpty, reason: 'b has not emitted yet');

      b.add(<String>['x']);
      await Future<void>.delayed(Duration.zero);
      expect(emitted, <String>['1|x']);

      // A later change on either side re-emits with the other's latest value.
      a.add(<int>[1, 2]);
      await Future<void>.delayed(Duration.zero);
      expect(emitted, <String>['1|x', '1,2|x']);

      b.add(<String>['x', 'y']);
      await Future<void>.delayed(Duration.zero);
      expect(emitted, <String>['1|x', '1,2|x', '1,2|x,y']);

      await sub.cancel();
    });

    test('propagates errors from either source', () async {
      final StreamController<int> a = StreamController<int>();
      final StreamController<int> b = StreamController<int>();
      addTearDown(() async {
        await a.close();
        await b.close();
      });

      final List<Object> errors = <Object>[];
      final StreamSubscription<int> sub = combineLatest<int, int, int>(
        a.stream,
        b.stream,
        (int x, int y) => x + y,
      ).listen((_) {}, onError: errors.add);

      a.addError(StateError('source failed'));
      await Future<void>.delayed(Duration.zero);
      expect(errors, hasLength(1));
      expect(errors.first, isA<StateError>());

      await sub.cancel();
    });
  });

  group('groupBy', () {
    test('buckets items and preserves insertion order', () {
      final Map<String, List<int>> grouped = groupBy<int, String>(<int>[
        1,
        2,
        3,
        4,
        5,
      ], (int value) => value.isEven ? 'even' : 'odd');
      expect(grouped.keys.toList(), <String>['odd', 'even']);
      expect(grouped['odd'], <int>[1, 3, 5]);
      expect(grouped['even'], <int>[2, 4]);
    });
  });

  group('debounce', () {
    test('collapses a burst into one emission', () async {
      final StreamController<int> source = StreamController<int>();
      addTearDown(source.close);

      final List<int> emitted = <int>[];
      final StreamSubscription<int> sub = debounce<int>(
        source.stream,
        const Duration(milliseconds: 30),
      ).listen(emitted.add);

      source.add(1);
      source.add(2);
      source.add(3);
      await Future<void>.delayed(const Duration(milliseconds: 80));

      expect(emitted, <int>[3]);

      await sub.cancel();
    });
  });
}
