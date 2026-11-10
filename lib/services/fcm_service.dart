import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('FCM background receipt: ${message.messageId}');
  // Never manipulate UI from the background isolate.
}

class CourierEvent {
  final String handler;
  final String? messageId;
  final String? asset;
  final String? diagnostic;
  const CourierEvent({
    required this.handler,
    this.messageId,
    this.asset,
    this.diagnostic,
  });
}

CourierEvent validateCourierMessage({
  required String handler,
  required String? messageId,
  required Map<String, dynamic> data,
}) {
  final action = data['action'];
  final asset = data['asset'];
  if (action != 'update_ui') {
    return CourierEvent(
      handler: handler,
      messageId: messageId,
      diagnostic: 'Rejected: missing or unsupported action',
    );
  }
  if (asset != 'default' && asset != 'promo') {
    return CourierEvent(
      handler: handler,
      messageId: messageId,
      diagnostic: 'Rejected: missing or unsupported asset',
    );
  }
  return CourierEvent(
    handler: handler,
    messageId: messageId,
    asset: asset as String,
  );
}

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final StreamController<CourierEvent> _events =
      StreamController<CourierEvent>.broadcast();
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _tokenSubscription;
  bool _disposed = false;

  Stream<CourierEvent> get events => _events.stream;
  String permissionStatus = 'Not checked';
  String tokenStatus = 'Not requested';
  String? token;

  Future<void> start() async {
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      (message) => _process(message, 'onMessage'),
    );
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _process(message, 'onMessageOpenedApp'),
    );

    // Retrieve cold-start message BEFORE permission/token network work.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _process(initial, 'getInitialMessage');

    final settings = await _messaging.requestPermission();
    if (_disposed) return;
    permissionStatus = settings.authorizationStatus.name;
    try {
      token = await _messaging.getToken();
      if (_disposed) return;
      tokenStatus = token == null ? 'Unavailable' : 'Ready';
    } catch (error) {
      tokenStatus = 'Error: $error';
    }
    if (_disposed) return;
    _tokenSubscription = _messaging.onTokenRefresh.listen((value) {
      if (_disposed) return;
      token = value;
      tokenStatus = 'Ready (refreshed)';
    });
  }

  void _process(RemoteMessage message, String handler) {
    if (_disposed) return;
    final event = validateCourierMessage(
      handler: handler,
      messageId: message.messageId,
      data: message.data,
    );
    if (!_events.isClosed) _events.add(event);
  }

  void dispose() {
    _disposed = true;
    _foregroundSubscription?.cancel();
    _openedSubscription?.cancel();
    _tokenSubscription?.cancel();
    _events.close();
  }
}
