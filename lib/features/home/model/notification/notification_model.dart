class NotificationModel {
  final String title;
  final String message;
  final DateTime timestamp;
  final bool read;

  NotificationModel({
    required this.title,
    required this.message,
    required this.timestamp,
    this.read = false,
  });
}
