import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../data/repositories/site_content_repository_impl.dart';
import '../../domain/repositories/site_content_repository.dart';

part 'site_content_providers.g.dart';

@Riverpod(keepAlive: true)
SiteContentRepository siteContentRepository(Ref ref) =>
    SiteContentRepositoryImpl(ref.watch(supabaseClientProvider));

/// Live home copy for one locale: `key → value`.
@riverpod
Stream<Map<String, String>> siteContent(Ref ref, String locale) =>
    ref.watch(siteContentRepositoryProvider).watch(locale);

/// Synchronous view of [siteContent], for widgets that want one value with
/// ARB fallback instead of a stream.
@riverpod
Map<String, String> siteContentValue(Ref ref, String locale) =>
    ref.watch(siteContentProvider(locale)).value ?? const <String, String>{};

/// The keys the owner has rewritten in [locale].
@riverpod
Set<String> siteContentKeys(Ref ref, String locale) =>
    ref.watch(siteContentProvider(locale)).value?.keys.toSet() ??
    const <String>{};
