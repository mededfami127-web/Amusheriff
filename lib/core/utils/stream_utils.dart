import 'dart:async';

/// Emits the latest combination of [a] and [b] whenever either changes, once
/// both have produced at least one value.
///
/// Used to join two independent Realtime streams — e.g. `products` and
/// `product_media` — without an extra network round trip on every event.
/// The returned stream closes when both sources close, and cancels both
/// subscriptions when the listener cancels.
Stream<R> combineLatest<A, B, R>(
  Stream<A> a,
  Stream<B> b,
  R Function(A a, B b) combine,
) {
  final StreamController<R> out = StreamController<R>();
  A? latestA;
  B? latestB;
  bool hasA = false;
  bool hasB = false;
  int closedCount = 0;

  void emit() {
    if (hasA && hasB && !out.isClosed) {
      out.add(combine(latestA as A, latestB as B));
    }
  }

  late final StreamSubscription<A> subA;
  late final StreamSubscription<B> subB;

  void maybeClose() {
    closedCount++;
    if (closedCount == 2 && !out.isClosed) out.close();
  }

  subA = a.listen(
    (A value) {
      latestA = value;
      hasA = true;
      emit();
    },
    onError: (Object error, StackTrace stack) {
      if (!out.isClosed) out.addError(error, stack);
    },
    onDone: maybeClose,
  );

  subB = b.listen(
    (B value) {
      latestB = value;
      hasB = true;
      emit();
    },
    onError: (Object error, StackTrace stack) {
      if (!out.isClosed) out.addError(error, stack);
    },
    onDone: maybeClose,
  );

  out.onCancel = () async {
    await subA.cancel();
    await subB.cancel();
  };

  return out.stream;
}

/// Groups [items] by a key extracted from each item, preserving input order.
Map<K, List<T>> groupBy<T, K>(Iterable<T> items, K Function(T item) keyOf) {
  final Map<K, List<T>> grouped = <K, List<T>>{};
  for (final T item in items) {
    grouped.putIfAbsent(keyOf(item), () => <T>[]).add(item);
  }
  return grouped;
}

/// Debounces a stream of values — used by the storefront search box.
Stream<T> debounce<T>(
  Stream<T> source,
  Duration duration, {
  bool leading = false,
}) {
  Timer? timer;
  late final StreamController<T> controller;
  StreamSubscription<T>? subscription;

  controller = StreamController<T>(
    onListen: () {
      subscription = source.listen(
        (T value) {
          timer?.cancel();
          if (leading && timer == null) controller.add(value);
          timer = Timer(duration, () {
            if (!leading) controller.add(value);
          });
        },
        onError: controller.addError,
        onDone: () {
          timer?.cancel();
          controller.close();
        },
      );
    },
    onCancel: () async {
      timer?.cancel();
      await subscription?.cancel();
    },
  );

  return controller.stream;
}
