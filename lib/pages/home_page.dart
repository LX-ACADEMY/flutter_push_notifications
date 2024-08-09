import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();

    void requestPermission() async {
      final isEnabled = await AwesomeNotifications().isNotificationAllowed();

      if (!isEnabled) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    }

    void sendNotification() async {
      final title = titleController.text;
      final description = descriptionController.text;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'sample_channel3',
          title: title,
          body: description,
          payload: {
            'page': 'test_page',
          },
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder(
                future: AwesomeNotifications().isNotificationAllowed(),
                builder: (context, snapshot) {
                  final isEnabled = snapshot.hasData && snapshot.data!;

                  return Text(
                      'Permission status: ${isEnabled ? 'ENABLED' : 'DISABLED'}');
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: requestPermission,
                child: const Text('Request Permission'),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                  onPressed: sendNotification,
                  child: const Text('Send Notification'))
            ],
          ),
        ),
      ),
    );
  }
}
