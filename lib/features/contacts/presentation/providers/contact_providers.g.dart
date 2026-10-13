// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(contactsRemoteDataSource)
final contactsRemoteDataSourceProvider = ContactsRemoteDataSourceProvider._();

final class ContactsRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          ContactsRemoteDataSource,
          ContactsRemoteDataSource,
          ContactsRemoteDataSource
        >
    with $Provider<ContactsRemoteDataSource> {
  ContactsRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactsRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactsRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<ContactsRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContactsRemoteDataSource create(Ref ref) {
    return contactsRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactsRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactsRemoteDataSource>(value),
    );
  }
}

String _$contactsRemoteDataSourceHash() =>
    r'8005b1c52d77da2009f886efb62814cf5ab4dd21';

@ProviderFor(contactRepository)
final contactRepositoryProvider = ContactRepositoryProvider._();

final class ContactRepositoryProvider
    extends
        $FunctionalProvider<
          ContactRepository,
          ContactRepository,
          ContactRepository
        >
    with $Provider<ContactRepository> {
  ContactRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactRepositoryHash();

  @$internal
  @override
  $ProviderElement<ContactRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContactRepository create(Ref ref) {
    return contactRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactRepository>(value),
    );
  }
}

String _$contactRepositoryHash() => r'86d17136564b8afd70aec3d6daf437ba99671a7b';

@ProviderFor(contactLauncher)
final contactLauncherProvider = ContactLauncherProvider._();

final class ContactLauncherProvider
    extends
        $FunctionalProvider<ContactLauncher, ContactLauncher, ContactLauncher>
    with $Provider<ContactLauncher> {
  ContactLauncherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactLauncherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactLauncherHash();

  @$internal
  @override
  $ProviderElement<ContactLauncher> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ContactLauncher create(Ref ref) {
    return contactLauncher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactLauncher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactLauncher>(value),
    );
  }
}

String _$contactLauncherHash() => r'0048b8a687c050e5ba5ccb078474716b666adf58';

/// Live, visible contact links, primary first.

@ProviderFor(visibleContactLinks)
final visibleContactLinksProvider = VisibleContactLinksProvider._();

/// Live, visible contact links, primary first.

final class VisibleContactLinksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ContactLink>>,
          List<ContactLink>,
          Stream<List<ContactLink>>
        >
    with
        $FutureModifier<List<ContactLink>>,
        $StreamProvider<List<ContactLink>> {
  /// Live, visible contact links, primary first.
  VisibleContactLinksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visibleContactLinksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visibleContactLinksHash();

  @$internal
  @override
  $StreamProviderElement<List<ContactLink>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ContactLink>> create(Ref ref) {
    return visibleContactLinks(ref);
  }
}

String _$visibleContactLinksHash() =>
    r'e0eec7830bb58995f2f6ad79e560e340c7e5919c';

@ProviderFor(allContactLinks)
final allContactLinksProvider = AllContactLinksProvider._();

final class AllContactLinksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ContactLink>>,
          List<ContactLink>,
          Stream<List<ContactLink>>
        >
    with
        $FutureModifier<List<ContactLink>>,
        $StreamProvider<List<ContactLink>> {
  AllContactLinksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allContactLinksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allContactLinksHash();

  @$internal
  @override
  $StreamProviderElement<List<ContactLink>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ContactLink>> create(Ref ref) {
    return allContactLinks(ref);
  }
}

String _$allContactLinksHash() => r'3573d2eeccde2c707ba69b30b0c759aa4afe543e';

/// The link shown as the storefront's headline contact button.

@ProviderFor(primaryContactLink)
final primaryContactLinkProvider = PrimaryContactLinkProvider._();

/// The link shown as the storefront's headline contact button.

final class PrimaryContactLinkProvider
    extends $FunctionalProvider<ContactLink?, ContactLink?, ContactLink?>
    with $Provider<ContactLink?> {
  /// The link shown as the storefront's headline contact button.
  PrimaryContactLinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'primaryContactLinkProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$primaryContactLinkHash();

  @$internal
  @override
  $ProviderElement<ContactLink?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ContactLink? create(Ref ref) {
    return primaryContactLink(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactLink? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactLink?>(value),
    );
  }
}

String _$primaryContactLinkHash() =>
    r'da69013226db9059ca40af9a6adb780cbdf39cfa';

/// Channels offered on a product page, most direct first.

@ProviderFor(orderChannels)
final orderChannelsProvider = OrderChannelsProvider._();

/// Channels offered on a product page, most direct first.

final class OrderChannelsProvider
    extends
        $FunctionalProvider<
          List<ContactLink>,
          List<ContactLink>,
          List<ContactLink>
        >
    with $Provider<List<ContactLink>> {
  /// Channels offered on a product page, most direct first.
  OrderChannelsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderChannelsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderChannelsHash();

  @$internal
  @override
  $ProviderElement<List<ContactLink>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ContactLink> create(Ref ref) {
    return orderChannels(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ContactLink> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ContactLink>>(value),
    );
  }
}

String _$orderChannelsHash() => r'6ec00aeeede678e3e1402d71d5b87fe825650941';

/// Look-up helper used by the product page's "Buy" sheet.

@ProviderFor(contactForKind)
final contactForKindProvider = ContactForKindFamily._();

/// Look-up helper used by the product page's "Buy" sheet.

final class ContactForKindProvider
    extends $FunctionalProvider<ContactLink?, ContactLink?, ContactLink?>
    with $Provider<ContactLink?> {
  /// Look-up helper used by the product page's "Buy" sheet.
  ContactForKindProvider._({
    required ContactForKindFamily super.from,
    required ContactKind super.argument,
  }) : super(
         retry: null,
         name: r'contactForKindProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$contactForKindHash();

  @override
  String toString() {
    return r'contactForKindProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ContactLink?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ContactLink? create(Ref ref) {
    final argument = this.argument as ContactKind;
    return contactForKind(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactLink? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactLink?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ContactForKindProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$contactForKindHash() => r'14ac05fa30336bc1dd8a44326081b24497be7362';

/// Look-up helper used by the product page's "Buy" sheet.

final class ContactForKindFamily extends $Family
    with $FunctionalFamilyOverride<ContactLink?, ContactKind> {
  ContactForKindFamily._()
    : super(
        retry: null,
        name: r'contactForKindProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Look-up helper used by the product page's "Buy" sheet.

  ContactForKindProvider call(ContactKind kind) =>
      ContactForKindProvider._(argument: kind, from: this);

  @override
  String toString() => r'contactForKindProvider';
}
