import 'package:flutter/material.dart';
import 'package:terp/terp_notifier.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terp')),
      body: const _HomeBody(),
      floatingActionButton: OrderButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class OrderButton extends StatelessWidget {
  OrderButton({Key? key}) : super(key: key);
  final notifier = TerpNotifier.instance;

  Future<void> _order(BuildContext context) async {
    await notifier.order();
    const snackbar = SnackBar(content: Text('Cooldown reset!'));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _order(context),
      label: const Text('Start countdown'),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody({Key? key}) : super(key: key);

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  final notifier = TerpNotifier.instance;

  String formatSeconds(int totalSeconds) {
    final minutes = totalSeconds ~/ Duration.secondsPerMinute;
    final seconds = totalSeconds % Duration.secondsPerMinute;
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: notifier,
      builder: (context, child) {
        final totalSeconds = notifier.secondsBeforeNextDrink;
        return Column(
          children: [
            Expanded(flex: 2, child: Image.asset('assets/images/qr_code.png')),
            Expanded(
              child: Center(
                child: Text(
                  formatSeconds(totalSeconds),
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
