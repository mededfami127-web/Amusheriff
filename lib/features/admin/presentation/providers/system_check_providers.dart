import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../data/system_check_runner.dart';

part 'system_check_providers.g.dart';

/// The state of the backend this build points at, asset by asset.
///
/// Deliberately auto-disposed: every visit to the system check screen re-runs
/// the probes, so a migration the owner applies while the app is open is
/// picked up on the next visit (and by the "run again" action).
@riverpod
Future<List<SystemAssetCheck>> systemChecks(Ref ref) async {
  final SupabaseClient client = ref.watch(supabaseClientProvider);
  return runSystemChecks(client);
}
