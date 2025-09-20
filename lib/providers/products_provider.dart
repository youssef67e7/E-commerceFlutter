import 'package:flutter/material.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProductsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  static const int _pageSize = 10; // Reduce page size for faster initial load
  bool _hasMoreProducts = true;
  String? _selectedCategory;
  static const String _categoriesCacheKey = 'cached_categories';
  static const String _categoriesCacheTimeKey = 'cached_categories_time';
  static const int _cacheExpiryDuration = 24 * 60 * 60 * 1000; // 24 hours

  List<Product> get products => [..._products];
  List<String> get categories => [..._categories];
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreProducts => _hasMoreProducts;
  int get totalProducts => _products.length;
  String? get selectedCategory => _selectedCategory;

  ProductsProvider() {
    _apiService.initialize();
    // Don't call async methods directly in constructor
    // Instead, let the UI trigger the initial load
  }

  // Initialize data properly - this should be called by the UI
  Future<void> initializeData() async {
    if (_products.isNotEmpty || _isLoading) return; // Already initialized or loading
    
    // Load categories first (faster)
    await fetchAndSetCategories();
    
    // Then load initial products
    await fetchAndSetProducts();
  }

  // Set selected category
  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Fetch all products
  Future<void> fetchAndSetProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _products = [];
      _hasMoreProducts = true;
    }

    // Always allow fetching if we're refreshing or if we have more products
    if (!_hasMoreProducts && !refresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      List<Product> loadedProducts;

      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        // Fetch products by selected category
        loadedProducts = await _apiService.fetchProductsByCategory(
          _selectedCategory!,
          limit: _pageSize,
          skip: _currentPage * _pageSize,
        );
      } else {
        // Fetch all products
        loadedProducts = await _apiService.fetchProducts(
          limit: _pageSize,
          skip: _currentPage * _pageSize,
        );
      }

      // Filter out makeup-related categories
      final makeupCategories = ['beauty', 'fragrances', 'skin-care'];
      loadedProducts =
          loadedProducts.where((product) {
            return !makeupCategories.any(
              (category) => product.category.toLowerCase().contains(category),
            );
          }).toList();

      if (refresh) {
        _products = loadedProducts;
      } else {
        _products.addAll(loadedProducts);
      }

      _hasMoreProducts = loadedProducts.length == _pageSize;
      _currentPage++;
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch products by category
  Future<void> fetchProductsByCategory(String category) async {
    // If trying to fetch makeup categories, return empty list
    final makeupCategories = ['beauty', 'fragrances', 'skin-care'];
    if (makeupCategories.any(
      (makeupCategory) => category.toLowerCase().contains(makeupCategory),
    )) {
      _selectedCategory = category;
      _products = [];
      _isLoading = false;
      _error = null;
      notifyListeners();
      return;
    }

    _selectedCategory = category;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loadedProducts = await _apiService.fetchProductsByCategory(
        category,
        limit: _pageSize, // Limit initial fetch for better performance
        skip: 0,
      );

      // Filter out makeup-related products even within category
      final makeupCategories = ['beauty', 'fragrances', 'skin-care'];
      final filteredProducts =
          loadedProducts.where((product) {
            return !makeupCategories.any(
              (makeupCategory) =>
                  product.category.toLowerCase().contains(makeupCategory),
            );
          }).toList();

      _products = filteredProducts;
      _currentPage = 1;
      _hasMoreProducts = filteredProducts.length == _pageSize;
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch categories
  Future<void> fetchAndSetCategories() async {
    // Try to load from cache first
    final cachedCategories = await _loadCategoriesFromCache();
    if (cachedCategories != null) {
      _categories = cachedCategories;
      notifyListeners();
      // Try to refresh from API in background
      _refreshCategoriesFromAPI();
      return;
    }

    try {
      final loadedCategories = await _apiService.fetchCategories();

      // Filter out makeup-related categories
      final makeupCategories = ['beauty', 'fragrances', 'skin-care'];
      final filteredCategories =
          loadedCategories.where((category) {
            return !makeupCategories.any(
              (makeupCategory) =>
                  category.toLowerCase().contains(makeupCategory),
            );
          }).toList();

      _categories = filteredCategories;
      // Save to cache
      await _saveCategoriesToCache(filteredCategories);
    } catch (error) {
      _error = error.toString();
      // Set default categories if API fails, excluding makeup
      _categories = [
        'Electronics',
        'Fashion',
        'Home & Kitchen',
        'Sports',
        'Books',
        'Toys',
        'Automotive',
      ];
    } finally {
      notifyListeners();
    }
  }

  // Load categories from cache
  Future<List<String>?> _loadCategoriesFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_categoriesCacheKey);
      final cacheTime = prefs.getInt(_categoriesCacheTimeKey);

      if (cachedData != null && cacheTime != null) {
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        if (currentTime - cacheTime < _cacheExpiryDuration) {
          final List<dynamic> decodedData = json.decode(cachedData);
          return decodedData.cast<String>();
        }
      }
    } catch (e) {
      // Ignore cache errors
    }
    return null;
  }

  // Save categories to cache
  Future<void> _saveCategoriesToCache(List<String> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = json.encode(categories);
      await prefs.setString(_categoriesCacheKey, encodedData);
      await prefs.setInt(
        _categoriesCacheTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Ignore cache errors
    }
  }

  // Refresh categories from API in background
  Future<void> _refreshCategoriesFromAPI() async {
    try {
      final loadedCategories = await _apiService.fetchCategories();

      // Filter out makeup-related categories
      final makeupCategories = ['beauty', 'fragrances', 'skin-care'];
      final filteredCategories =
          loadedCategories.where((category) {
            return !makeupCategories.any(
              (makeupCategory) =>
                  category.toLowerCase().contains(makeupCategory),
            );
          }).toList();

      // Only update if different from current categories
      if (!_listsEqual(_categories, filteredCategories)) {
        _categories = filteredCategories;
        notifyListeners();
        // Save to cache
        await _saveCategoriesToCache(filteredCategories);
      }
    } catch (e) {
      // Ignore refresh errors
    }
  }

  // Helper method to compare lists
  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  // Search products
  Future<void> searchProducts(String query) async {
    _selectedCategory = null; // Clear category when searching
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loadedProducts = await _apiService.searchProducts(query);
      _products = loadedProducts;
      _currentPage = 1;
      _hasMoreProducts = loadedProducts.length == _pageSize;
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Product findById(String id) {
    return _products.firstWhere((product) => product.id == id);
  }

  List<Product> get favoriteProducts {
    return _products.where((product) => product.rating > 4.5).toList();
  }

  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  // Method for pull-to-refresh
  Future<void> loadProducts() async {
    await fetchAndSetProducts(refresh: true);
  }

  // Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (!_isLoading && _hasMoreProducts) {
      await fetchAndSetProducts();
    }
  }

  // Get single product by ID
  Future<Product?> getProductById(String id) async {
    try {
      return await _apiService.fetchProduct(id);
    } catch (error) {
      _error = error.toString();
      notifyListeners();
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear category filter
  void clearCategoryFilter() {
    _selectedCategory = null;
    fetchAndSetProducts(refresh: true);
  }
}