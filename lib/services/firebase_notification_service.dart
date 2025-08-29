import 'package:app/databaseConnection/ingredientLogic/import_ingredient.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;


class FirebaseNotificationService{
  static final FirebaseNotificationService _instance = FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
   
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseNotificationService._internal();
  
  Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: _onNotificationTap,
    );
  }
    
    Future<void> scheduleNotification(Ingredient? ingredient, notificationDate) async {
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        channelDescription: 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );
      int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'MyPantry Notificaton',
        'Ingredient ${ingredient?.name ?? 'Unknown ingredient'} is about to expire',
        tz.TZDateTime.from(notificationDate, tz.local),
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'scheduled', androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
      );
    }
}

void _onNotificationTap(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
    
    }
  }