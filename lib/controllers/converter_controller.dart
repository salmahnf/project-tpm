import 'dart:convert';
import 'package:http/http.dart' as http;

class ConverterController {
  // Simulasi exchange rate (dalam aplikasi nyata, gunakan API seperti exchangerate-api.com)
  static const Map<String, double> _exchangeRates = {
    'USD': 1.0,
    'IDR': 15300.0,
    'EUR': 0.85,
    'GBP': 0.73,
    'JPY': 110.0,
    'SGD': 1.35,
    'MYR': 4.15,
  };

  // Mapping timezone ke Duration offset dari UTC
  // Note: New York menggunakan EDT (UTC-4) pada musim panas, bukan EST (UTC-5)
  static const Map<String, Duration> _timezoneOffsets = {
    'Jakarta (WIB)': Duration(hours: 7),
    'New York (EST)': Duration(hours: -4), // EDT pada Juni = UTC-4
    'London (GMT)': Duration(hours: 1), // BST pada Juni = UTC+1
    'Tokyo (JST)': Duration(hours: 9),
    'Sydney (AEDT)': Duration(hours: 10), // AEST pada Juni = UTC+10
    'Dubai (GST)': Duration(hours: 4),
    'Singapore (SGT)': Duration(hours: 8),
  };

  static Future<String> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      Map<String, double> rates = await fetchRealTimeRates();

      String fromCode = fromCurrency.split(' - ')[0];
      String toCode = toCurrency.split(' - ')[0];

      if (fromCode == toCode) {
        return '$amount $toCode = $amount $toCode';
      }

      print('Rates from API: $rates');
      print('From: $fromCode, To: $toCode');

      double usdAmount = amount / rates[fromCode]!;
      double convertedAmount = usdAmount * rates[toCode]!;

      print('USD amount: $usdAmount');
      print('Converted amount (before formatting): $convertedAmount');

      String formattedResult;
      if (convertedAmount >= 1000) {
        formattedResult = convertedAmount.toStringAsFixed(0);
      } else if (convertedAmount >= 1) {
        formattedResult = convertedAmount.toStringAsFixed(2);
      } else {
        formattedResult = convertedAmount.toStringAsFixed(4);
      }

      return '$amount $fromCode = $formattedResult $toCode';
    } catch (e) {
      throw Exception('Failed to convert currency: $e');
    }
  }

  static Future<String> convertTimezone({
    required String dateTime,
    required String fromTimezone,
    required String toTimezone,
  }) async {
    try {
      // Simulasi delay API call
      await Future.delayed(Duration(milliseconds: 300));

      // Parse input datetime menggunakan DateTime.parse setelah konversi format
      DateTime inputDateTime = _parseDateTime(dateTime);

      // Get timezone offsets menggunakan Duration
      Duration fromOffset = _timezoneOffsets[fromTimezone] ?? Duration.zero;
      Duration toOffset = _timezoneOffsets[toTimezone] ?? Duration.zero;

      // Konversi ke UTC terlebih dahulu
      DateTime utcDateTime = inputDateTime.subtract(fromOffset);

      // Lalu konversi ke target timezone
      DateTime targetDateTime = utcDateTime.add(toOffset);

      // Format hasil menggunakan built-in DateTime methods
      String formattedResult = _formatDateTime(targetDateTime, toTimezone);

      return formattedResult;
    } catch (e) {
      throw Exception('Failed to convert timezone: $e');
    }
  }

  // Helper method untuk parsing datetime dari format dd/MM/yyyy HH:mm
  static DateTime _parseDateTime(String dateTimeString) {
    try {
      List<String> parts = dateTimeString.split(' ');
      if (parts.length != 2) {
        throw FormatException('Invalid datetime format');
      }

      List<String> dateParts = parts[0].split('/');
      List<String> timeParts = parts[1].split(':');

      if (dateParts.length != 3 || timeParts.length != 2) {
        throw FormatException('Invalid datetime format');
      }

      int day = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);
      int year = int.parse(dateParts[2]);
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      throw FormatException('Error parsing datetime: $e');
    }
  }

  // Helper method untuk format datetime
  static String _formatDateTime(DateTime dateTime, String timezone) {
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = dateTime.month.toString().padLeft(2, '0');
    String year = dateTime.year.toString();
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute ($timezone)';
  }

  // Method untuk mendapatkan exchange rate real-time (opsional)
  static Future<Map<String, double>> fetchRealTimeRates() async {
    try {
      // Contoh menggunakan API gratis (ganti dengan API key yang valid)
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        Map<String, double> rates = {};

        data['rates'].forEach((key, value) {
          rates[key] = value.toDouble();
        });

        return rates;
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      // Fallback ke static rates jika API gagal
      return _exchangeRates;
    }
  }

  // Method untuk validasi input
  static bool isValidAmount(String amount) {
    try {
      double.parse(amount);
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool isValidDateTime(String dateTime) {
    try {
      _parseDateTime(dateTime);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Method tambahan untuk mendapatkan timezone saat ini
  static String getCurrentTimezone() {
    Duration offset = DateTime.now().timeZoneOffset;
    int hours = offset.inHours;
    int minutes = offset.inMinutes.remainder(60);

    String sign = hours >= 0 ? '+' : '-';
    String hoursStr = hours.abs().toString().padLeft(2, '0');
    String minutesStr = minutes.abs().toString().padLeft(2, '0');

    return 'UTC$sign$hoursStr:$minutesStr';
  }

  // Method untuk convert ke timezone lokal
  static DateTime convertToLocalTime(DateTime utcDateTime) {
    return utcDateTime.toLocal();
  }

  // Method untuk convert ke UTC
  static DateTime convertToUtc(DateTime localDateTime) {
    return localDateTime.toUtc();
  }
}