import 'package:saviaqua/features/home/model/notification/notification_model.dart';

class NotificationService {
  Future<List<NotificationModel>> fetchNotifications() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      NotificationModel(
        title: 'Nuevo reporte disponible',
        message: 'Ya puedes revisar el último análisis del pozo #45',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      NotificationModel(
        title: 'Alerta de calidad del agua',
        message: 'Los niveles de cloro han bajado del mínimo en la Junta Azuay',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        read: true,
      ),
    ];
  }
}
