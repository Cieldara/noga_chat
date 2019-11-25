import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  static final Firestore _db = Firestore.instance;
  static final FirebaseMessaging _fcm = FirebaseMessaging();

  static StreamSubscription iosSubscription;

  static void init() {

    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());

    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
      },
      onLaunch: (Map<String, dynamic> message) async {
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        // TODO optional
      },
    );
  }
}
