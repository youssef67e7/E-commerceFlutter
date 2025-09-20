import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/providers/products_provider.dart';
import 'package:ecommerce_app/widgets/category_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final categories = productsProvider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shop by Category',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple.shade900,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.purple.withValues(alpha: 0.6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child:
            categories.isEmpty && productsProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                    itemCount: categories.length,
                    cacheExtent:
                        1000, // Cache widgets for better scrolling performance
                    itemBuilder:
                        (ctx, i) => CategoryCard(
                          category: categories[i],
                          onTap: () {
                            // Filter products by category and navigate back to home
                            productsProvider.fetchProductsByCategory(
                              categories[i],
                            );
                            Navigator.pop(context);
                          },
                        ),
                    // Add performance optimizations
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                  ),
                ),
      ),
    );
  }
}
