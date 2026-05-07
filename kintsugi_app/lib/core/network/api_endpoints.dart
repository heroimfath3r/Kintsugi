class ApiEndpoints {
  ApiEndpoints._();
  static const String baseUrl = 'http://10.0.2.2:3000';
  static const String register = '/api/auth/register';
  static const String profile = '/api/auth/profile';
  static const String archetype = '/api/auth/archetype';
  static const String checkin = '/api/checkin';
  static const String checkinToday = '/api/checkin/today';
  static const String checkinHistory = '/api/checkin/history';
  static const String misionDaily = '/api/misiones/daily';
  static String misionComplete(String id) => '/api/misiones/$id/complete';
  static const String misionHistory = '/api/misiones/history';
  static const String progreso = '/api/progreso';
  static const String progresoWeekly = '/api/progreso/weekly';
  static const String health = '/api/health';
}
