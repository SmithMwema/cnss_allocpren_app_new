// lib/controleur/notification_ctrl.dart
import 'package:get/get.dart';
import '../modele/notification.dart';
import '../service/auth_service.dart';
import '../service/firestore_service.dart';

class NotificationCtrl extends GetxController {
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  var isLoading = true.obs;
  final RxList<AppNotification> notifications = <AppNotification>[].obs;

  @override
  void onInit() {
    super.onInit();
    chargerNotifications();
  }

  Future<void> chargerNotifications() async {
    if (_authService.user == null) {
      notifications.clear();
      isLoading.value = false;
      return;
    }
    try {
      isLoading.value = true;
      final notifs = await _firestore.recupererNotifications(_authService.user!.uid);
      notifications.assignAll(notifs);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> marquerCommeLue(AppNotification notification) async {
    int index = notifications.indexOf(notification);
    if (index != -1 && !notifications[index].estLue) {
      notifications[index] = notification.copyWith(estLue: true);
      await _firestore.marquerNotificationCommeLue(notification.id!);
    }
  }
}