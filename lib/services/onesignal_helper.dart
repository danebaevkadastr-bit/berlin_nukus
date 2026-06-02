import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalHelper {
  static void setup(String appId) {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(appId);
    OneSignal.Notifications.requestPermission(true);
    OneSignal.Notifications.addClickListener((event) {
      debugPrint('NOTIFICATION CLICKED: ${event.notification.additionalData}');
    });
  }

  static void login(String uid) {
    OneSignal.login(uid);
  }

  static void logout() {
    OneSignal.logout();
  }
}
