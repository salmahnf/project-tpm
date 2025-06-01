import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';
import '../services/session_service.dart';

class AuthController {
  static final DatabaseService _databaseService = DatabaseService();
  static final EncryptionService _encryptionService = EncryptionService();

  static Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      print('🔄 Starting registration for username: $username');

      // Check if user already exists
      final existingUser = await _databaseService.getUserByUsername(username);
      if (existingUser != null) {
        print('❌ Registration failed: User already exists');
        return false; // User already exists
      }

      // Encrypt password
      final encryptedPassword = _encryptionService.hashPassword(password);
      print('🔐 Password encrypted successfully');

      // Create user
      final user = UserModel(
        username: username,
        email: email,
        password: encryptedPassword,
        createdAt: DateTime.now(),
      );

      // Save user to database
      await _databaseService.saveUser(user);
      print('✅ User saved to Hive database successfully');
      print('📊 Registration completed for: $username');
      return true;
    } catch (e) {
      print('❌ Registration error: $e');
      return false;
    }
  }

  static Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      print('🔄 Starting login for username: $username');

      // Get user from database
      final user = await _databaseService.getUserByUsername(username);
      if (user == null) {
        print('❌ Login failed: User not found in database');
        return false; // User not found
      }
      print('👤 User found in database');

      // Verify password
      final isPasswordValid =
          _encryptionService.verifyPassword(password, user.password);
      if (!isPasswordValid) {
        print('❌ Login failed: Invalid password');
        return false; // Wrong password
      }
      print('🔐 Password verification successful');

      // Save session
      await SessionService.saveSession(user);
      print('💾 Session saved successfully');
      print('✅ Login completed for: $username');
      return true;
    } catch (e) {
      print('❌ Login error: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    await SessionService.clearSession();
  }

  static Future<UserModel?> getCurrentUser() async {
    return await SessionService.getCurrentUser();
  }
}
