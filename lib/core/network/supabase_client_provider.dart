import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_client_provider.g.dart';

/// The single, app-wide Supabase client.
///
/// Overridden in tests with a fake so repositories never touch the network.
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;

/// Fires on every auth event (sign-in, sign-out, token refresh, recovery).
@Riverpod(keepAlive: true)
Stream<AuthState> authStateChanges(Ref ref) =>
    ref.watch(supabaseClientProvider).auth.onAuthStateChange;

/// The current session, or `null` when signed out.
@Riverpod(keepAlive: true)
Session? currentSession(Ref ref) {
  final SupabaseClient client = ref.watch(supabaseClientProvider);
  ref.watch(authStateChangesProvider);
  return client.auth.currentSession;
}

/// The current authenticated user, or `null` when signed out.
@Riverpod(keepAlive: true)
User? currentUser(Ref ref) =>
    ref.watch(currentSessionProvider)?.user;

/// Stream of the signed-in user id, used by the router guard.
@Riverpod(keepAlive: true)
Stream<String?> currentUserId(Ref ref) => ref
    .watch(supabaseClientProvider)
    .auth
    .onAuthStateChange
    .map((AuthState state) => state.session?.user.id);
