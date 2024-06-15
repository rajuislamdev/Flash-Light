import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const FlashlightControllScreen(),
    );
  }
}

class FlashlightControllScreen extends StatefulWidget {
  const FlashlightControllScreen({super.key});

  @override
  State<FlashlightControllScreen> createState() =>
      _FlashlightControllScreenState();
}

class _FlashlightControllScreenState extends State<FlashlightControllScreen> {
  static const platform =
      MethodChannel('com.example.flashlight_app/flashlight');
  static const eventChannel =
      EventChannel('com.example.flashlight_app/flashlight_event');

  bool isFlashlightOn = false;

  @override
  void initState() {
    _listenToFlashlightEvents();
    super.initState();
  }

  Future<void> _toggleFlashlight() async {
    try {
      await platform.invokeMethod(
        'toggleFlashlight',
      );
    } on PlatformException catch (e) {
      print('Failed to toggle flashlight: $e');
    }
  }

  Future<void> _listenToFlashlightEvents() async {
    try {
      eventChannel.receiveBroadcastStream().listen((event) {
        print(event);
        setState(() {
          isFlashlightOn = event;
        });
      });
    } on PlatformException catch (e) {
      print('Failed to listen to flashlight events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Flashlight Control'),
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 100),
              Icon(
                isFlashlightOn ? Icons.flashlight_off : Icons.flashlight_on,
                size: 350,
                color: !isFlashlightOn ? Colors.white : Colors.amber,
              ),
              const SizedBox(height: 100),
              _buildFlashlightButton()
            ],
          ),
        ));
  }

  Widget _buildFlashlightButton() {
    return InkWell(
      onTap: _toggleFlashlight,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              width: 5,
              color: isFlashlightOn
                  ? Colors.amber
                  : Colors.white.withOpacity(0.2)),
        ),
        child: Center(
          child: Text(
            isFlashlightOn ? 'Off' : 'On',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
