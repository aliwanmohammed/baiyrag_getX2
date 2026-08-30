import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/models/user_model.dart';

/// Secure persistence for Sanctum token and cached user profile.
class SecureStorageService {
  SecureStorageService._();

  static final SecureStorageService instance = SecureStorageService._();

  static const _tokenKey = '_bhm_access_token';
  static const _languageKey = '_bhm_language';
  static const _userRoleKey = '_bhm_user_role';
  static const _userIdKey = '_bhm_user_id';
  static const _userProfileKey = '_bhm_user_profile';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(),
  );

  Future<bool> isLoggedIn() async {
    final token = await readToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> readToken() async => _storage.read(key: _tokenKey);

  Future<void> deleteToken() async => _storage.delete(key: _tokenKey);

  Future<void> saveRole(String role) async {
    await _storage.write(key: _userRoleKey, value: role);
  }

  Future<String?> readRole() async => _storage.read(key: _userRoleKey);

  Future<void> saveUserId(String id) async {
    await _storage.write(key: _userIdKey, value: id);
  }

  Future<String?> readUserId() async => _storage.read(key: _userIdKey);

  /// Persists profile fields for guest-editable profile screen.
  Future<void> saveUserProfile(UserModel user) async {
    if (user.token != null) {
      await saveToken(user.token!);
    }
    await saveUserId(user.id);
    await saveRole(user.role.name);
    await _storage.write(
      key: _userProfileKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<UserModel?> loadUserProfile() async {
    final raw = await _storage.read(key: _userProfileKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final token = await readToken();
      return UserModel.fromJson({...map, 'token': token});
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLanguage(String languageCode) async {
    await _storage.write(key: _languageKey, value: languageCode);
  }

  Future<String> readLanguage() async {
    return await _storage.read(key: _languageKey) ?? 'ar';
  }

  Future<void> clearAll() async => _storage.deleteAll();
}
