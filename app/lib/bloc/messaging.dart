import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'models.dart';

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
  void configure({ @required VoidCallback onMessageReceived }) {
    final onReceived = (Map<String, dynamic> msg) {
      print('Message received: $msg');
      onMessageReceived();
    };

    _firebaseMessaging.configure(
      onMessage: onReceived,
      onResume: onReceived,
      onLaunch: onReceived,
    );
    getToken().then((token) {
      print('Firebase messaging configured. Messaging token: $token');
    });
  }

  Future<String> getToken() => _firebaseMessaging.getToken();

  // Stuff for subscribing to / unsubscribing from different topics.
  void _subscribe(String topic) => _firebaseMessaging.subscribeToTopic(topic);
  void _unsubscribe(String topic) => _firebaseMessaging.unsubscribeFromTopic(topic);

  void subscribeToGame(Game game) => _subscribe('game_${game.code}');
  void unsubscribeFromGame(Game game) => _unsubscribe('game_${game.code}');

  void subscribeToDeaths() => _subscribe('deaths');
  void unsubscribeFromDeaths() => _unsubscribe('deaths');
}
