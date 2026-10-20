// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(catalogRemoteDataSource)
final catalogRemoteDataSourceProvider = CatalogRemoteDataSourceProvider._();

final class CatalogRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          CatalogRemoteDataSource,
          CatalogRemoteDataSource,
          CatalogRemoteDataSource
        >
    with $Provider<CatalogRemoteDataSource> {
  CatalogRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<CatalogRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CatalogRemoteDataSource create(Ref ref) {
    return catalogRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatalogRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatalogRemoteDataSource>(value),
    );
  }
}

String _$catalogRemoteDataSourceHash() =>
    r'159512548948a351f046e721df0fd6b95a9e6d95';

@ProviderFor(categoryRepository)
final categoryRepositoryProvider = CategoryRepositoryProvider._();

final class CategoryRepositoryProvider
    extends
        $FunctionalProvider<
          CategoryRepository,
          CategoryRepository,
          CategoryRepository
        >
    with $Provider<CategoryRepository> {
  CategoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CategoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoryRepository create(Ref ref) {
    return categoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryRepository>(value),
    );
  }
}

String _$categoryRepositoryHash() =>
    r'16ce96566707375c6e12b1b52067e75c8f9cf9df';

@ProviderFor(productRepository)
final productRepositoryProvider = ProductRepositoryProvider._();

final class ProductRepositoryProvider
    extends
        $FunctionalProvider<
          ProductRepository,
          ProductRepository,
          ProductRepository
        >
    with $Provider<ProductRepository> {
  ProductRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProductRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductRepository create(Ref ref) {
    return productRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductRepository>(value),
    );
  }
}

String _$productRepositoryHash() => r'956e3aa938e3f8f96d17445f8b540244c365b98c';

@ProviderFor(productMediaRepository)
final productMediaRepositoryProvider = ProductMediaRepositoryProvider._();

final class ProductMediaRepositoryProvider
    extends
        $FunctionalProvider<
          ProductMediaRepository,
          ProductMediaRepository,
          ProductMediaRepository
        >
    with $Provider<ProductMediaRepository> {
  ProductMediaRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productMediaRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productMediaRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProductMediaRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductMediaRepository create(Ref ref) {
    return productMediaRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductMediaRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductMediaRepository>(value),
    );
  }
}

String _$productMediaRepositoryHash() =>
    r'f61f741b6f120113a1c4b21f56873777bd5b4ff5';

/// Visible categories, live. Anonymous visitors get exactly what RLS allows.

@ProviderFor(visibleCategories)
final visibleCategoriesProvider = VisibleCategoriesProvider._();

/// Visible categories, live. Anonymous visitors get exactly what RLS allows.

final class VisibleCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          Stream<List<Category>>
        >
    with $FutureModifier<List<Category>>, $StreamProvider<List<Category>> {
  /// Visible categories, live. Anonymous visitors get exactly what RLS allows.
  VisibleCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visibleCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visibleCategoriesHash();

  @$internal
  @override
  $StreamProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Category>> create(Ref ref) {
    return visibleCategories(ref);
  }
}

String _$visibleCategoriesHash() => r'f1760bb7eb29fc63d5ebb6da74a244b28f73047b';

/// Every category, including hidden ones. Admin surface only.

@ProviderFor(allCategories)
final allCategoriesProvider = AllCategoriesProvider._();

/// Every category, including hidden ones. Admin surface only.

final class AllCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          Stream<List<Category>>
        >
    with $FutureModifier<List<Category>>, $StreamProvider<List<Category>> {
  /// Every category, including hidden ones. Admin surface only.
  AllCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allCategoriesHash();

  @$internal
  @override
  $StreamProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Category>> create(Ref ref) {
    return allCategories(ref);
  }
}

String _$allCategoriesHash() => r'522e0951601cf3ffbe437e10a63eee29bcb038de';

@ProviderFor(categoryById)
final categoryByIdProvider = CategoryByIdFamily._();

