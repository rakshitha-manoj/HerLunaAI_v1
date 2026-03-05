import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure local storage for auth tokens and user preferences.
class StorageService {
  static const _storage = FlutterSecureStorage();

  // Keys
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _emailKey = 'user_email';
  static const _nameKey = 'user_name';
  static const _storageModeKey = 'storage_mode';
  static const _ageRangeKey = 'age_range';
  static const _activityKey = 'activity_pattern';
  static const _onboardingCompleteKey = 'onboarding_complete';

  // ── Token ─────────────────────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // ── User Info ─────────────────────────────────────────────────────────

  static Future<void> saveUserId(dynamic id) async {
    await _storage.write(key: _userIdKey, value: id.toString());
  }

  static Future<int?> getUserId() async {
    final val = await _storage.read(key: _userIdKey);
    return val != null ? int.tryParse(val) : null;
  }

  static Future<void> saveEmail(String email) async {
    await _storage.write(key: _emailKey, value: email);
  }

  static Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  static Future<void> saveName(String name) async {
    await _storage.write(key: _nameKey, value: name);
  }

  static Future<String?> getName() async {
    return await _storage.read(key: _nameKey);
  }

  // ── Storage Mode ──────────────────────────────────────────────────────

  static Future<void> saveStorageMode(String mode) async {
    await _storage.write(key: _storageModeKey, value: mode);
  }

  static Future<String> getStorageMode() async {
    return await _storage.read(key: _storageModeKey) ?? 'cloud';
  }

  // ── Profile ───────────────────────────────────────────────────────────

  static Future<void> saveAgeRange(String ageRange) async {
    await _storage.write(key: _ageRangeKey, value: ageRange);
  }

  static Future<String?> getAgeRange() async {
    return await _storage.read(key: _ageRangeKey);
  }

  static Future<void> saveActivity(String activity) async {
    await _storage.write(key: _activityKey, value: activity);
  }

  static Future<String?> getActivity() async {
    return await _storage.read(key: _activityKey);
  }

  // ── Onboarding ────────────────────────────────────────────────────────

  static Future<void> setOnboardingComplete(bool value) async {
    await _storage.write(
        key: _onboardingCompleteKey, value: value.toString());
  }

  static Future<bool> isOnboardingComplete() async {
    final val = await _storage.read(key: _onboardingCompleteKey);
    return val == 'true';
  }

  // ── Clear All ─────────────────────────────────────────────────────────

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
