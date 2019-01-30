import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

class Handler {
  /// The firebase cloud messaging service provider.
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();


  /// Requests the notification permissions. Only really does something on iOS.
  void requestNotificationPermissions() {
    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true)
    );
  }

  /// Configures the firebase messaging service.
  void configure() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('onMessage called: Message is $message.');
      },
      onResume: (msg) async => print('onResume called: Message is $msg.'),
      onLaunch: (msg) async => print('onLaunch called: Message is $msg.'),
    );
    _firebaseMessaging.getToken().then(print);
    print('Firebase messaging configured.');
  }

  Future<String> getToken() => _firebaseMessaging.getToken();
}
