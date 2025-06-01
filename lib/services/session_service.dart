import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'encryption_service.dart';

class SessionService {
  static final EncryptionService _encryptionService = EncryptionService();
  static const String _sessionBoxName = 'sessionBox';
  static const String _keyUser = 'user';
  static const String _keyLoggedIn = 'isLoggedIn';

  /// Simpan sesi login ke Hive
  static Future<void> saveSession(UserModel user) async {
    final box = await Hive.openBox(_sessionBoxName);
    final userData = jsonEncode(user.toJson());
    final encryptedData = _encryptionService.encryptString(userData);

    await box.put(_keyUser, encryptedData);
    await box.put(_keyLoggedIn, true);
  }

  /// Ambil user saat ini
  static Future<UserModel?> getCurrentUser() async {
    try {
      final box = await Hive.openBox(_sessionBoxName);
      final encryptedData = box.get(_keyUser);

      if (encryptedData == null) return null;

      final decrypted = _encryptionService.decryptString(encryptedData);
      final userJson = jsonDecode(decrypted);
      return UserModel.fromJson(userJson);
    } catch (e) {
      print('Gagal ambil user: $e');
      return null;
    }
  }

  /// Cek apakah sudah login
  static Future<bool> isLoggedIn() async {
    final box = await Hive.openBox(_sessionBoxName);
    final loggedIn = box.get(_keyLoggedIn, defaultValue: false);

    if (!loggedIn) return false;

    final currentUser = await getCurrentUser();
    return currentUser != null;
  }

  /// Hapus sesi login
  static Future<void> clearSession() async {
    final box = await Hive.openBox(_sessionBoxName);
    await box.delete(_keyUser);
    await box.put(_keyLoggedIn, false);
  }

  /// Update user session
  static Future<void> updateSession(UserModel user) async {
    await saveSession(user);
  }
}
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/user_model.dart';
// import '../utils/constants.dart';
// import 'encryption_service.dart';

// class SessionService {
//   static final EncryptionService _encryptionService = EncryptionService();

//   static Future<void> saveSession(UserModel user) async {
//     final prefs = await SharedPreferences.getInstance();
//     final userData = jsonEncode(user.toJson());
//     final encryptedData = _encryptionService.encryptString(userData);
    
//     await prefs.setString(Constants.sessionKey, encryptedData);
//     await prefs.setBool(Constants.isLoggedInKey, true);
//   }

//   static Future<UserModel?> getCurrentUser() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final encryptedData = prefs.getString(Constants.sessionKey);
      
//       if (encryptedData == null) return null;
      
//       final userData = _encryptionService.decryptString(encryptedData);
//       if (userData.isEmpty) return null;
      
//       final userJson = jsonDecode(userData);
//       return UserModel.fromJson(userJson);
//     } catch (e) {
//       print('Get current user error: $e');
//       return null;
//     }
//   }

//   static Future<bool> isLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     final isLoggedIn = prefs.getBool(Constants.isLoggedInKey) ?? false;
    
//     if (!isLoggedIn) return false;
    
//     // Verify session data exists and is valid
//     final currentUser = await getCurrentUser();
//     return currentUser != null;
//   }

//   static Future<void> clearSession() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(Constants.sessionKey);
//     await prefs.setBool(Constants.isLoggedInKey, false);
//   }

//   static Future<void> updateSession(UserModel user) async {
//     await saveSession(user);
//   }
// }