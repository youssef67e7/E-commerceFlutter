import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  static const String baseUrl = 'https://dummyjson.com';
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  static const String _categoriesCacheKey = 'api_categories_cache';
  static const String _categoriesCacheTimeKey = 'api_categories_cache_time';
  static const int _cacheExpiryDuration = 60 * 60 * 1000; // 1 hour

  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: connectTimeout),
        receiveTimeout: const Duration(milliseconds: receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: kDebugMode,
        responseBody: kDebugMode,
        error: kDebugMode,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            // Check connectivity before making request
            final connectivityResult = await Connectivity().checkConnectivity();
            if (connectivityResult.contains(ConnectivityResult.none)) {
              throw DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                error: 'No internet connection',
              );
            }
          } catch (e) {
            // If connectivity check fails, continue with the request
            debugPrint('Connectivity check failed: $e');
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(_handleError(error));
        },
      ),
    );
  }

  DioException _handleError(DioException error) {
    String message;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Server response timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        message = _handleHttpError(error.response?.statusCode);
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'Network connection error. Please check your internet.';
        break;
      default:
        message = 'An unexpected error occurred. Please try again.';
    }

    return DioException(
      requestOptions: error.requestOptions,
      type: error.type,
      error: message,
    );
  }

  String _handleHttpError(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access forbidden.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'Server error occurred. Please try again.';
    }
  }

  // Fetch all products
  Future<List<Product>> fetchProducts({int limit = 20, int skip = 0}) async {
    try {
      // Limit the number of products fetched to improve performance
      final actualLimit = limit > 50 ? 50 : limit; // Increased max limit back to 50
      final response = await _dio.get(
        '/products',
        queryParameters: {'limit': actualLimit, 'skip': skip},
      );

      // Validate response structure
      if (response.data is! Map<String, dynamic>) {
        throw FormatException('Invalid response format');
      }

      final productsData = response.data['products'];
      if (productsData is! List<dynamic>) {
        throw FormatException('Invalid products data format');
      }

      // Filter out any null or invalid product entries
      final validProducts = productsData
          .where((item) => item != null && item is Map<String, dynamic>)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .where((product) => product.id.isNotEmpty) // Only include products with valid IDs
          .toList();

      return validProducts;
    } catch (e) {
      throw _convertError(e);
    }
  }

  // Fetch products by category
  Future<List<Product>> fetchProductsByCategory(
    String category, {
    int limit = 20, // Reduced default limit
    int skip = 0,
  }) async {
    try {
      // Limit the number of products fetched to improve performance
      final actualLimit = limit > 50 ? 50 : limit; // Increased max limit back to 50
      final response = await _dio.get(
        '/products/category/$category',
        queryParameters: {'limit': actualLimit, 'skip': skip},
      );

      // Validate response structure
      if (response.data is! Map<String, dynamic>) {
        throw FormatException('Invalid response format');
      }

      final productsData = response.data['products'];
      if (productsData is! List<dynamic>) {
        throw FormatException('Invalid products data format');
      }

      // Filter out any null or invalid product entries
      final validProducts = productsData
          .where((item) => item != null && item is Map<String, dynamic>)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .where((product) => product.id.isNotEmpty) // Only include products with valid IDs
          .toList();

      return validProducts;
    } catch (e) {
      throw _convertError(e);
    }
  }

  // Search products
  Future<List<Product>> searchProducts(
    String query, {
    int limit = 20, // Reduced default limit
    int skip = 0,
  }) async {
    try {
      // Limit the number of products fetched to improve performance
      final actualLimit = limit > 50 ? 50 : limit; // Increased max limit back to 50
      final response = await _dio.get(
        '/products/search',
        queryParameters: {'q': query, 'limit': actualLimit, 'skip': skip},
      );

      // Validate response structure
      if (response.data is! Map<String, dynamic>) {
        throw FormatException('Invalid response format');
      }

      final productsData = response.data['products'];
      if (productsData is! List<dynamic>) {
        throw FormatException('Invalid products data format');
      }

      // Filter out any null or invalid product entries
      final validProducts = productsData
          .where((item) => item != null && item is Map<String, dynamic>)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .where((product) => product.id.isNotEmpty) // Only include products with valid IDs
          .toList();

      return validProducts;
    } catch (e) {
      throw _convertError(e);
    }
  }

  // Fetch categories
  Future<List<String>> fetchCategories() async {
    // Try to load from cache first
    final cachedCategories = await _loadCategoriesFromCache();
    if (cachedCategories != null) {
      return cachedCategories;
    }

    try {
      final response = await _dio.get('/products/categories');
      
      // Validate response structure
      if (response.data is! List<dynamic>) {
        throw FormatException('Invalid categories data format');
      }

      // Filter out any null or non-string entries
      final categories = response.data
          .where((item) => item != null && item is String)
          .map((item) => item as String)
          .toList();

      // Save to cache
      await _saveCategoriesToCache(categories);
      return categories;
    } catch (e) {
      throw _convertError(e);
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

  // Fetch single product
  Future<Product> fetchProduct(String id) async {
    try {
      final response = await _dio.get('/products/$id');
      
      // Validate response structure
      if (response.data is! Map<String, dynamic>) {
        throw FormatException('Invalid product data format');
      }

      return Product.fromJson(response.data);
    } catch (e) {
      throw _convertError(e);
    }
  }

  // User authentication (mock for DummyJSON)
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );

      return response.data;
    } catch (e) {
      throw _convertError(e);
    }
  }

  // Get user profile (mock for DummyJSON)
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await _dio.get(
        '/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data;
    } catch (e) {
      throw _convertError(e);
    }
  }

  // Add to cart (mock - in real app this would sync with backend)
  Future<Map<String, dynamic>> addToCart(String productId, int quantity) async {
    try {
      final response = await _dio.post(
        '/carts/add',
        data: {
          'userId': 1, // Mock user ID
          'products': [
            {'id': productId, 'quantity': quantity},
          ],
        },
      );

      return response.data;
    } catch (e) {
      throw _convertError(e);
    }
  }

  // Get user carts
  Future<List<dynamic>> getUserCarts(String userId) async {
    try {
      final response = await _dio.get('/carts/user/$userId');
      return response.data['carts'];
    } catch (e) {
      throw _convertError(e);
    }
  }

  // Cancel request
  void cancelRequests() {
    _dio.close();
  }

  // Convert various error types to a consistent format
  Exception _convertError(dynamic error) {
    if (error is DioException) {
      // Provide more specific error messages
      if (error.type == DioExceptionType.connectionTimeout || 
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return Exception('Network timeout. Please check your connection and try again.');
      } else if (error.type == DioExceptionType.connectionError) {
        return Exception('Network connection error. Please check your internet connection.');
      } else if (error.type == DioExceptionType.badResponse) {
        if (error.response?.statusCode == 404) {
          return Exception('Product not found.');
        } else if (error.response?.statusCode == 500) {
          return Exception('Server error. Please try again later.');
        } else {
          return Exception('Server error (${error.response?.statusCode}). Please try again.');
        }
      }
      return Exception(error.error?.toString() ?? 'Network error occurred');
    } else if (error is FormatException) {
      return Exception('Data format error. Please try again.');
    } else {
      return Exception('An unexpected error occurred: ${error.toString()}');
    }
  }

  // Utility method to check internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return !connectivityResult.contains(ConnectivityResult.none);
    } catch (e) {
      // If we can't check connectivity, assume we have connection
      return true;
    }
  }

  // Test API connectivity
  Future<bool> testApiConnectivity() async {
    try {
      final response = await _dio.get('/products', queryParameters: {'limit': 1});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Retry mechanism for failed requests
  Future<T> retryRequest<T>(
    Future<T> Function() request, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        return await request();
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          rethrow;
        }
        await Future.delayed(delay * retryCount);
      }
    }

    throw Exception('Max retries exceeded');
  }

  // Batch request utility
  Future<List<T>> batchRequests<T>(
    List<Future<T> Function()> requests, {
    int concurrency = 3,
  }) async {
    final results = <T>[];

    for (int i = 0; i < requests.length; i += concurrency) {
      final batch = requests.skip(i).take(concurrency);
      final batchResults = await Future.wait(
        batch.map((request) => request()),
        eagerError: false,
      );
      results.addAll(batchResults);
    }

    return results;
  }
}