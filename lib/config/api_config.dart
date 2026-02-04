class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2/REPAIR_API';
  
  // Auth endpoints
  static const String login = '$baseUrl/auth/login.php';
  static const String register = '$baseUrl/auth/register_technician.php';
  static const String getProfile = '$baseUrl/auth/get_user_profile.php';
  static const String updateProfile = '$baseUrl/auth/update_profile.php';
  static const String checkCurrentJob = '$baseUrl/auth/check_current_job.php';
  
  // Technician endpoints
  static const String getAvailableJobs = '$baseUrl/technician/get_available_jobs.php';
  static const String acceptJob = '$baseUrl/technician/accept_job.php';
  static const String updateJobStatus = '$baseUrl/technician/update_job_status.php';
  static const String finishJob = '$baseUrl/technician/finish_job.php';
  static const String getJobHistory = '$baseUrl/technician/get_job_history.php';
  static const String setOnlineStatus = '$baseUrl/technician/set_online_status.php';
  static const String updateLocation = '$baseUrl/technician/update_location.php';
  static const String incomeDashboard = '$baseUrl/technician/income_dashboard.php';
  static const String stats = '$baseUrl/technician/stats.php';
  static const String notifications = '$baseUrl/technician/notifications.php';
  static const String profile = '$baseUrl/technician/profile.php';
  
  static const Duration connectionTimeout = Duration(seconds: 30);
}
