import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saviaqua/core/widgets/loading_overlay.dart';
import 'package:saviaqua/features/home/data/notification-data/notification_service_mock.dart';
import 'package:saviaqua/features/home/model/notification/notification_model.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final result = await _notificationService.fetchNotifications();
      if (mounted) {
        setState(() {
          _notifications = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.blue,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Cargando notificaciones...',
        backgroundColor: Colors.white,
        style: LoadingStyle.drop, // o .dots, .drop, .defaultSpinner
        child: _notifications.isEmpty
              ? const Center(child: Text('No hay notificaciones'))
              : ListView.builder(
                padding: const EdgeInsets.all(12), 
                itemCount: _notifications.length,
                itemBuilder: (_, index) {
                  final notification = _notifications[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            notification.read
                                ? Colors.grey.shade200
                                : Colors.blue.shade100,
                        child: Icon(
                          notification.read
                              ? Icons.notifications_none
                              : Icons.notifications_active,
                          color: notification.read ? Colors.grey : Colors.blue,
                        ),
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight:
                              notification.read
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(notification.message),
                      trailing: Text(
                        DateFormat(
                          'dd MMM HH:mm',
                          'es',
                        ).format(notification.timestamp),
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () {},
                    ),
                  );
                },
              ),
      ),
    );
  }
}
