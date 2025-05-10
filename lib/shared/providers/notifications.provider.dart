import 'dart:convert';

import 'package:mentor/shared/models/notification.model.dart';
import 'package:http/http.dart' as http;

class NotificationsProvider {
  static NotificationsProvider get shared => NotificationsProvider();
  /*List<NotificationModel> get notifications => [
        NotificationModel(
            id: "1",
            title: "Today's Special Offers",
            message: "You get a special promo today!",
            dateTime: DateTime.now(),
            initiatedUser: MentorsProvider.shared.getMentor("1")!,
            isRead: false),
        NotificationModel(
            id: "2",
            title: "Toro like your profile",
            dateTime: DateTime.now().add(const Duration(hours: -3)),
            initiatedUser: MentorsProvider.shared.getMentor("2")!,
            isRead: false),
        NotificationModel(
            id: "3",
            title: "Lorem Ipsum is simply dummy text of the printing",
            message: "It is a long established fact",
            dateTime: DateTime.now().add(const Duration(hours: -5)),
            initiatedUser: MentorsProvider.shared.getMentor("3")!,
            isRead: false),
        NotificationModel(
            id: "4",
            title: "Many desktop publishing packages",
            message: "You get a special promo today!",
            dateTime: DateTime.now().add(const Duration(hours: -6)),
            initiatedUser: MentorsProvider.shared.getMentor("4")!,
            isRead: false),
        NotificationModel(
            id: "5",
            title: "There are many variations of passages of Lorem Ipsum",
            message: "You get a special promo today!",
            dateTime: DateTime.now().add(const Duration(hours: -7)),
            initiatedUser: MentorsProvider.shared.getMentor("5")!,
            isRead: false),
        NotificationModel(
            id: "6",
            title: "Contrary to popular belief",
            dateTime: DateTime.now().add(const Duration(days: -1)),
            initiatedUser: MentorsProvider.shared.getMentor("6")!,
            isRead: false),
        NotificationModel(
            id: "7",
            title: "All the Lorem Ipsum generators on the Internet",
            dateTime: DateTime.now().add(const Duration(days: -10)),
            initiatedUser: MentorsProvider.shared.getMentor("6")!,
            isRead: false)
      ];*/

  Future<List<NotificationModel>> getNotificationsByMentor(int userId, String usertoken) async {

    final url = Uri.parse('http://localhost:8080/api/notify/getAllNotificationByMentorId?mentorId=$userId');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $usertoken',
        },
      );

      List<NotificationModel> expes = [];

      if (response.statusCode == 200) {
        var parsed = response.body;
        List<dynamic> notifications = jsonDecode(parsed);

        for (var notification in notifications) {
          Map<String, dynamic> exp = notification as Map<String, dynamic>;
          String dateString = exp['createdAt'];

          DateTime date = DateTime.parse(dateString);

          NotificationModel model = NotificationModel(
            id: exp['id'].toString(),
            title: exp['title'] ?? 'Unknown Title',
            message: exp['message'] ?? 'Unknown Message',
            userName: exp['recipientName'] ?? 'Unknown User',
            dateTime: date,
            isRead: exp['isRead'] ?? 'false',
          );
          expes.add(model);
        }
      }
      return expes;
  }

  Future<List<NotificationModel>> getNotificationsByAdmin(String usertoken) async {

    final url = Uri.parse('http://localhost:8080/api/notify/getAll');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $usertoken',
        },
      );

      List<NotificationModel> expes = [];

      if (response.statusCode == 200) {
        var parsed = response.body;
        List<dynamic> notifications = jsonDecode(parsed);

        for (var notification in notifications) {
          Map<String, dynamic> exp = notification as Map<String, dynamic>;
          String dateString = exp['createdAt'];

          DateTime date = DateTime.parse(dateString);

          NotificationModel model = NotificationModel(
            id: exp['id'].toString(),
            title: exp['title'] ?? 'Unknown Title',
            message: exp['message'] ?? 'Unknown Message',
            userName: exp['recipientName'] ?? 'Unknown User',
            dateTime: date,
            isRead: exp['isRead'] ?? 'false',
          );
          expes.add(model);
        }
      }
      return expes;
  }

  Future<List<NotificationModel>> getNotificationsByUser(int userId, String usertoken) async {

    final url = Uri.parse('http://localhost:8080/api/notify/getAllNotificationByUserId?recipientId=$userId');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $usertoken',
        },
      );

      List<NotificationModel> expes = [];

      if (response.statusCode == 200) {
        var parsed = response.body;
        List<dynamic> notifications = jsonDecode(parsed);

        for (var notification in notifications) {
          Map<String, dynamic> exp = notification as Map<String, dynamic>;
          String dateString = exp['createdAt'];

          DateTime date = DateTime.parse(dateString);

          NotificationModel model = NotificationModel(
            id: exp['id'].toString(),
            title: exp['title'] ?? 'Unknown Title',
            message: exp['message'] ?? 'Unknown Message',
            userName: exp['recipientName'] ?? 'Unknown User',
            dateTime: date,
            isRead: exp['isRead'] ?? 'false',
          );
          expes.add(model);
        }
      }
      return expes;
  }

}
