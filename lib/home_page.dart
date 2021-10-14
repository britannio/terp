import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:terp/terp_notifier.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int tabIndex = TerpNotifier.instance.currentCode.isEmpty ? 1 : 0;

  void switchTab(int index) {
    setState(() {
      tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const pages = [QrPage(), NewCodePage()];
    return Scaffold(
      appBar: AppBar(title: const Text('Terp'), centerTitle: true),
      body: pages[tabIndex],
      bottomNavigationBar: BottomBar(index: tabIndex),
      floatingActionButton: OrderButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key, required this.index}) : super(key: key);
  final int index;

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  final items = <BottomNavigationBarItem>[
    const BottomNavigationBarItem(icon: FaIcon(Icons.qr_code), label: 'QR'),
    const BottomNavigationBarItem(icon: FaIcon(Icons.save), label: 'New Code'),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.index,
      items: items,
      onTap: (i) =>
          context.findAncestorStateOfType<_HomePageState>()!.switchTab(i),
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

class QrPage extends StatefulWidget {
  const QrPage({Key? key}) : super(key: key);

  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  final notifier = TerpNotifier.instance;

  String formatSeconds(int totalSeconds) {
    final minutes = totalSeconds ~/ Duration.secondsPerMinute;
    final seconds =
        (totalSeconds % Duration.secondsPerMinute).toString().padLeft(2, '0');
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
            const Spacer(flex: 2),
            Image.asset(
              'assets/images/qr_code.png',
              width: double.infinity,
            ),
            /*notifier.currentCode.isEmpty
                ? const Text('No code')
                : FractionallySizedBox(
                    widthFactor: 0.5,
                    child: QrImage(
                      data: notifier.currentCode,
                      errorCorrectionLevel: QrErrorCorrectLevel.L,
                    ),
                  ),*/
            const Spacer(),
            Center(
              child: Text(
                formatSeconds(totalSeconds),
                style: const TextStyle(fontSize: 80),
              ),
            ),
            const Spacer(flex: 5),
          ],
        );
      },
    );
  }
}

class NewCodePage extends StatefulWidget {
  const NewCodePage({Key? key}) : super(key: key);

  @override
  State<NewCodePage> createState() => _NewCodePageState();
}

class _NewCodePageState extends State<NewCodePage> {
  late final TextEditingController _controller;
  final notifier = TerpNotifier.instance;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: notifier.currentCode);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _controller,
          maxLength: 12,
          onChanged: (code) => notifier.currentCode = code,
        )
      ],
    );
  }
}
