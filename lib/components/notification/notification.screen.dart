import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mentor/shared/providers/notifications.provider.dart';
import 'package:mentor/shared/shared.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';
import 'package:http/http.dart' as http;
import '../../navigation/router.dart';
import '../../shared/models/notification.model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  //final notifications = NotificationsProvider.shared.notifications;
  late String usertoken;
  late String userid;
  late String usertype;
  var provider;

  List<NotificationModel> notifications = [];

  @override
  void initState() {
    super.initState();

    provider = context.read<UserDataProvider>();
    usertoken = provider.usertoken;
    userid = provider.userid;
    usertype = provider.usertype;

    if (usertype == 'Admin') {
      loadAdminNotification();
    } else if (usertype == 'Mentor') {
      loadMentorNotification();
    } else {
      loadUserNotification();
    }
  }

  loadAdminNotification() async {
    notifications = await NotificationsProvider.shared.getNotificationsByAdmin(usertoken);

    setState(() {
      notifications = notifications;
    });
  }

  loadMentorNotification() async {
    int userId = int.parse(userid);
    notifications = await NotificationsProvider.shared.getNotificationsByMentor(userId, usertoken);

    setState(() {
      notifications = notifications;
    });
  }

  loadUserNotification() async {
    int userId = int.parse(userid);
    notifications = await NotificationsProvider.shared.getNotificationsByUser(userId, usertoken);

    setState(() {
      notifications = notifications;
    });
  }

  setRead() async {
    for (var notify in notifications) {
      int id = int.parse(notify.id);
      final url = Uri.parse('http://localhost:8080/api/notify/updateAsRead?notificationId=$id');

      await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $usertoken',
        },
      );
    }

    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Notifications",
          style: context.headlineMedium,
        ),
        actions: [
          if (usertype == 'Mentor')
            TextButton(
              onPressed: () async {
                await setRead();
              },
            child: const Text("Clear all"))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Dismissible(
                background: Container(
                  decoration:
                      BoxDecoration(color: context.colors.errorContainer),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(FontAwesomeIcons.trashCan),
                        SizedBox(
                          width: 20,
                        )
                      ]),
                ),
                key: Key(notifications[index].id),
                child: ListTile(
                  title: Text(notification.title),
                  subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.message ?? ""),
                        Text(
                          timeago.format(notification.dateTime),
                          style: context.bodySmall,
                        )
                      ]),
                  /*leading: CircleAvatar(
                    radius: 26,
                    backgroundImage: AssetImage(
                      notification.initiatedUser.avatarUrl,
                    ),
                  ),*/
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
