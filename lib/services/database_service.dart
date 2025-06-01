import 'package:hive/hive.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class DatabaseService {
  Box<UserModel>? _userBox;

  Future<Box<UserModel>> get userBox async {
    if (_userBox != null && _userBox!.isOpen) {
      return _userBox!;
    }
    _userBox = await Hive.openBox<UserModel>(Constants.userBoxName);
    return _userBox!;
  }

  Future<void> saveUser(UserModel user) async {
    final box = await userBox;
    await box.put(user.username, user);
  }

  Future<UserModel?> getUserByUsername(String username) async {
    final box = await userBox;
    return box.get(username);
  }

  Future<List<UserModel>> getAllUsers() async {
    final box = await userBox;
    return box.values.toList();
  }

  Future<void> deleteUser(String username) async {
    final box = await userBox;
    await box.delete(username);
  }

  Future<void> clearAllUsers() async {
    final box = await userBox;
    await box.clear();
  }

  Future<void> closeBox() async {
    if (_userBox != null && _userBox!.isOpen) {
      await _userBox!.close();
    }
  }
}