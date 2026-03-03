import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/cycle_log.dart';
import '../models/behavioral_data.dart';
import '../models/travel_data.dart';
import '../models/inference_response.dart';
import '../services/api_service.dart';
import '../services/local_db_service.dart';
import '../services/storage_service.dart';

/// Central state management provider for HerLuna.
/// Manages user, storage mode, data, and inference results.
class AppProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocalDbService _localDb = LocalDbService();

  // State
  User? _currentUser;
  String _storageMode = 'cloud';
  bool _isYoungGirlMode = false;
  bool _isLoading = false;
  String? _error;
  InferenceResponse? _inferenceResult;
  List<CycleLog> _cycleLogs = [];
  List<BehavioralData> _behavioralData = [];
  List<TravelData> _travelData = [];

  // Getters
  User? get currentUser => _currentUser;
  String get storageMode => _storageMode;
  bool get isYoungGirlMode => _isYoungGirlMode;
  bool get isLoading => _isLoading;
  String? get error => _error;
  InferenceResponse? get inferenceResult => _inferenceResult;
  List<CycleLog> get cycleLogs => _cycleLogs;
  List<BehavioralData> get behavioralData => _behavioralData;
  List<TravelData> get travelData => _travelData;
  bool get isCloudMode => _storageMode == 'cloud';

  /// Initialize from saved state
  Future<void> initialize() async {
    final mode = await StorageService.getStorageMode();
    if (mode != null) {
      _storageMode = mode;
    }
    final token = await StorageService.getToken();
    if (token != null) {
      _apiService.setToken(token);
    }
    notifyListeners();
  }

  /// Set storage mode
  Future<void> setStorageMode(String mode) async {
    _storageMode = mode;
    await StorageService.setStorageMode(mode);
    notifyListeners();
  }

  void setYoungGirlMode(bool value) {
    _isYoungGirlMode = value;
    notifyListeners();
  }

  // ── Auth ────────────────────────────────────────────────────────────

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final data = await _apiService.register(
        email: email,
        password: password,
        storageMode: _storageMode,
        isYoungGirlMode: _isYoungGirlMode,
      );
      _currentUser = User.fromJson(data['user']);
      await StorageService.setToken(data['access_token']);
      await StorageService.setUserId(_currentUser!.id);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final data = await _apiService.login(email: email, password: password);
      _currentUser = User.fromJson(data['user']);
      _storageMode = _currentUser!.storageMode;
      _isYoungGirlMode = _currentUser!.isYoungGirlMode;
      await StorageService.setToken(data['access_token']);
      await StorageService.setUserId(_currentUser!.id);
      await StorageService.setStorageMode(_storageMode);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _inferenceResult = null;
    _cycleLogs = [];
    _behavioralData = [];
    _travelData = [];
    await StorageService.clearAll();
    notifyListeners();
  }

  // ── Data Operations ──────────────────────────────────────────────────

  Future<void> addCycleLog(CycleLog log) async {
    _setLoading(true);
    try {
      if (isCloudMode) {
        await _apiService.addCycleLog(log);
      } else {
        await _localDb.insertCycleLog(log);
      }
      await fetchCycleLogs();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchCycleLogs() async {
    try {
      final userId = _currentUser?.id ?? 0;
      if (isCloudMode) {
        _cycleLogs = await _apiService.getCycleLogs(userId);
      } else {
        _cycleLogs = await _localDb.getCycleLogs(userId);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> addBehavioralData(BehavioralData data) async {
    _setLoading(true);
    try {
      if (isCloudMode) {
        await _apiService.addBehavioralData(data);
      } else {
        await _localDb.insertBehavioralData(data);
      }
      await fetchBehavioralData();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchBehavioralData() async {
    try {
      final userId = _currentUser?.id ?? 0;
      if (isCloudMode) {
        _behavioralData = await _apiService.getBehavioralData(userId);
      } else {
        _behavioralData = await _localDb.getBehavioralData(userId);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> addTravelData(TravelData data) async {
    _setLoading(true);
    try {
      if (isCloudMode) {
        await _apiService.addTravelData(data);
      } else {
        await _localDb.insertTravelData(data);
      }
      await fetchTravelData();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchTravelData() async {
    try {
      final userId = _currentUser?.id ?? 0;
      if (isCloudMode) {
        _travelData = await _apiService.getTravelData(userId);
      } else {
        _travelData = await _localDb.getTravelData(userId);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // ── Inference ────────────────────────────────────────────────────────

  Future<void> runInference() async {
    _setLoading(true);
    try {
      if (isCloudMode) {
        _inferenceResult = await _apiService.predictCloud(
          userId: _currentUser!.id,
          isYoungGirlMode: _isYoungGirlMode,
        );
      } else {
        // Local mode: fetch data from SQLite, send as snapshot
        final userId = _currentUser?.id ?? 0;
        final cycles = await _localDb.getCycleLogs(userId);
        final behavioral = await _localDb.getBehavioralData(userId);
        final travel = await _localDb.getTravelData(userId);

        _inferenceResult = await _apiService.predictLocal(
          cycleLogs: cycles,
          behavioralData: behavioral,
          travelData: travel,
          isYoungGirlMode: _isYoungGirlMode,
        );
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
