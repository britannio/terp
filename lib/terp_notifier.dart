import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terp/constants.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:math' as math;

class TerpNotifier extends ChangeNotifier {
  TerpNotifier._() {
    // Update every second
    Stream.periodic(const Duration(seconds: 1))
        .listen((_) => notifyListeners());
  }

  static final instance = TerpNotifier._();

  late final SharedPreferences _preferences;
  final _notifications = FlutterLocalNotificationsPlugin();

  int get secondsBeforeNextDrink {
    final now = DateTime.now();
    final lastOrder = DateTime.fromMillisecondsSinceEpoch(
      _preferences.getInt('last_order') ?? now.millisecondsSinceEpoch,
    );
    return math.max(
      kCooldown.inSeconds - now.difference(lastOrder).inSeconds,
      0,
    );
  }

  String get currentCode => _preferences.getString('code') ?? '';
  set currentCode(String code) {
    () async {
      await _preferences.setString('code', code);
      notifyListeners();
    }();
  }

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();

    tz.initializeTimeZones();
    final location = tz.getLocation('Europe/London');
    tz.setLocalLocation(location);
    await _notifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('notification_icon'),
      ),
    );
  }

  Future<void> order() async {
    await _preferences.setInt(
      'last_order',
      DateTime.now().millisecondsSinceEpoch,
    );

    await _notifications.cancel(0);
    await _notifications.zonedSchedule(
      0,
      'Your Pret cooldown has expired!',
      'Enjoy your next drink!',
      tz.TZDateTime.now(tz.local).add(kCooldown),
      const NotificationDetails(
        android: AndroidNotificationDetails('drink-cooldown', 'Drink Cooldown'),
      ),
      // Absolute time is the correct interpretation for countdown timers
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }
}
