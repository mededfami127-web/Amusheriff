import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admin_ui_providers.g.dart';

/// Whether the owner asked to see the storefront exactly as a customer would.
///
/// This is a UI affordance, not an authorisation boundary: RLS already stops
/// anon from seeing unpublished rows, and the storefront only ever queries
/// published data. Flipping this on hides the admin chrome so the owner can
/// sanity-check what is live.
@Riverpod(keepAlive: true)
class PreviewAsCustomer extends _$PreviewAsCustomer {
  @override
  bool build() => false;

  void enable() => state = true;
  void disable() => state = false;
  void toggle() => state = !state;
}
