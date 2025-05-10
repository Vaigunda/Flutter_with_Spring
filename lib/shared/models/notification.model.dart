class NotificationModel {
  final String id;
  final String title;
  final String? message;
  final DateTime dateTime;
  final bool isRead;
  final String userName;

  NotificationModel(
      {required this.id,
      required this.title,
      this.message,
      required this.userName,
      required this.dateTime,
      this.isRead = false});
}
