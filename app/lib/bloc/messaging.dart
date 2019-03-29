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
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  /// Configures the firebase messaging service.
  void configure({@required VoidCallback onMessageReceived}) {
    assert(onMessageReceived != null);

    Function onReceived = onMessageReceived;
    assert(() {
      onReceived = (Map<String, dynamic> msg) {
        print('Message received: $msg');
        onMessageReceived();
      };
      return true;
    }());

    _firebaseMessaging.configure(
      onMessage: onReceived,
      onResume: onReceived,
      onLaunch: onReceived,
    );
    assert(() {
      getToken().then((token) {
        debugPrint('Firebase messaging configured. Messaging token: $token',
            wrapWidth: 80);
      });
      return true;
    }());
  }

  Future<String> getToken() => _firebaseMessaging.getToken();

  // Stuff for subscribing to / unsubscribing from different topics.

  void _subscribe(String topic) {
    assert(topic != null);
    _firebaseMessaging.subscribeToTopic(topic);
  }

  void _unsubscribe(String topic) {
    assert(topic != null);
    _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  void subscribeToGame(Game game) {
    assert(game != null);
    _subscribe('game_${game.code}');
  }

  void unsubscribeFromGame(Game game) {
    assert(game != null);
    _unsubscribe('game_${game.code}');
  }

  void subscribeToDeaths() => _subscribe('deaths');
  void unsubscribeFromDeaths() => _unsubscribe('deaths');
}
