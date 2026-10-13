import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

bool _hasTransport(List<ConnectivityResult> results) =>
    results.isNotEmpty &&
    !results.every((ConnectivityResult r) => r == ConnectivityResult.none);

/// Reactive online/offline flag.
///
/// Note this only reports whether a transport exists — not whether Supabase is
/// reachable. Repositories still have to handle [NetworkFailure] gracefully.
@Riverpod(keepAlive: true)
Stream<bool> isOnline(Ref ref) async* {
  final Connectivity connectivity = Connectivity();
  ref.onDispose(connectivity.onConnectivityChanged.listen((_) {}).cancel);

  yield _hasTransport(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(_hasTransport);
}
