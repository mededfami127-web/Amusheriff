import '../drafts/contact_link_draft.dart';
import '../entities/contact_link.dart';

/// Contact links, shared by the storefront (read) and the admin gateway
/// (read + write).
///
/// The storefront reads [watchVisible] — RLS hides links where
/// `is_visible = false` — so an admin toggling a channel off removes it from
/// every customer's device in realtime.
abstract interface class ContactRepository {
  Stream<List<ContactLink>> watchVisible();

  Stream<List<ContactLink>> watchAll();

  Future<List<ContactLink>> fetchVisible();

  Future<ContactLink?> findById(String id);

  Future<ContactLink> create(ContactLinkDraft draft);

  Future<ContactLink> update(String id, ContactLinkDraft draft);

  Future<void> delete(String id);

  Future<void> setVisibility(String id, {required bool isVisible});

  Future<void> setPrimary(String id, {required bool isPrimary});

  Future<void> reorder(List<String> orderedIds);
}
