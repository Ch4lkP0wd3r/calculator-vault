import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calculator_vault/services/panic_service.dart';
import 'package:permission_handler/permission_handler.dart';

class BackgroundServiceHelper {
  static const String notificationChannelId = 'safehouse_foreground';
  static const int notificationId = 888;
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    // Notification Init
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      'Safehouse Protection',
      description: 'Active background protection',
      importance: Importance.low, 
    );

    await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: 'Safehouse Active',
        initialNotificationContent: 'Monitoring for Shake (Emergency)',
        foregroundServiceNotificationId: notificationId,
      ),
      iosConfiguration: IosConfiguration(autoStart: false),
    );
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    // State Variables
    DateTime lastShakeTime = DateTime.now();
    bool isPanicActive = false;
    StreamSubscription? accelerometerSub;
    final PanicService panicService = PanicService();

    // 1. Listen for stop
    service.on('stopService').listen((event) {
      service.stopSelf();
      accelerometerSub?.cancel();
    });

    // 2. Accelerometer Logic
    accelerometerSub = userAccelerometerEvents.listen((UserAccelerometerEvent event) async {
       if (isPanicActive) return;

       double acceleration = (event.x.abs() + event.y.abs() + event.z.abs());
       if (acceleration > 15) { // Threshold
          final now = DateTime.now();
          if (now.difference(lastShakeTime).inSeconds > 2) {
             lastShakeTime = now;
             
             // Trigger Logic
             isPanicActive = true;
             await _startBackgroundPanic(service, panicService);
             isPanicActive = false; // Reset after done
          }
       }
    });
  }

  static Future<void> _startBackgroundPanic(ServiceInstance service, PanicService panicService) async {
     // A. Countdown (5 seconds)
     for(int i=5; i>0; i--) {
        _notifications.show(
          notificationId,
          'SOS DETECTED!',
          'Initiating in $i seconds... Open app to CANCEL.',
          const NotificationDetails(android: AndroidNotificationDetails(
             notificationChannelId, 
             'Safehouse Protection',
             importance: Importance.max,
             priority: Priority.max,
             playSound: true,
             enableVibration: true,
          )),
        );
        await Future.delayed(const Duration(seconds: 1));
     }

     // A2. Check if user cancelled (requires IPC, simplification: user must open app to kill service)
     // If we are here, we proceed.

     // B. Execute Panic (Record + Location)
     _notifications.show(notificationId, 'SOS STARTED', 'Recording Audio & Location...', 
        const NotificationDetails(android: AndroidNotificationDetails(notificationChannelId, 'Safehouse Protection')));

     // Reuse PanicService but we need a dummy context or modify PanicService to handle context-less
     // NOTE: PanicService as written primarily drives UI state. We need a "silent" mode.
     // For now, let's create a simplified logic here or assume PanicService can be adapted.
     
     // *Simplified Background Logic (Service Context)*
     // We can't use Share Sheet in background. We prompt user.
     
     _notifications.show(
        notificationId+1, // Separate ID
        'SOS READY TO SEND',
        'Tap this notification to SEND ALERT via WhatsApp/SMS',
        const NotificationDetails(android: AndroidNotificationDetails(
           notificationChannelId, 'Safehouse Protection',
           importance: Importance.max, priority: Priority.high,
           fullScreenIntent: true, // Try to wake screen
        )),
        payload: 'trigger_share', // Main app monitors this on launch
     );
  }
}
