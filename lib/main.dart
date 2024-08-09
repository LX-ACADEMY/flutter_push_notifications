import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:notification_example/firebase_options.dart';
import 'package:notification_example/notification_controller.dart';
import 'package:notification_example/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// Create the required notification channels
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
          channelKey: 'sample_channel',
          channelName: 'Sample Chennel',
          channelDescription: 'To ccreate sample notifications',
          groupKey: 'sample_group'),
      NotificationChannel(
          channelKey: 'sample_channel2',
          channelName: 'Sample Chennel 2',
          channelDescription: 'To ccreate sample notifications',
          groupKey: 'sample_group'),
      NotificationChannel(
          channelKey: 'sample_channel3',
          channelName: 'Sample Chennel 3',
          channelDescription: 'To ccreate sample notifications',
          groupKey: 'sample_group2'),
      NotificationChannel(
          channelKey: 'sample_channel4',
          channelName: 'Sample Chennel 4',
          channelDescription: 'To ccreate sample notifications',
          groupKey: 'sample_group2'),
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: 'sample_group',
        channelGroupName: 'Sample Group',
      ),
      NotificationChannelGroup(
        channelGroupKey: 'sample_group2',
        channelGroupName: 'Sample Group2',
      )
    ],
  );

  runApp(const App());
}

class App extends HookWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();

  const App({super.key});

  @override
  Widget build(BuildContext context) {
    /// FCM initialization
    useEffect(() {
      FirebaseMessaging.instance.requestPermission(provisional: true);

      FirebaseMessaging.instance.getToken().then((token) {
        print('FCM Token: $token');
      });

      FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
        /// Store the updated token in the database
      }).onError((err) {
        // Error getting token.
      });

      return null;
    }, []);

    /// Setup FCM notification listener
    useEffect(() {
      FirebaseMessaging.onMessage
          .listen(NotificationController.fcmForegroundHandler);

      FirebaseMessaging.onBackgroundMessage(
          NotificationController.fcmBackgroundHandler);

      return null;
    }, []);

    /// Setup listeners for local notifications
    useEffect(() {
      AwesomeNotifications().setListeners(
          onActionReceivedMethod: NotificationController.onActionReceivedMethod,
          onNotificationCreatedMethod:
              NotificationController.onNotificationCreatedMethod,
          onNotificationDisplayedMethod:
              NotificationController.onNotificationDisplayedMethod,
          onDismissActionReceivedMethod:
              NotificationController.onDismissActionReceivedMethod);

      return null;
    }, []);

    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const HomePage(),
    );
  }
}
