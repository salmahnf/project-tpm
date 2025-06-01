class Constants {
  // Database
  static const String userBoxName = 'users';
  
  // Session
  static const String sessionKey = 'user_session';
  static const String isLoggedInKey = 'is_logged_in';
  
  // UI
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxUsernameLength = 20;
  
  // Messages
  static const String loginSuccess = 'Login berhasil!';
  static const String loginFailed = 'Username atau password salah!';
  static const String registerSuccess = 'Registrasi berhasil!';
  static const String registerFailed = 'Username sudah terdaftar!';
  static const String logoutSuccess = 'Logout berhasil!';
}