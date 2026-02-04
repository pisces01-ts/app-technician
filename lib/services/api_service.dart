import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  void setToken(String? token) => _token = token;
  String? get token => _token;

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<ApiResponse<Map<String, dynamic>>> get(String url, {Map<String, String>? queryParams}) async {
    try {
      Uri uri = Uri.parse(url);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(uri, headers: _headers).timeout(ApiConfig.connectionTimeout);
      return _handleResponse(response);
    } on SocketException {
      return ApiResponse(success: false, message: 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้', statusCode: 0);
    } catch (e) {
      return ApiResponse(success: false, message: 'เกิดข้อผิดพลาด: ${e.toString()}', statusCode: 0);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> post(String url, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(ApiConfig.connectionTimeout);
      return _handleResponse(response);
    } on SocketException {
      return ApiResponse(success: false, message: 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้', statusCode: 0);
    } catch (e) {
      return ApiResponse(success: false, message: 'เกิดข้อผิดพลาด: ${e.toString()}', statusCode: 0);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> uploadFile(String url, File file, {String fieldName = 'image', Map<String, String>? fields}) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      if (_token != null) request.headers['Authorization'] = 'Bearer $_token';
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
      if (fields != null) request.fields.addAll(fields);

      final streamedResponse = await request.send().timeout(ApiConfig.connectionTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(success: false, message: 'เกิดข้อผิดพลาด: ${e.toString()}', statusCode: 0);
    }
  }

  ApiResponse<Map<String, dynamic>> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final success = body['success'] == true;
      return ApiResponse(
        success: success,
        message: body['message'] ?? (success ? 'สำเร็จ' : 'เกิดข้อผิดพลาด'),
        data: body,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'ไม่สามารถประมวลผลข้อมูลได้', statusCode: response.statusCode);
    }
  }
}
