import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/contact_settings.dart';
import '../../domain/repositories/contact_settings_repository.dart';
import '../datasources/contact_settings_remote_datasource.dart';

/// Supabase-backed [ContactSettingsRepository].
///
/// The table is constrained to one row (`check (id = 1)`), so reads take that
/// row and writes upsert it. Every failure funnels through
/// [ErrorMapper.guard] to surface a localised [AppFailure].
class ContactSettingsRepositoryImpl implements ContactSettingsRepository {
  ContactSettingsRepositoryImpl(this._remote);

  final ContactSettingsRemoteDataSource _remote;

  @override
  Stream<ContactSettings> watch() =>
      _remote.watch().map(ContactSettings.fromJson);

  @override
  Future<ContactSettings> fetch() => ErrorMapper.guard(() async {
    final Map<String, dynamic>? row = await _remote.fetch();
    return row == null ? ContactSettings.empty : ContactSettings.fromJson(row);
  });

  @override
  Future<void> save(ContactSettings settings) =>
      ErrorMapper.guard(() => _remote.upsert(settings.toRow()));
}
