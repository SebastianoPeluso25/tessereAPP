import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/secure_storage_service.dart';

class AuthViewModel extends ChangeNotifier {
  final SecureStorageService _storageService;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthViewModel(this._storageService) {
    _checkSession();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  Future<void> _checkSession() async {
    _setLoading(true);
    final activeUser = await _storageService.getActiveSession();
    if (activeUser != null) {
      // Just mock user restoration or load fully if needed. Since we only save username as session:
      _currentUser = UserModel(username: activeUser, password: '');
    }
    _setLoading(false);
  }

  Future<bool> signup(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      _setError('I campi non possono essere vuoti');
      return false;
    }
    _setLoading(true);
    _setError(null);
    final success = await _storageService.registerUser(username, password);
    _setLoading(false);
    if (!success) {
      _setError('Nome utente già registrato');
    }
    return success;
  }

  Future<bool> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      _setError('I campi non possono essere vuoti');
      return false;
    }
    _setLoading(true);
    _setError(null);
    final user = await _storageService.authenticateUser(username, password);
    _setLoading(false);
    if (user != null) {
      _currentUser = user;
      await _storageService.saveActiveSession(username);
      notifyListeners();
      return true;
    } else {
      _setError('Credenziali non valide');
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await _storageService.clearActiveSession();
    _currentUser = null;
    _setLoading(false);
  }
}
