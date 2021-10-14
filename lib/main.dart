import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:terp/terp_app.dart';
import 'package:terp/terp_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock the device orientation to portrait
  await SystemChrome.setPreferredOrientations(
    <DeviceOrientation>[DeviceOrientation.portraitUp],
  );
  await TerpNotifier.instance.init();
  runApp(const TerpApp());
}
