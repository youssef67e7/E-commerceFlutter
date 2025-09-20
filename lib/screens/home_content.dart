import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/providers/products_provider.dart';
import 'package:ecommerce_app/widgets/product_item.dart';
import 'package:ecommerce_app/widgets/shimmer_widget.dart';
import 'package:ecommerce_app/widgets/error_widgets.dart';
import 'package:ecommerce_app/screens/search_screen.dart';
import 'package:ecommerce_app/widgets/category_item.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure products are loaded when this widget is built
    final productsProvider = Provider.of<ProductsProvider>(context);
    
    // Load products if they haven't been loaded yet
    if (productsProvider.products.isEmpty && !productsProvider.isLoading) {
      // Use a more robust approach to initialize data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Add a small delay to ensure the widget is fully built
        Future.delayed(Duration.zero, () {
          if (productsProvider.products.isEmpty && !productsProvider.isLoading) {
            productsProvider.initializeData();
          }
        });
      });
    }
    
    final products = productsProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          productsProvider.selectedCategory != null
              ? '${productsProvider.selectedCategory} Products'
              : 'Luxury',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.purple.shade900,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.purple.withValues(alpha: 0.6),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            icon: const Icon(Icons.search, size: 30),
            tooltip: 'Search Products',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Shop by Category',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
            SizedBox(
              height: 85,
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return true;
                },
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  cacheExtent:
                      500, // Cache widgets for better scrolling performance
                  // Add performance optimizations
                  physics: const ClampingScrollPhysics(),
                  children: [
                    // "View All" button to clear category filter
                    if (productsProvider.selectedCategory != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            // Clear category filter
                            productsProvider.clearCategoryFilter();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 18,
                            ),
                            elevation: 8,
                            shadowColor: Colors.purple.withValues(alpha: 0.5),
                            animationDuration: Duration.zero,
                            enableFeedback: false,
                          ),
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ...productsProvider.categories.map(
                      (category) => CategoryItem(
                        category: category,
                        isSelected:
                            productsProvider.selectedCategory == category,
                        onTap: () {
                          // Filter products by category
                          productsProvider.fetchProductsByCategory(category);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (productsProvider.selectedCategory != null)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.purple.shade300, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing results for: ${productsProvider.selectedCategory}',
                      style: TextStyle(
                        color: Colors.purple.shade900,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        productsProvider.clearCategoryFilter();
                      },
                      child: const Text(
                        'Clear Filter',
                        style: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    productsProvider.selectedCategory != null
                        ? '${productsProvider.selectedCategory} Products'
                        : 'Featured Products',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  if (productsProvider.selectedCategory != null)
                    TextButton(
                      onPressed: () {
                        productsProvider.clearCategoryFilter();
                      },
                      child: const Text(
                        'Clear Filter',
                        style: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<ProductsProvider>(
                builder: (context, productsProvider, child) {
                  // Show error state if there's an error and no products
                  if (productsProvider.error != null && products.isEmpty) {
                    return ErrorStateWidget(
                      error: productsProvider.error,
                      errorMessage: getErrorMessage(productsProvider.error),
                      onRetry: () {
                        productsProvider.clearError();
                        productsProvider.retryLoading();
                      },
                      retryButtonText: 'Retry',
                    );
                  }

                  // Show loading state if loading and no products
                  if (productsProvider.isLoading && products.isEmpty) {
                    return const ShimmerProductGrid();
                  }

                  // Show empty state if no products and not loading
                  if (products.isEmpty && !productsProvider.isLoading) {
                    return EmptyStateWidget(
                      icon: Icons.store_outlined,
                      title: 'No products available',
                      message: 'Check back later for new products!',
                      action: ElevatedButton.icon(
                        onPressed: () {
                          productsProvider.retryLoading();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    );
                  }

                  // Show error snackbar if there's an error but we have products
                  if (productsProvider.error != null && products.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ErrorSnackBarHelper.showError(
                        context,
                        getErrorMessage(productsProvider.error),
                      );
                      productsProvider.clearError();
                    });
                  }

                  return PullToRefreshWrapper(
                    onRefresh: () async {
                      try {
                        await productsProvider.loadProducts();
                        if (context.mounted) {
                          ErrorSnackBarHelper.showSuccess(
                            context,
                            'Products refreshed successfully!',
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ErrorSnackBarHelper.showError(
                            context,
                            getErrorMessage(e),
                          );
                        }
                      }
                    },
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        // Implement lazy loading for better performance
                        if (notification.metrics.pixels ==
                                notification.metrics.maxScrollExtent &&
                            !productsProvider.isLoading &&
                            productsProvider.hasMoreProducts) {
                          // Load more products when user scrolls to the end
                          productsProvider.loadMoreProducts();
                        }
                        return false;
                      },
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                        ),
                        itemCount:
                            products.length +
                            (productsProvider.isLoading &&
                                    productsProvider.hasMoreProducts
                                ? 2
                                : 0),
                        itemBuilder: (ctx, i) {
                          if (i >= products.length) {
                            return const ShimmerWidget(
                              isLoading: true,
                              child: ProductItemShimmer(),
                            );
                          }
                          return ProductItem(product: products[i]);
                        },
                        // Add performance optimizations
                        cacheExtent: 1000,
                        physics: const ClampingScrollPhysics(),
                        // Add additional performance optimizations
                        shrinkWrap: true,
                        addRepaintBoundaries: true,
                        addAutomaticKeepAlives: true,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}