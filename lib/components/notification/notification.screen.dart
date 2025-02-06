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
  late String? usertoken;
  late String? userid;
  late String? usertype;
  var provider;

  List<NotificationModel> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    provider = context.read<UserDataProvider>();
    usertoken = provider.usertoken;
    userid = provider.userid;
    usertype = provider.usertype;

    // Check if any value is null or an empty string
    if (usertoken == null || usertoken!.isEmpty || 
        userid == null || userid!.isEmpty || 
        usertype == null || usertype!.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    loadNotifications();
  }


  void loadNotifications() async {
    List<NotificationModel> fetchedNotifications = [];

    if (usertype == 'Admin') {
      fetchedNotifications = await NotificationsProvider.shared.getNotificationsByAdmin(usertoken!);
    } else if (usertype == 'Mentor') {
      fetchedNotifications = await NotificationsProvider.shared.getNotificationsByMentor(int.parse(userid!), usertoken!);
    } else {
      fetchedNotifications = await NotificationsProvider.shared.getNotificationsByUser(int.parse(userid!), usertoken!);
    }

    setState(() {
      notifications = fetchedNotifications;
      isLoading = false;
    });
  }

  Future<void> setRead() async {
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
          if (usertype == 'Mentor' && notifications.isNotEmpty)
            TextButton(
              onPressed: () async {
                await setRead();
              },
              child: const Text("Clear all"),
            )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : usertoken == null || userid == null || usertype == null
              ? const Center(child: Text("Please log in to view notifications."))
              : notifications.isEmpty
                  ? const Center(child: Text("No notifications"))
                  : Padding(
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
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
