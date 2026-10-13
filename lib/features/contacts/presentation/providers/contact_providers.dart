import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/utils/launcher.dart';
import '../../data/datasources/contacts_remote_datasource.dart';
import '../../data/repositories/contact_repository_impl.dart';
import '../../domain/contact_launcher.dart';
import '../../domain/entities/contact_kind.dart';
import '../../domain/entities/contact_link.dart';
import '../../domain/repositories/contact_repository.dart';

part 'contact_providers.g.dart';

@Riverpod(keepAlive: true)
ContactsRemoteDataSource contactsRemoteDataSource(Ref ref) =>
    ContactsRemoteDataSource(ref.watch(supabaseClientProvider));

@Riverpod(keepAlive: true)
ContactRepository contactRepository(Ref ref) =>
    ContactRepositoryImpl(ref.watch(contactsRemoteDataSourceProvider));

@Riverpod(keepAlive: true)
ContactLauncher contactLauncher(Ref ref) =>
    ContactLauncher(ref.watch(linkLauncherProvider));

/// Live, visible contact links, primary first.
@riverpod
Stream<List<ContactLink>> visibleContactLinks(Ref ref) =>
    ref.watch(contactRepositoryProvider).watchVisible();

@riverpod
Stream<List<ContactLink>> allContactLinks(Ref ref) =>
    ref.watch(contactRepositoryProvider).watchAll();

/// The link shown as the storefront's headline contact button.
@riverpod
ContactLink? primaryContactLink(Ref ref) {
  final List<ContactLink> links =
      ref.watch(visibleContactLinksProvider).value ?? const <ContactLink>[];
  if (links.isEmpty) return null;
  return links.firstWhere(
    (ContactLink link) => link.isPrimary,
    orElse: () => links.first,
  );
}

/// Channels offered on a product page, most direct first.
@riverpod
List<ContactLink> orderChannels(Ref ref) {
  final List<ContactLink> links =
      ref.watch(visibleContactLinksProvider).value ?? const <ContactLink>[];
  return <ContactLink>[...links]
    ..sort((ContactLink a, ContactLink b) {
      final int byPriority =
          a.kind.actionPriority.compareTo(b.kind.actionPriority);
      if (byPriority != 0) return byPriority;
      return a.sortOrder.compareTo(b.sortOrder);
    });
}

/// Look-up helper used by the product page's "Buy" sheet.
@riverpod
ContactLink? contactForKind(Ref ref, ContactKind kind) {
  final List<ContactLink> links =
      ref.watch(visibleContactLinksProvider).value ?? const <ContactLink>[];
  for (final ContactLink link in links) {
    if (link.kind == kind) return link;
  }
  return null;
}
