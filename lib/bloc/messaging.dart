import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingHandler {
  /// The firebase cloud messaging service provider.
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Future<void> initialize() async {
    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true)
    );

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
}