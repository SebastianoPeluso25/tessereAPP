import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../services/secure_storage_service.dart';

class CardViewModel extends ChangeNotifier {
  final SecureStorageService _storageService;
  List<CardModel> _cards = [];
  List<String> _categories = [];
  bool _isLoading = false;

  CardViewModel(this._storageService);

  List<CardModel> get cards => _cards;
  List<CardModel> get favoriteCards => _cards.where((c) => c.isFavorite).toList();
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCards(String username) async {
    _isLoading = true;
    notifyListeners();
    _cards = await _storageService.getCards(username);
    _categories = await _storageService.getCategories(username);
    if (_categories.isEmpty) {
      _categories = ['Supermercati', 'Animali', 'Negozi'];
      await _storageService.saveCategories(username, _categories);
    }
    final cardCategories = _cards
        .map((c) => c.category)
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();
    bool changed = false;
    for (final c in cardCategories) {
      if (!_categories.contains(c)) {
        _categories.add(c);
        changed = true;
      }
    }
    if (changed) {
      await _storageService.saveCategories(username, _categories);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCard(String username, CardModel card) async {
    _cards.add(card);
    await _storageService.saveCards(username, _cards);
    final category = card.category?.trim();
    if (category != null &&
        category.isNotEmpty &&
        !_categories.contains(category)) {
      _categories.add(category);
      await _storageService.saveCategories(username, _categories);
    }
    notifyListeners();
  }

  Future<void> removeCard(String username, String cardId) async {
    _cards.removeWhere((c) => c.id == cardId);
    await _storageService.saveCards(username, _cards);
    notifyListeners();
  }
  Future<void> toggleFavorite(String username, String cardId) async {
    final cardIndex = _cards.indexWhere((c) => c.id == cardId);
    if (cardIndex != -1) {
      final card = _cards[cardIndex];
      final updatedCard = CardModel(
        id: card.id,
        title: card.title,
        barcode: card.barcode,
        barcodeFormat: card.barcodeFormat,
        colorHex: card.colorHex,
        notes: card.notes,
        isFavorite: !card.isFavorite,
        category: card.category,
      );
      _cards[cardIndex] = updatedCard;
      await _storageService.saveCards(username, _cards);
      notifyListeners();
    }
  }

  List<CardModel> cardsByCategory(String category) {
    return _cards.where((c) => c.category == category).toList();
  }

  Future<void> addCategory(String username, String name) async {
    final normalized = name.trim();
    if (normalized.isEmpty) return;
    if (_categories.any((c) => c.toLowerCase() == normalized.toLowerCase())) {
      return;
    }
    _categories.add(normalized);
    await _storageService.saveCategories(username, _categories);
    notifyListeners();
  }

  Future<void> reorderCategories(
    String username,
    int oldIndex,
    int newIndex,
  ) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _categories.removeAt(oldIndex);
    _categories.insert(newIndex, item);
    await _storageService.saveCategories(username, _categories);
    notifyListeners();
  }

  Future<void> removeCategory(String username, String category) async {
    _categories.removeWhere((c) => c == category);
    for (int i = 0; i < _cards.length; i++) {
      final card = _cards[i];
      if (card.category == category) {
        _cards[i] = CardModel(
          id: card.id,
          title: card.title,
          barcode: card.barcode,
          barcodeFormat: card.barcodeFormat,
          colorHex: card.colorHex,
          notes: card.notes,
          isFavorite: card.isFavorite,
          category: null,
        );
      }
    }
    await _storageService.saveCards(username, _cards);
    await _storageService.saveCategories(username, _categories);
    notifyListeners();
  }

  Future<void> renameCategory(
    String username,
    String oldName,
    String newName,
  ) async {
    final normalized = newName.trim();
    if (normalized.isEmpty) return;
    if (normalized.toLowerCase() == oldName.toLowerCase()) return;
    if (_categories.any((c) => c.toLowerCase() == normalized.toLowerCase())) {
      return;
    }

    final index = _categories.indexWhere((c) => c == oldName);
    if (index == -1) return;
    _categories[index] = normalized;

    for (int i = 0; i < _cards.length; i++) {
      final card = _cards[i];
      if (card.category == oldName) {
        _cards[i] = CardModel(
          id: card.id,
          title: card.title,
          barcode: card.barcode,
          barcodeFormat: card.barcodeFormat,
          colorHex: card.colorHex,
          notes: card.notes,
          isFavorite: card.isFavorite,
          category: normalized,
        );
      }
    }

    await _storageService.saveCards(username, _cards);
    await _storageService.saveCategories(username, _categories);
    notifyListeners();
  }

  Future<void> setCardCategory(
    String username,
    String cardId,
    String? category,
  ) async {
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index == -1) return;
    final normalized = category?.trim();
    final nextCategory = (normalized == null || normalized.isEmpty)
        ? null
        : normalized;
    final card = _cards[index];
    final updatedCard = CardModel(
      id: card.id,
      title: card.title,
      barcode: card.barcode,
      barcodeFormat: card.barcodeFormat,
      colorHex: card.colorHex,
      notes: card.notes,
      isFavorite: card.isFavorite,
      category: nextCategory,
    );
    _cards[index] = updatedCard;
    await _storageService.saveCards(username, _cards);
    if (nextCategory != null && !_categories.contains(nextCategory)) {
      _categories.add(nextCategory);
      await _storageService.saveCategories(username, _categories);
    }
    notifyListeners();
  }

  Future<void> reorderCardsInCategory(
    String username,
    String category,
    int oldIndex,
    int newIndex,
  ) async {
    final indices = <int>[];
    for (int i = 0; i < _cards.length; i++) {
      if (_cards[i].category == category) indices.add(i);
    }
    if (indices.isEmpty) return;
    if (newIndex > oldIndex) newIndex -= 1;
    final categoryCards = indices.map((i) => _cards[i]).toList();
    final moved = categoryCards.removeAt(oldIndex);
    categoryCards.insert(newIndex, moved);
    for (int j = 0; j < indices.length; j++) {
      _cards[indices[j]] = categoryCards[j];
    }
    await _storageService.saveCards(username, _cards);
    notifyListeners();
  }
}
