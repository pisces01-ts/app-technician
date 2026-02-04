import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class LocationProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
  Position? _currentPosition;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasPermission = false;
  Timer? _locationTimer;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasPermission => _hasPermission;
  bool get hasLocation => _currentPosition != null;
  double get latitude => _currentPosition?.latitude ?? 0;
  double get longitude => _currentPosition?.longitude ?? 0;

  Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _errorMessage = 'กรุณาเปิด Location Service';
      _hasPermission = false;
      notifyListeners();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _errorMessage = 'กรุณาอนุญาตการเข้าถึงตำแหน่ง';
        _hasPermission = false;
        notifyListeners();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _errorMessage = 'กรุณาเปิดการเข้าถึงตำแหน่งในการตั้งค่า';
      _hasPermission = false;
      notifyListeners();
      return false;
    }

    _hasPermission = true;
    notifyListeners();
    return true;
  }

  Future<bool> getCurrentLocation() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'ไม่สามารถระบุตำแหน่งได้';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void startLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateLocationToServer();
    });
  }

  void stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  Future<void> _updateLocationToServer() async {
    if (_currentPosition == null) {
      await getCurrentLocation();
    }
    
    if (_currentPosition != null) {
      await _api.post(ApiConfig.updateLocation, body: {
        'lat': _currentPosition!.latitude,
        'lng': _currentPosition!.longitude,
      });
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }
}
