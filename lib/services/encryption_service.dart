import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class EncryptionService {
  // Generate random salt
  String _generateSalt([int length = 16]) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Encode(bytes);
  }

  // Hash password with salt
  String hashPassword(String password) {
    final salt = _generateSalt();
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return '$salt:${digest.toString()}';
  }

  // Verify password
  bool verifyPassword(String password, String hashedPassword) {
    try {
      final parts = hashedPassword.split(':');
      if (parts.length != 2) return false;

      final salt = parts[0];
      final hash = parts[1];

      final bytes = utf8.encode(password + salt);
      final digest = sha256.convert(bytes);

      return digest.toString() == hash;
    } catch (e) {
      return false;
    }
  }

  // Simple string encryption for session data
  String encryptString(String text) {
    final bytes = utf8.encode(text);
    final encoded = base64Encode(bytes);
    return encoded;
  }

  // Simple string decryption for session data
  String decryptString(String encryptedText) {
    try {
      final bytes = base64Decode(encryptedText);
      return utf8.decode(bytes);
    } catch (e) {
      return '';
    }
  }
}