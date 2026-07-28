import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalHelper {
  static void setup(String appId) {
    debugPrint('🔔 OneSignal setup boshlandi...');
    debugPrint('   App ID: $appId');
    
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(appId);
    
    debugPrint('🔔 OneSignal initialized');
    
    OneSignal.Notifications.requestPermission(true);
    debugPrint('🔔 Permission requested');
    
    OneSignal.Notifications.addClickListener((event) {
      debugPrint('🔔 NOTIFICATION CLICKED: ${event.notification.additionalData}');
    });
    
    debugPrint('✅ OneSignal setup tugallandi');
  }

  static void login(String uid) {
    debugPrint('🔔 OneSignal login: $uid');
    OneSignal.login(uid);
    debugPrint('✅ OneSignal login tugallandi');
  }

  static void logout() {
    debugPrint('🔔 OneSignal logout');
    OneSignal.logout();
  }
}
