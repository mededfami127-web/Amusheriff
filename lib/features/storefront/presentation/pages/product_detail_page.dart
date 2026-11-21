import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/network/storage_urls.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/gradients.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/gold_divider.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/shimmer_card.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_media.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../contacts/domain/contact_launcher.dart';
import '../../../contacts/domain/entities/contact_kind.dart';
import '../../../contacts/domain/entities/contact_link.dart';
import '../../../contacts/domain/entities/contact_settings.dart';
import '../../../contacts/presentation/providers/contact_providers.dart';
import '../../../contacts/presentation/providers/contact_settings_providers.dart';
import '../../../../core/utils/launcher.dart';
import '../providers/storefront_providers.dart';
import '../widgets/call_button.dart';
import '../widgets/favourite_button.dart';

/// Full product page. Everything is streamed, so an admin price change or a
/// newly uploaded photo appears here immediately.
class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String language = Localizations.localeOf(context).languageCode;
    final AsyncValue<Product?> product = ref.watch(
      productDetailProvider(productId),
    );
    final Product? current = product.value;

    return AppScaffold(
      showLockup: false,
      title: current?.titleFor(language) ?? l10n.stateLoading,
      actions: <Widget>[
        if (current != null) FavouriteButton(productId: productId),
        if (current != null)
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: l10n.actionShare,
            onPressed: () => ref
                .read(linkLauncherProvider)
                .shareProduct(
                  title: current.titleFor(language),
                  price: Formatters.money(
                    current.price,
                    currency: current.currencyCode,
                    locale: language,
                  ),
                  url: 'amusheriff://product/$productId',
                ),
          ),
      ],
      body: switch (product) {
        AsyncLoading() => const ShimmerGrid(itemCount: 2),
        AsyncError(:final Object error) => ErrorStateView(
          failure: error is AppFailure ? error : UnknownFailure(cause: error),
          onRetry: () => ref.invalidate(productDetailProvider(productId)),
        ),
        AsyncValue<Product?>(:final Product? value) =>
          value == null
              ? EmptyState(
                  title: l10n.stateNotFoundTitle,
                  message: l10n.stateNotFoundMessage,
                  icon: Icons.chair_outlined,
                )
              : _Body(product: value, language: language),
      },
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.product, required this.language});

  final Product product;
  final String language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final String description = product.descriptionFor(language);
    final List<ContactLink> channels = ref.watch(orderChannelsProvider);
    final ContactSettings settings = ref.watch(contactSettingsValueProvider);

    // The product's own category, and its mother when it sits on a
    // subcategory: the page states where the piece belongs instead of leaving
    // the shopper with no way back into the catalogue tree.
    final Category? category = ref
        .watch(categoryByIdProvider(product.categoryId))
        .value;
    final String? motherId = category?.parentId;
    final Category? mother = motherId == null
        ? null
        : ref.watch(categoryByIdProvider(motherId)).value;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        _Gallery(product: product),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (category != null) ...<Widget>[
                _CategoryBreadcrumb(
                  mother: mother,
                  category: category,
                  language: language,
                ),
                const SizedBox(height: 6),
              ],
              Text(
                product.titleFor(language),
                style:
                    BrandTypography.displayForLocale(
                      Localizations.localeOf(context),
                      base: BrandTypography.displayMedium,
                    ).copyWith(
                      color: dark
                          ? BrandColors.goldLight
                          : BrandColors.charcoal,
                    ),
              ),
              const SizedBox(height: 14),
              // Three price parts on one line cannot fit a 320dp phone at
              // 2.0 text; the Wrap breaks between them instead of clipping.
              Wrap(
                spacing: 12,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  ShaderMask(
                    shaderCallback: BrandGradients.goldHorizontal.createShader,
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      product.hasPrice
                          ? Formatters.money(
                              product.price,
                              currency: product.currencyCode,
                              locale: language,
                            )
                          : l10n.labelCallForPrice,
                      style: BrandTypography.price.copyWith(
                        fontSize: product.hasPrice ? 26 : 20,
                        color: BrandColors.gold,
                      ),
                    ),
                  ),
                  if (product.hasDiscount) ...<Widget>[
                    Text(
                      Formatters.money(
                        product.compareAtPrice!,
                        currency: product.currencyCode,
                        locale: language,
                      ),
                      style: BrandTypography.priceStruck.copyWith(
                        color: BrandTypography.mutedOn(
                          Theme.of(context).brightness,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: BrandGradients.warmAccent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.labelDiscount(product.discountPercent ?? 0),
                        style: BrandTypography.labelSmall.copyWith(
                          color: BrandColors.charcoal,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Icon(
                    product.isAvailable
                        ? Icons.check_circle_outline_rounded
                        : Icons.remove_circle_outline_rounded,
                    size: 17,
                    color: product.isAvailable
                        ? BrandColors.success
                        : BrandColors.danger,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    product.isAvailable
                        ? l10n.labelAvailable
                        : l10n.labelUnavailable,
                    style: BrandTypography.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const GoldDivider(withOrnament: true),
              if (description.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 20),
                Text(
                  description,
                  style: BrandTypography.bodyLarge.copyWith(
                    color: dark
                        ? BrandColors.ivory.withValues(alpha: 0.9)
                        : BrandColors.charcoal.withValues(alpha: 0.86),
                  ),
                ),
              ],
              // The one action that matters on a marketplace listing: call the
              // shop about this exact piece. Sits after the description so the
              // page reads photo → title → price → details → Call.
              const SizedBox(height: 24),
              const CallButton(),
              const SizedBox(height: 26),
              _ContactActions(
                product: product,
                channels: channels,
                settings: settings,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Every photo of the piece, stacked down the page.
///
/// The old [PageView] hid all but one photo behind a swipe and then repeated
/// them as a horizontal thumbnail strip. A Jiji-style listing shows the whole
/// set in one vertical scroll instead — nothing to swipe sideways, and the
/// video badge stays exactly where it was.
class _Gallery extends ConsumerWidget {
  const _Gallery({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final List<ProductMedia> media = product.media;
    final String title = product.titleFor(
      Localizations.localeOf(context).languageCode,
    );
    final int cacheWidth =
        (MediaQuery.sizeOf(context).width *
                MediaQuery.devicePixelRatioOf(context))
            .round()
            .clamp(320, 1600);

    if (media.isEmpty) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: dark ? BrandColors.plumSurface : const Color(0xFFF3ECE1),
          ),
          child: Center(
            child: Icon(
              Icons.chair_outlined,
              size: 52,
              color: BrandColors.gold.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    final StorageUrls urls = ref.read(storageUrlsProvider);

    return Column(
      children: <Widget>[
        for (int i = 0; i < media.length; i++)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: CachedNetworkImage(
                // A video has no decodable still of its own; its poster frame
                // is what the old gallery showed anyway, so the same source is
                // used and the play badge marks it as a clip.
                imageUrl: urls.productMedia(
                  media[i].isVideo && media[i].hasThumbnail
                      ? media[i].thumbnailPath!
                      : media[i].storagePath,
                ),
                memCacheWidth: cacheWidth,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    const ShimmerBox(height: 320, radius: 0),
                errorWidget: (_, __, ___) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: dark
                        ? BrandColors.plumSurface
                        : const Color(0xFFF3ECE1),
                  ),
                  child: const Center(
                    child: Icon(Icons.broken_image_outlined, size: 40),
                  ),
                ),
                imageBuilder: (_, ImageProvider provider) => Semantics(
                  label: l10n.a11yProductImage(title),
                  image: true,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Image(image: provider, fit: BoxFit.cover),
                      if (media[i].isVideo)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.5),
                              border: Border.all(color: BrandColors.gold),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 30,
                              color: BrandColors.ivory,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ContactActions extends ConsumerWidget {
  const _ContactActions({
    required this.product,
    required this.channels,
    required this.settings,
  });

  final Product product;
  final List<ContactLink> channels;
  final ContactSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String language = Localizations.localeOf(context).languageCode;
    final ContactLauncher launcher = ref.read(contactLauncherProvider);
    final String title = product.titleFor(language);
    // A piece without a price still has an inquiry message; it just asks for
    // the price instead of quoting ETB 0.
    final String price = product.hasPrice
        ? Formatters.money(
            product.price,
            currency: product.currencyCode,
            locale: language,
          )
        : l10n.labelCallForPrice;
    final String message = l10n.inquiryMessageTemplate(title, price);

    // Channels from `admin_contact_settings`, minus any kind already rendered
    // from the curated `contact_links`, so the same WhatsApp button never shows
    // twice. Only non-empty settings fields become a button.
    final Set<ContactKind> curatedKinds = channels
        .map((ContactLink link) => link.kind)
        .toSet();
    final List<ContactLink> ownerLinks = <ContactLink>[
      if (settings.hasPhone && !curatedKinds.contains(ContactKind.phone))
        _ownerLink(ContactKind.phone, l10n.contactPhone, settings.ownerPhone),
      if (settings.hasWhatsApp && !curatedKinds.contains(ContactKind.whatsapp))
        _ownerLink(
          ContactKind.whatsapp,
          l10n.contactWhatsApp,
          settings.whatsappNumber,
        ),
      if (settings.hasTelegram && !curatedKinds.contains(ContactKind.telegram))
        _ownerLink(
          ContactKind.telegram,
          l10n.contactTelegram,
          settings.telegramHandle,
        ),
      if (settings.hasEmail && !curatedKinds.contains(ContactKind.email))
        _ownerLink(ContactKind.email, l10n.contactEmail, settings.ownerEmail),
      if (settings.hasInstagram &&
          !curatedKinds.contains(ContactKind.instagram))
        _ownerLink(
          ContactKind.instagram,
          l10n.contactInstagram,
          settings.instagramHandle,
        ),
      if (settings.hasFacebook && !curatedKinds.contains(ContactKind.facebook))
        _ownerLink(
          ContactKind.facebook,
          l10n.contactFacebook,
          settings.facebookHandle,
        ),
      if (settings.hasTikTok && !curatedKinds.contains(ContactKind.tiktok))
        _ownerLink(
          ContactKind.tiktok,
          l10n.contactTikTok,
          settings.tiktokHandle,
        ),
      if (settings.hasYouTube && !curatedKinds.contains(ContactKind.youtube))
        _ownerLink(
          ContactKind.youtube,
          l10n.contactYouTube,
          settings.youtubeHandle,
        ),
      if (settings.hasWebsite && !curatedKinds.contains(ContactKind.website))
        _ownerLink(
          ContactKind.website,
          l10n.contactWebsite,
          settings.websiteUrl,
        ),
    ];

    if (channels.isEmpty && ownerLinks.isEmpty) {
      return EmptyState(
        title: l10n.stateEmptyTitle,
        message: l10n.contactLaunchFailed,
        icon: Icons.link_off_rounded,
        compact: true,
      );
    }

    Future<void> open(ContactLink link, String prefilled) async {
      final bool ok = await launcher.launch(link, message: prefilled);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.contactLaunchFailed)));
      }
    }

    // The most direct curated channel becomes the primary gradient button.
    final ContactLink? primary = channels.isEmpty ? null : channels.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (primary != null)
          GradientButton(
            label: '${l10n.actionOrderNow} · ${primary.label}',
            icon: primary.kind.icon,
            onPressed: product.isOrderable
                ? () => open(primary, message)
                : null,
          ),
        if (channels.length > 1) ...<Widget>[
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: channels
                .skip(1)
                .map(
                  (ContactLink link) => OutlinedButton.icon(
                    onPressed: () => open(link, message),
                    icon: Icon(link.kind.icon, size: 18),
                    label: Text(link.label),
                  ),
                )
                .toList(growable: false),
          ),
        ],
        if (ownerLinks.isNotEmpty) ...<Widget>[
          const SizedBox(height: 24),
          Text(l10n.actionContactOwner, style: BrandTypography.titleMedium),
          const SizedBox(height: 4),
          Text(l10n.contactOwnerHint, style: BrandTypography.bodySmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ownerLinks
                .map(
                  (ContactLink link) => OutlinedButton.icon(
                    // WhatsApp / Telegram get the product name pre-filled.
                    onPressed: () => open(link, title),
                    icon: Icon(link.kind.icon, size: 18),
                    label: Text(link.label),
                  ),
                )
                .toList(growable: false),
          ),
        ],
        const SizedBox(height: 8),
        if (product.videos.isNotEmpty)
          Text(
            l10n.a11yVideoThumbnail(title),
            style: BrandTypography.bodySmall,
          ),
      ],
    );
  }

  static ContactLink _ownerLink(ContactKind kind, String label, String value) =>
      ContactLink(
        id: 'settings-${kind.name}',
        kind: kind,
        label: label,
        value: value,
      );
}

/// "Category › Subcategory" above the product title.
///
/// Both steps are tappable, so a shopper who arrived from search can step back
/// into the tree one level at a time. A product filed directly on a top-level
/// category shows that single name.
class _CategoryBreadcrumb extends StatelessWidget {
  const _CategoryBreadcrumb({
    required this.mother,
    required this.category,
    required this.language,
  });

  final Category? mother;
  final Category category;
  final String language;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = BrandTypography.labelLarge.copyWith(
      color: BrandColors.gold,
    );
    final Category? parent = mother;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        if (parent != null) ...<Widget>[
          InkWell(
            onTap: () => context.push(Routes.category(parent.slug)),
            child: Text(parent.nameFor(language), style: style),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '›',
              style: style.copyWith(color: BrandColors.goldHairline),
            ),
          ),
        ],
        InkWell(
          onTap: () => context.push(Routes.category(category.slug)),
          child: Text(
            category.nameFor(language),
            style: parent == null
                ? style
                : style.copyWith(color: BrandColors.goldLight),
          ),
        ),
      ],
    );
  }
}
