// import 'package:hive/hive.dart';
// import '../models/user_model.dart';
// import '../services/database_service.dart';

// class DebugService {
//   static final DatabaseService _databaseService = DatabaseService();

//   // Check if Hive is initialized and working
//   static Future<Map<String, dynamic>> getHiveStatus() async {
//     try {
//       final box = await _databaseService.userBox;
//       final allUsers = await _databaseService.getAllUsers();
      
//       return {
//         'isHiveInitialized': Hive.isBoxOpen('users'),
//         'boxName': box.name,
//         'boxPath': box.path,
//         'totalUsers': allUsers.length,
//         'usersList': allUsers.map((user) => {
//           'username': user.username,
//           'email': user.email,
//           'createdAt': user.createdAt.toString(),
//         }).toList(),
//         'status': 'Connected'
//       };
//     } catch (e) {
//       return {
//         'status': 'Error',
//         'error': e.toString(),
//       };
//     }
//   }

//   // Print database status to console
//   static Future<void> printDatabaseStatus() async {
//     final status = await getHiveStatus();
//     print('=== HIVE DATABASE STATUS ===');
//     status.forEach((key, value) {
//       print('$key: $value');
//     });
//     print('=========================');
//   }

//   // Get database file location
//   static Future<String> getDatabasePath() async {
//     try {
//       final box = await _databaseService.userBox;
//       return box.path ?? 'Path not available';
//     } catch (e) {
//       return 'Error: $e';
//     }
//   }

//   // Test database operations
//   static Future<bool> testDatabaseOperations() async {
//     try {
//       // Test write
//       final testUser = UserModel(
//         username: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
//         email: 'test@example.com',
//         password: 'test_password',
//         createdAt: DateTime.now(),
//       );
      
//       await _databaseService.saveUser(testUser);
//       print('✅ Write test: SUCCESS');
      
//       // Test read
//       final retrievedUser = await _databaseService.getUserByUsername(testUser.username);
//       if (retrievedUser != null) {
//         print('✅ Read test: SUCCESS');
//       } else {
//         print('❌ Read test: FAILED');
//         return false;
//       }
      
//       // Test delete
//       await _databaseService.deleteUser(testUser.username);
//       final deletedUser = await _databaseService.getUserByUsername(testUser.username);
//       if (deletedUser == null) {
//         print('✅ Delete test: SUCCESS');
//       } else {
//         print('❌ Delete test: FAILED');
//         return false;
//       }
      
//       print('✅ All database operations working correctly!');
//       return true;
//     } catch (e) {
//       print('❌ Database test failed: $e');
//       return false;
//     }
//   }
// }