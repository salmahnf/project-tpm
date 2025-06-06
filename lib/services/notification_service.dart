import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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
