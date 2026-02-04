import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class JobProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<JobModel> _availableJobs = [];
  List<JobModel> _history = [];
  JobModel? _currentJob;
  bool _isLoading = false;
  String _errorMessage = '';

  List<JobModel> get availableJobs => _availableJobs;
  List<JobModel> get history => _history;
  JobModel? get currentJob => _currentJob;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasActiveJob => _currentJob != null && _currentJob!.isActive;

  Future<void> loadAvailableJobs() async {
    _isLoading = true;
    notifyListeners();

    final response = await _api.get(ApiConfig.getAvailableJobs);

    _isLoading = false;

    if (response.success && response.data != null) {
      final dataList = response.data!['data'] as List? ?? [];
      _availableJobs = dataList.map((e) => JobModel.fromJson(e)).toList();
      
      // Find current active job
      _currentJob = _availableJobs.where((j) => j.isActive).firstOrNull;
    }
    notifyListeners();
  }

  Future<bool> acceptJob(int requestId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final response = await _api.post(ApiConfig.acceptJob, body: {'request_id': requestId});

    _isLoading = false;

    if (response.success) {
      await loadAvailableJobs();
      notifyListeners();
      return true;
    }

    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  Future<bool> updateJobStatus(int requestId, String status) async {
    final response = await _api.post(ApiConfig.updateJobStatus, body: {
      'request_id': requestId,
      'status': status,
    });

    if (response.success) {
      if (_currentJob?.requestId == requestId) {
        await loadAvailableJobs();
      }
      notifyListeners();
      return true;
    }

    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  Future<bool> finishJob(int requestId, double price, {String? notes}) async {
    _isLoading = true;
    notifyListeners();

    final response = await _api.post(ApiConfig.finishJob, body: {
      'request_id': requestId,
      'price': price,
      if (notes != null) 'notes': notes,
    });

    _isLoading = false;

    if (response.success) {
      _currentJob = null;
      await loadAvailableJobs();
      notifyListeners();
      return true;
    }

    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  Future<void> loadHistory({int page = 1}) async {
    _isLoading = true;
    notifyListeners();

    final response = await _api.get(ApiConfig.getJobHistory, queryParams: {'page': page.toString()});

    _isLoading = false;

    if (response.success && response.data != null) {
      final dataList = response.data!['data'] as List? ?? [];
      if (page == 1) {
        _history = dataList.map((e) => JobModel.fromJson(e)).toList();
      } else {
        _history.addAll(dataList.map((e) => JobModel.fromJson(e)));
      }
    }
    notifyListeners();
  }

  void clearCurrentJob() {
    _currentJob = null;
    notifyListeners();
  }
}
