import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terp/constants.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:math' as math;

class TerpNotifier extends ChangeNotifier {
  TerpNotifier._();
  static final instance = TerpNotifier._();

  late final SharedPreferences _preferences;
  final _notifications = FlutterLocalNotificationsPlugin();

  int get secondsBeforeNextDrink => _secondsBeforeNextDrink;
  int _secondsBeforeNextDrink = 0;

  Timer? _timer;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    tz.initializeTimeZones();
    final location = tz.getLocation('Europe/London');
    tz.setLocalLocation(location);
    _restoreCountdown();
  }

  Future<void> _restoreCountdown() async {
    final now = DateTime.now();
    final lastOrder = DateTime.fromMillisecondsSinceEpoch(
      _preferences.getInt('last_order') ?? now.millisecondsSinceEpoch,
    );
    _secondsBeforeNextDrink = kCooldown.inSeconds -
        math.min(
          now.difference(lastOrder).inSeconds,
          kCooldown.inSeconds,
        );
    _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsBeforeNextDrink <= 0) {
        timer.cancel();
        return;
      }

      _secondsBeforeNextDrink--;
      notifyListeners();
    });
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
        android: AndroidNotificationDetails('drink-cooldown', ''),
      ),
      // Absolute time is the correct interpretation for countdown timers
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
    // Reset the countdown
    // Schedule a push notification
    _secondsBeforeNextDrink = kCooldown.inSeconds;
    _resetTimer();
  }
}
