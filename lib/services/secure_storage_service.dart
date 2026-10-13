import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../models/card_model.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // User credentials management
  Future<bool> registerUser(String username, String password) async {
    final existingUser = await _storage.read(key: 'user_$username');
    if (existingUser != null) {
      return false; // User already exists
    }
    final user = UserModel(username: username, password: password);
    await _storage.write(key: 'user_$username', value: jsonEncode(user.toJson()));
    return true;
  }

  Future<UserModel?> authenticateUser(String username, String password) async {
    final userData = await _storage.read(key: 'user_$username');
    if (userData == null) return null;

    try {
      final user = UserModel.fromJson(jsonDecode(userData) as Map<String, dynamic>);
      if (user.password == password) {
        return user;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  // Active session tracking
  Future<void> saveActiveSession(String username) async {
    await _storage.write(key: 'active_session', value: username);
  }

  Future<String?> getActiveSession() async {
    return await _storage.read(key: 'active_session');
  }

  Future<void> clearActiveSession() async {
    await _storage.delete(key: 'active_session');
  }

  // Cards management
  Future<List<CardModel>> getCards(String username) async {
    final cardsData = await _storage.read(key: 'cards_$username');
    if (cardsData == null) return [];

    try {
      final List<dynamic> decodedList = jsonDecode(cardsData) as List<dynamic>;
      return decodedList
          .map((item) => CardModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCards(String username, List<CardModel> cards) async {
    final listMap = cards.map((card) => card.toJson()).toList();
    await _storage.write(key: 'cards_$username', value: jsonEncode(listMap));
  }

  // Categories management
  Future<List<String>> getCategories(String username) async {
    final data = await _storage.read(key: 'categories_$username');
    if (data == null) return [];
    try {
      final List<dynamic> decodedList = jsonDecode(data) as List<dynamic>;
      return decodedList
          .whereType<String>()
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCategories(String username, List<String> categories) async {
    await _storage.write(
      key: 'categories_$username',
      value: jsonEncode(categories),
    );
  }
}
