import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../data/datasources/inquiries_remote_datasource.dart';
import '../../data/repositories/inquiry_repository_impl.dart';
import '../../domain/entities/inquiry.dart';
import '../../domain/repositories/inquiry_repository.dart';

part 'inquiry_providers.g.dart';

@Riverpod(keepAlive: true)
InquiriesRemoteDataSource inquiriesRemoteDataSource(Ref ref) =>
    InquiriesRemoteDataSource(ref.watch(supabaseClientProvider));

/// Overridden with a fake in tests.
@Riverpod(keepAlive: true)
InquiryRepository inquiryRepository(Ref ref) =>
    InquiryRepositoryImpl(ref.watch(inquiriesRemoteDataSourceProvider));

/// Live lead log. Reads only what RLS permits, which for anon is nothing.
@riverpod
Stream<List<Inquiry>> adminInquiries(Ref ref) =>
    ref.watch(inquiryRepositoryProvider).watchAll();

/// Leads recorded in the last seven days.
@riverpod
int inquiriesThisWeek(Ref ref) {
  final List<Inquiry> all =
      ref.watch(adminInquiriesProvider).value ?? const <Inquiry>[];
  final DateTime now = DateTime.now();
  return all
      .where((Inquiry i) => i.isWithinLast(const Duration(days: 7), now: now))
      .length;
}

/// How many times each product was contacted this week, most-tapped first.
///
/// Derived from the same stream the gateway already subscribes to, so the
/// "most contacted" list costs no extra round trip.
@riverpod
List<MapEntry<String, int>> mostContactedProducts(Ref ref) {
  final List<Inquiry> all =
      ref.watch(adminInquiriesProvider).value ?? const <Inquiry>[];
  final DateTime now = DateTime.now();

  final Map<String, int> counts = <String, int>{};
  for (final Inquiry inquiry in all) {
    final String? title = inquiry.productTitle;
    if (title == null || title.isEmpty) continue;
    if (!inquiry.isWithinLast(const Duration(days: 7), now: now)) continue;
    counts[title] = (counts[title] ?? 0) + 1;
  }

  final List<MapEntry<String, int>> entries = counts.entries.toList()
    ..sort(
      (MapEntry<String, int> a, MapEntry<String, int> b) =>
          b.value.compareTo(a.value),
    );
  return entries.take(5).toList(growable: false);
}

/// Clears a lead. Optimistic callers should invalidate on failure.
Future<void> deleteInquiry(Ref ref, String id) =>
    ref.watch(inquiryRepositoryProvider).remove(id);
