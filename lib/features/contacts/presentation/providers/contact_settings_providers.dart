import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../data/datasources/contact_settings_remote_datasource.dart';
import '../../data/repositories/contact_settings_repository_impl.dart';
import '../../domain/entities/contact_settings.dart';
import '../../domain/repositories/contact_settings_repository.dart';

part 'contact_settings_providers.g.dart';

@Riverpod(keepAlive: true)
ContactSettingsRemoteDataSource contactSettingsRemoteDataSource(Ref ref) =>
    ContactSettingsRemoteDataSource(ref.watch(supabaseClientProvider));

@Riverpod(keepAlive: true)
ContactSettingsRepository contactSettingsRepository(Ref ref) =>
    ContactSettingsRepositoryImpl(
      ref.watch(contactSettingsRemoteDataSourceProvider),
    );

/// Live owner contact channels, empty until the owner fills the row.
@riverpod
Stream<ContactSettings> contactSettings(Ref ref) =>
    ref.watch(contactSettingsRepositoryProvider).watch();

/// Synchronous view for screens that only need "which channels exist".
@riverpod
ContactSettings contactSettingsValue(Ref ref) =>
    ref.watch(contactSettingsProvider).value ?? ContactSettings.empty;
