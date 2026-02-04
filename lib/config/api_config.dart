import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Use localhost for web, 10.0.2.2 for Android emulator
  static String get baseUrl => kIsWeb ? 'http://localhost/REPAIR_API' : 'http://10.0.2.2/REPAIR_API';
  
  // Auth endpoints
  static String get login => '$baseUrl/technician/login.php';
  static String get register => '$baseUrl/technician/register.php';
  static String get getProfile => '$baseUrl/technician/get_profile.php';
  static String get updateProfile => '$baseUrl/technician/update_profile.php';
  static String get checkCurrentJob => '$baseUrl/technician/check_current_job.php';
  
  // Technician endpoints
  static String get getAvailableJobs => '$baseUrl/technician/get_available_jobs.php';
  static String get acceptJob => '$baseUrl/technician/accept_job.php';
  static String get updateJobStatus => '$baseUrl/technician/update_job_status.php';
  static String get finishJob => '$baseUrl/technician/finish_job.php';
  static String get getJobHistory => '$baseUrl/technician/get_job_history.php';
  static String get setOnlineStatus => '$baseUrl/technician/toggle_online.php';
  static String get updateLocation => '$baseUrl/technician/update_location.php';
  static String get incomeDashboard => '$baseUrl/technician/income_dashboard.php';
  static String get stats => '$baseUrl/technician/stats.php';
  static String get notifications => '$baseUrl/technician/notifications.php';
  
  // Chat endpoints
  static String get sendMessage => '$baseUrl/chat/send_message.php';
  static String get getMessages => '$baseUrl/chat/get_messages.php';
  
  static const Duration connectionTimeout = Duration(seconds: 30);
}
