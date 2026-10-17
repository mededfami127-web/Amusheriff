import 'dart:async';
import 'dart:io' show HttpException, SocketException;

import 'package:supabase_flutter/supabase_flutter.dart';

/// What a probe of a single backend asset found.
///
/// The distinction matters: "missing" means the backend has never been set up
/// on this project (run the migrations), "unreachable" means this build cannot
/// reach the network or the project URL is wrong, and "restricted" means the
/// asset exists but the anon key may not use it — expected for some tables and
/// not a fault. Each one has a different fix, so they are never collapsed into
/// one "server error".
enum SystemAssetStatus {
  /// The asset answered; it exists.
  ok,

  /// The asset exists, but this key/session is not allowed to use it.
  restricted,

  /// The asset is absent from the backend this build points at.
  missing,

  /// The backend could not be reached at all.
  unreachable,

  /// An answer we cannot classify. Never rendered as a fault.
  unknown,
}

/// Turns any exception thrown by a Supabase call into a [SystemAssetStatus].
///
/// Pure — no client, no I/O — so the rules below are unit-testable and there is
/// exactly one definition of what "missing" means. Both the error mapper (so a
/// missing table reads as "the backend is not set up" instead of a generic
/// server error) and the admin system check screen use it.
SystemAssetStatus classifyBackendFailure(Object error) {
  if (error is PostgrestException) {
    final String code = (error.code ?? '').trim();
    final String message = error.message.toLowerCase();
    // 42P01 = undefined_table. PostgREST also reports a relation it has never
    // seen as "could not find the table … in the schema cache".
    if (code == '42P01' ||
        message.contains('could not find the table') ||
        message.contains('could not find the relation') ||
        message.contains('does not exist')) {
      return SystemAssetStatus.missing;
    }
    // 42501 = insufficient_privilege; PGRST301/302 = no usable JWT.
    if (code == '42501' ||
        code == '401' ||
        code == '403' ||
        code == 'PGRST301' ||
        code == 'PGRST302') {
      return SystemAssetStatus.restricted;
    }
    return SystemAssetStatus.unknown;
  }

  if (error is AuthException) return SystemAssetStatus.restricted;

  if (error is StorageException) {
    if (error.message.toLowerCase().contains('bucket not found')) {
      return SystemAssetStatus.missing;
    }
    final int? status = int.tryParse((error.statusCode ?? '').trim());
    if (status == 401 || status == 403) return SystemAssetStatus.restricted;
    return SystemAssetStatus.unknown;
  }

  if (error is FunctionException) {
    // A 404 from the gateway means no such function; anything else the
    // function itself answered, so it is deployed.
    if (error.status == 404) return SystemAssetStatus.missing;
    if (error is FunctionsFetchException) return SystemAssetStatus.unreachable;
    if (error is FunctionsRelayException) return SystemAssetStatus.restricted;
    return SystemAssetStatus.ok;
  }

  if (error is SocketException ||
      error is HttpException ||
      error is TimeoutException) {
    return SystemAssetStatus.unreachable;
  }

  return SystemAssetStatus.unknown;
}
