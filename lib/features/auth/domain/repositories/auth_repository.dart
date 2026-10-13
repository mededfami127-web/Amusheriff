import 'package:supabase_flutter/supabase_flutter.dart';

/// Admin authentication.
///
/// The app never reads the service-role key and never trusts client-side
/// metadata for authorisation: [isAdmin] asks the database, which is the only
/// place `profiles.is_admin` can be changed.
abstract interface class AuthRepository {
  /// Supabase's auth event stream (sign-in, sign-out, token refresh, recovery).
  Stream<AuthState> get authStateChanges;

  /// The cached session, or `null`. Supabase refreshes this automatically.
  Session? get currentSession;

  User? get currentUser;

  bool get isSignedIn;

  Future<void> signInWithPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  /// Sends a recovery email to the owner's address.
  Future<void> sendPasswordReset(String email);

  /// Requires an active session (Supabase allows a user to update their own
  /// password while authenticated).
  Future<void> updatePassword(String newPassword);

  /// Re-authenticates with the current password, returning `true` when it is
  /// correct. Used to gate the change-password screen.
  Future<bool> verifyPassword({
    required String email,
    required String password,
  });

  /// Reads `profiles.is_admin` for the signed-in user from Postgres.
  Future<bool> isAdmin();
}
