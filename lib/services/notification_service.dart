import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Wajib dipanggil di main()
Future<void> initializeTimeZone() async {
  tz.initializeTimeZones();
}

/// Notifikasi langsung
Future<void> showFavoriteNotification(String cocktailName) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'favorite_channel',
    'Favorites',
    channelDescription: 'Notifikasi untuk cocktail favorit',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Ditambahkan ke Favorit',
    '$cocktailName berhasil ditambahkan ke favorit!',
    notificationDetails,
  );
}

/// Notifikasi terjadwal
Future<void> scheduleReminderNotification(String cocktailName) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    1, // ID notifikasi
    'Ingat Hari Ini!', // Judul
    'Jangan lupa coba membuat $cocktailName cocktails favorit kamu hari ini 🍹', // Isi
    tz.TZDateTime.now(tz.local).add(const Duration(minutes: 2)), // Waktu
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_channel',
        'Daily Reminder',
        channelDescription: 'Pengingat untuk mencoba cocktail favorit',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    // Versi terbaru TIDAK pakai ini:
    // matchDateTimeComponents: null,
    // uiLocalNotificationDateInterpretation: null,
    payload: null,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}
