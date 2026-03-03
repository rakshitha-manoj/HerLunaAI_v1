import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages storage mode selection (cloud/local) via secure storage.
class StorageService {
  static const _storage = FlutterSecureStorage();
  static const _modeKey = 'herluna_storage_mode';
  static const _tokenKey = 'herluna_auth_token';
  static const _userIdKey = 'herluna_user_id';

  /// Save storage mode (persists across launches)
  static Future<void> setStorageMode(String mode) async {
    await _storage.write(key: _modeKey, value: mode);
  }

  /// Get saved storage mode
  static Future<String?> getStorageMode() async {
    return await _storage.read(key: _modeKey);
  }

  /// Save auth token
  static Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Get auth token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Save user ID
  static Future<void> setUserId(int userId) async {
    await _storage.write(key: _userIdKey, value: userId.toString());
  }

  /// Get user ID
  static Future<int?> getUserId() async {
    final val = await _storage.read(key: _userIdKey);
    return val != null ? int.tryParse(val) : null;
  }

  /// Clear all stored data (logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Check if mode has been selected
  static Future<bool> isModeSelected() async {
    final mode = await getStorageMode();
    return mode != null && mode.isNotEmpty;
  }
}
