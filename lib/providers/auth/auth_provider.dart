import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutrisee/models/user_model.dart';
import 'package:nutrisee/services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final _service = FirebaseService.instance;

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _firebaseUser != null;
  bool get isProfileComplete => _userModel != null && _userModel!.name.isNotEmpty;
  String? get error => _error;

  AuthProvider() {
    _service.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user != null) {
      _userModel = await _service.getUserProfile(user.uid);
    } else {
      _userModel = null;
    }
    notifyListeners();
  }

  Future<bool> signUp(String email, String password, String name) async {
    _setLoading(true);
    try {
      final cred = await _service.signUp(email, password);
      final user = UserModel(
        uid: cred.user!.uid,
        email: email,
        name: name,
      );
      await _service.saveUserProfile(user);
      _userModel = user;
      _error = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      final cred = await _service.signIn(email, password);
      _userModel = await _service.getUserProfile(cred.user!.uid);
      _error = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    _userModel = null;
    notifyListeners();
  }

  Future<bool> updateProfile(UserModel updated) async {
    _setLoading(true);
    try {
      await _service.saveUserProfile(updated);
      _userModel = updated;
      _error = null;
      return true;
    } catch (e) {
      _error = 'Gagal menyimpan profil';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found': return 'Email tidak terdaftar';
      case 'wrong-password': return 'Password salah';
      case 'email-already-in-use': return 'Email sudah digunakan';
      case 'weak-password': return 'Password terlalu lemah (min 6 karakter)';
      case 'invalid-email': return 'Format email tidak valid';
      case 'invalid-credential': return 'Email atau password salah';
      default: return 'Terjadi kesalahan, coba lagi';
    }
  }
}