import 'dart:convert';
import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:notification_example/firebase_options.dart';
import 'package:notification_example/main.dart';
import 'package:notification_example/pages/home_page.dart';
import 'package:notification_example/pages/test_page.dart';

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    final extraData = receivedAction.payload;

    log(extraData.toString());

    if ((extraData ?? {}).containsKey('navigate_to')) {
      final pageName = extraData!['navigate_to'];

      final pageWidget = switch (pageName) {
        'test_page' => const TestPage(),
        _ => const HomePage(),
      };

      App.navigatorKey.currentState!.push(MaterialPageRoute(
        builder: (context) => pageWidget,
      ));
    }
  }

  static void fcmForegroundHandler(RemoteMessage message) {
    fcmHandler(message);
  }

  @pragma('vm:entry-point')
  static Future<void> fcmBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    fcmHandler(message);
  }

  static void fcmHandler(RemoteMessage message) {
    final messagePayload = message.data;

    if (messagePayload.containsKey('title') &&
        messagePayload.containsKey('body')) {
      /// Fetch the title and body from the payload
      final title = messagePayload['title'];
      final body = messagePayload['body'];

      final channelKey =
          messagePayload['notification_channel'] ?? 'sample_channel2';

      final hasExtraData = messagePayload.containsKey('extra');

      /// Create a notification
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecond,
          channelKey: channelKey,
          title: title,
          body: body,
          payload: hasExtraData
              ? (jsonDecode(messagePayload['extra']) as Map<String, dynamic>)
                      .map((key, value) => MapEntry(key, value.toString()))
                  as Map<String, String?>
              : null,
        ),
      );
    } else {
      log('Invalid notification message recieved.');
    }
  }
}