final class CategoryByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<Category?>,
          Category?,
          FutureOr<Category?>
        >
    with $FutureModifier<Category?>, $FutureProvider<Category?> {
  CategoryByIdProvider._({
    required CategoryByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryByIdHash();

  @override
  String toString() {
    return r'categoryByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Category?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Category?> create(Ref ref) {
    final argument = this.argument as String;
    return categoryById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryByIdHash() => r'8c140e04e117c05fb4563a172ac452464a89687f';

final class CategoryByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Category?>, String> {
  CategoryByIdFamily._()
    : super(
        retry: null,
        name: r'categoryByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryByIdProvider call(String id) =>
      CategoryByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'categoryByIdProvider';
}

@ProviderFor(categoryBySlug)
final categoryBySlugProvider = CategoryBySlugFamily._();

final class CategoryBySlugProvider
    extends
        $FunctionalProvider<
          AsyncValue<Category?>,
          Category?,
          FutureOr<Category?>
        >
    with $FutureModifier<Category?>, $FutureProvider<Category?> {
  CategoryBySlugProvider._({
    required CategoryBySlugFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryBySlugProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryBySlugHash();

  @override
  String toString() {
    return r'categoryBySlugProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Category?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Category?> create(Ref ref) {
    final argument = this.argument as String;
    return categoryBySlug(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryBySlugProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryBySlugHash() => r'220d1ac7f65cc7ee3ac23135ece76f0bddc25bca';

final class CategoryBySlugFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Category?>, String> {
  CategoryBySlugFamily._()
    : super(
        retry: null,
        name: r'categoryBySlugProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryBySlugProvider call(String slug) =>
      CategoryBySlugProvider._(argument: slug, from: this);

  @override
  String toString() => r'categoryBySlugProvider';
}

/// Number of visible products per category, for the "Browse by category" grid.
///
/// Counted client-side from the same Realtime stream the storefront already
/// subscribes to, so no extra view or round trip is needed.

@ProviderFor(categoryProductCounts)
final categoryProductCountsProvider = CategoryProductCountsProvider._();

/// Number of visible products per category, for the "Browse by category" grid.
///
/// Counted client-side from the same Realtime stream the storefront already
/// subscribes to, so no extra view or round trip is needed.

final class CategoryProductCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, int>>,
          Map<String, int>,
          Stream<Map<String, int>>
        >
    with $FutureModifier<Map<String, int>>, $StreamProvider<Map<String, int>> {
  /// Number of visible products per category, for the "Browse by category" grid.
  ///
  /// Counted client-side from the same Realtime stream the storefront already
  /// subscribes to, so no extra view or round trip is needed.
  CategoryProductCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryProductCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryProductCountsHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, int>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, int>> create(Ref ref) {
    return categoryProductCounts(ref);
  }
}

String _$categoryProductCountsHash() =>
    r'ddc11e34218e0ad66bbbedf6253df0a074fdcf9f';

/// Storefront product list with media joined in memory.
///
/// Combines the `products` and `product_media` Realtime streams so a newly
/// uploaded photo appears immediately — without re-querying the product row.

@ProviderFor(storefrontProducts)
final storefrontProductsProvider = StorefrontProductsFamily._();

/// Storefront product list with media joined in memory.
///
/// Combines the `products` and `product_media` Realtime streams so a newly
/// uploaded photo appears immediately — without re-querying the product row.

final class StorefrontProductsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Product>>,
          List<Product>,
          Stream<List<Product>>
        >
    with $FutureModifier<List<Product>>, $StreamProvider<List<Product>> {
  /// Storefront product list with media joined in memory.
  ///
  /// Combines the `products` and `product_media` Realtime streams so a newly
  /// uploaded photo appears immediately — without re-querying the product row.
  StorefrontProductsProvider._({
    required StorefrontProductsFamily super.from,
    required ({String? categoryId, bool featured}) super.argument,
  }) : super(
         retry: null,
         name: r'storefrontProductsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$storefrontProductsHash();

  @override
  String toString() {
    return r'storefrontProductsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<Product>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Product>> create(Ref ref) {
    final argument = this.argument as ({String? categoryId, bool featured});
    return storefrontProducts(
      ref,
      categoryId: argument.categoryId,
      featured: argument.featured,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StorefrontProductsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$storefrontProductsHash() =>
    r'444219e61c952dc24d69d831c68c633c51661cb4';

/// Storefront product list with media joined in memory.
///
/// Combines the `products` and `product_media` Realtime streams so a newly
/// uploaded photo appears immediately — without re-querying the product row.

final class StorefrontProductsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<Product>>,
          ({String? categoryId, bool featured})
        > {
  StorefrontProductsFamily._()
    : super(
        retry: null,
        name: r'storefrontProductsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Storefront product list with media joined in memory.
  ///
  /// Combines the `products` and `product_media` Realtime streams so a newly
  /// uploaded photo appears immediately — without re-querying the product row.

  StorefrontProductsProvider call({
    String? categoryId,
    bool featured = false,
  }) => StorefrontProductsProvider._(
    argument: (categoryId: categoryId, featured: featured),
    from: this,
  );

  @override
  String toString() => r'storefrontProductsProvider';
}

/// First product image per category, for category tiles without a cover.
///
/// Derived from the single [storefrontProducts] stream (products + media
/// joined in memory), so the rail never issues one query per category.

@ProviderFor(categoryThumbnailPaths)
final categoryThumbnailPathsProvider = CategoryThumbnailPathsProvider._();

/// First product image per category, for category tiles without a cover.
///
/// Derived from the single [storefrontProducts] stream (products + media
/// joined in memory), so the rail never issues one query per category.

final class CategoryThumbnailPathsProvider
    extends
        $FunctionalProvider<
          Map<String, String>,
          Map<String, String>,
          Map<String, String>
        >
    with $Provider<Map<String, String>> {
  /// First product image per category, for category tiles without a cover.
  ///
  /// Derived from the single [storefrontProducts] stream (products + media
  /// joined in memory), so the rail never issues one query per category.
  CategoryThumbnailPathsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryThumbnailPathsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryThumbnailPathsHash();

  @$internal
  @override
  $ProviderElement<Map<String, String>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, String> create(Ref ref) {
    return categoryThumbnailPaths(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, String>>(value),
    );
  }
}

String _$categoryThumbnailPathsHash() =>
    r'3dd5f083b7a9aa37576766b1b6cf651f4ed5befd';

/// Admin product list, including unpublished rows.

@ProviderFor(adminProducts)
final adminProductsProvider = AdminProductsFamily._();

/// Admin product list, including unpublished rows.

final class AdminProductsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Product>>,
          List<Product>,
          Stream<List<Product>>
        >
    with $FutureModifier<List<Product>>, $StreamProvider<List<Product>> {
  /// Admin product list, including unpublished rows.
  AdminProductsProvider._({
    required AdminProductsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'adminProductsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminProductsHash();

  @override
  String toString() {
    return r'adminProductsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Product>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Product>> create(Ref ref) {
    final argument = this.argument as String?;
    return adminProducts(ref, categoryId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminProductsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminProductsHash() => r'5ae2c3cc1c2513c37caef36e50220844f284357f';

/// Admin product list, including unpublished rows.

final class AdminProductsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Product>>, String?> {
  AdminProductsFamily._()
    : super(
        retry: null,
        name: r'adminProductsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Admin product list, including unpublished rows.

  AdminProductsProvider call({String? categoryId}) =>
      AdminProductsProvider._(argument: categoryId, from: this);

  @override
  String toString() => r'adminProductsProvider';
}

/// Product detail with its own media stream, so the gallery updates live.

@ProviderFor(productDetail)
final productDetailProvider = ProductDetailFamily._();

/// Product detail with its own media stream, so the gallery updates live.

final class ProductDetailProvider
    extends
        $FunctionalProvider<AsyncValue<Product?>, Product?, Stream<Product?>>
    with $FutureModifier<Product?>, $StreamProvider<Product?> {
  /// Product detail with its own media stream, so the gallery updates live.
  ProductDetailProvider._({
    required ProductDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productDetailHash();

  @override
  String toString() {
    return r'productDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Product?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Product?> create(Ref ref) {
    final argument = this.argument as String;
    return productDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productDetailHash() => r'4cba2d0f6fa0b8fa654b364082643b15b726c732';

/// Product detail with its own media stream, so the gallery updates live.

final class ProductDetailFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Product?>, String> {
  ProductDetailFamily._()
    : super(
        retry: null,
        name: r'productDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Product detail with its own media stream, so the gallery updates live.

  ProductDetailProvider call(String id) =>
      ProductDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'productDetailProvider';
}

@ProviderFor(searchProducts)
final searchProductsProvider = SearchProductsFamily._();

final class SearchProductsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Product>>,
          List<Product>,
          FutureOr<List<Product>>
        >
    with $FutureModifier<List<Product>>, $FutureProvider<List<Product>> {
  SearchProductsProvider._({
    required SearchProductsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchProductsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchProductsHash();

  @override
  String toString() {
    return r'searchProductsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Product>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Product>> create(Ref ref) {
    final argument = this.argument as String;
    return searchProducts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchProductsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchProductsHash() => r'18bf0fb714174cdf2a344716922e3eac99850e74';

final class SearchProductsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Product>>, String> {
  SearchProductsFamily._()
    : super(
        retry: null,
        name: r'searchProductsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchProductsProvider call(String query) =>
      SearchProductsProvider._(argument: query, from: this);

  @override
  String toString() => r'searchProductsProvider';
}
