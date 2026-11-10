import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'services/fcm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const CloudCourierApp());
}

class CloudCourierApp extends StatelessWidget {
  const CloudCourierApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Cloud Courier',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF008F88)),
      useMaterial3: true,
    ),
    home: const CourierDashboard(),
  );
}

class CourierDashboard extends StatefulWidget {
  const CourierDashboard({super.key});
  @override
  State<CourierDashboard> createState() => _CourierDashboardState();
}

class _CourierDashboardState extends State<CourierDashboard> {
  final FCMService _service = FCMService();
  StreamSubscription<CourierEvent>? _subscription;
  String _asset = 'default';
  String _handler = 'Waiting for message';
  String _messageId = 'None';
  String _diagnostic = 'No messages processed';
  String _permission = 'Checking...';
  String _tokenStatus = 'Checking...';
  int _receiptCount = 0;

  @override
  void initState() {
    super.initState();
    _subscription = _service.events.listen(_handleEvent);
    _initializeMessaging();
  }

  Future<void> _initializeMessaging() async {
    try {
      await _service.start();
      if (!mounted) return;
      if (!mounted) return;
      setState(() {
        _permission = _service.permissionStatus;
        _tokenStatus = _service.tokenStatus;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _diagnostic = 'Messaging setup error: $error');
      }
    }
  }

  void _handleEvent(CourierEvent event) {
    if (!mounted) return;
    setState(() {
      _receiptCount++;
      _handler = event.handler;
      _messageId = event.messageId ?? 'Not supplied';
      if (event.diagnostic != null) {
        _diagnostic = event.diagnostic!;
      } else if (event.asset != null) {
        _asset = event.asset!;
        _diagnostic = 'Accepted: UI updated successfully';
      }
    });
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        SelectableText(value),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isPromo = _asset == 'promo';
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Courier'), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(
              Icons.cloud_done_rounded,
              size: 65,
              color: Color(0xFF008F88),
            ),
            const SizedBox(height: 12),
            const Text(
              'Campus Notification Center',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Firebase Cloud Messaging • Activity 14',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Icon(
                      isPromo
                          ? Icons.celebration_rounded
                          : Icons.school_rounded,
                      size: 90,
                      color: isPromo
                          ? Colors.deepOrange
                          : const Color(0xFF008F88),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPromo
                          ? 'Special Campus Announcement!'
                          : 'Welcome to Campus',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPromo
                          ? 'A new announcement has arrived.'
                          : 'Waiting for your next cloud update.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Diagnostics',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _infoRow('Last handler', _handler),
                    _infoRow('Receipts this launch', '$_receiptCount'),
                    _infoRow('Message ID', _messageId),
                    _infoRow('Current asset', _asset),
                    _infoRow('Validation', _diagnostic),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Firebase Connection',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _infoRow('Notification permission', _permission),
                    _infoRow('FCM token', _tokenStatus),
                    const Text(
                      'Device token is not displayed or included in screenshots.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _service.dispose();
    super.dispose();
  }
}
