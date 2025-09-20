import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late Box _userBox;
  static late Box _cartBox;
  static late Box _settingsBox;
  static late SharedPreferences _prefs;

  static const String userBoxName = 'user_data';
  static const String cartBoxName = 'cart_data';
  static const String settingsBoxName = 'settings_data';

  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Open boxes
    _userBox = await Hive.openBox(userBoxName);
    _cartBox = await Hive.openBox(cartBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);

    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();
  }

  // User data operations
  static Future<void> saveUserData(String key, dynamic value) async {
    await _userBox.put(key, value);
  }

  static T? getUserData<T>(String key) {
    return _userBox.get(key) as T?;
  }

  static Future<void> removeUserData(String key) async {
    await _userBox.delete(key);
  }

  static Future<void> clearUserData() async {
    await _userBox.clear();
  }

  // Cart data operations
  static Future<void> saveCartData(String key, dynamic value) async {
    await _cartBox.put(key, value);
  }

  static T? getCartData<T>(String key) {
    return _cartBox.get(key) as T?;
  }

  static Future<void> removeCartData(String key) async {
    await _cartBox.delete(key);
  }

  static Future<void> clearCartData() async {
    await _cartBox.clear();
  }

  // Settings operations
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  static T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  static Future<void> removeSetting(String key) async {
    await _settingsBox.delete(key);
  }

  // SharedPreferences operations
  static Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  static Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  static Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  static Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  static Future<void> clear() async {
    await _prefs.clear();
  }

  // Auth session management
  static Future<void> saveAuthToken(String token) async {
    await setString('auth_token', token);
  }

  static String? getAuthToken() {
    return getString('auth_token');
  }

  static Future<void> clearAuthToken() async {
    await remove('auth_token');
  }

  static Future<void> saveUserSession(Map<String, dynamic> userData) async {
    await saveUserData('current_user', userData);
  }

  static Map<String, dynamic>? getUserSession() {
    return getUserData<Map<String, dynamic>>('current_user');
  }

  static Future<void> clearUserSession() async {
    await removeUserData('current_user');
    await clearAuthToken();
  }

  // Cart persistence
  static Future<void> saveCartItems(
    List<Map<String, dynamic>> cartItems,
  ) async {
    await saveCartData('cart_items', cartItems);
  }

  static List<Map<String, dynamic>>? getCartItems() {
    final items = getCartData<List>('cart_items');
    return items?.cast<Map<String, dynamic>>();
  }

  static Future<void> clearCart() async {
    await removeCartData('cart_items');
  }

  // Theme and settings persistence
  static Future<void> saveThemeMode(int themeModeIndex) async {
    await saveSetting('theme_mode', themeModeIndex);
  }

  static int? getThemeMode() {
    return getSetting<int>('theme_mode');
  }

  // Favorites persistence
  static Future<void> saveFavorites(List<String> favoriteIds) async {
    await saveUserData('favorites', favoriteIds);
  }

  static List<String>? getFavorites() {
    final favorites = getUserData<List>('favorites');
    return favorites?.cast<String>();
  }

  static Future<void> clearFavorites() async {
    await removeUserData('favorites');
  }

  // Search history
  static Future<void> saveSearchHistory(List<String> searchHistory) async {
    await saveSetting('search_history', searchHistory);
  }

  static List<String>? getSearchHistory() {
    final history = getSetting<List>('search_history');
    return history?.cast<String>();
  }

  static Future<void> clearSearchHistory() async {
    await removeSetting('search_history');
  }

  // Notification preferences
  static Future<void> saveNotificationEnabled(bool enabled) async {
    await saveSetting('notifications_enabled', enabled);
  }

  static bool getNotificationEnabled() {
    return getSetting<bool>('notifications_enabled') ?? true;
  }

  // First launch check
  static Future<void> markFirstLaunchCompleted() async {
    await setBool('first_launch_completed', true);
  }

  static bool isFirstLaunch() {
    return getBool('first_launch_completed') != true;
  }

  // App version tracking
  static Future<void> saveAppVersion(String version) async {
    await setString('app_version', version);
  }

  static String? getAppVersion() {
    return getString('app_version');
  }
}
