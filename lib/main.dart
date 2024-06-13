import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FlashlightControllScreen(),
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

  bool isFlashlightOn = true;

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
        title: const Text('Flashlight Control'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _toggleFlashlight,
          child: Text(isFlashlightOn ? 'Turn Off' : 'Turn On'),
        ),
      ),
    );
  }
}
