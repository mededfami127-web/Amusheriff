import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../domain/repositories/auth_repository.dart';

/// Supabase-backed [AuthRepository].
///
/// Authorisation is always resolved server-side: [isAdmin] performs an
/// RLS-protected read of the caller's own `profiles` row. Even if a client
/// forged `user_metadata`, the database would still deny every admin write.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const String profilesTable = 'profiles';

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  bool get isSignedIn => _client.auth.currentSession != null;

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) => ErrorMapper.guard(() async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  });

  @override
  Future<void> signOut() =>
      ErrorMapper.guard(() => _client.auth.signOut(scope: SignOutScope.local));

  @override
  Future<void> sendPasswordReset(String email) => ErrorMapper.guard(() async {
    await _client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: 'amusheriff://reset-password',
    );
  });

  @override
  Future<void> updatePassword(String newPassword) => ErrorMapper.guard(
    () => _client.auth.updateUser(UserAttributes(password: newPassword)),
  );

  @override
  Future<bool> verifyPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Re-authenticating is the only way to confirm the current password;
      // Supabase has no "check password" endpoint by design.
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return true;
    } on AuthException catch (error) {
      final AppFailure failure = ErrorMapper.map(error);
      if (failure is AuthFailure &&
          failure.messageKey == 'errorInvalidCredentials') {
        return false;
      }
      throw failure;
    }
  }

  @override
  Future<bool> isAdmin() => ErrorMapper.guard(() async {
    final String? userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    final Map<String, dynamic>? row = await _client
        .from(profilesTable)
        .select('is_admin')
        .eq('id', userId)
        .maybeSingle();

    // A missing row means the trigger has not provisioned the profile yet;
    // treat that as "not an admin" rather than an error.
    return row?['is_admin'] == true;
  });
}
