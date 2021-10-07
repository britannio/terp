import 'package:flutter/material.dart';
import 'package:terp/terp_app.dart';
import 'package:terp/terp_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TerpNotifier.instance.init();
  runApp(const TerpApp());
}
