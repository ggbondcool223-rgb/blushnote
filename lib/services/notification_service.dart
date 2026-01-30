import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:get/get.dart';
import 'package:blush_note/db_blush_note/index.dart';
import 'package:blush_note/db_blush_note/db_blush_note_entity.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService extends GetxService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  final inAppNotifications = <ScheduleNotification>[].obs;
  final hasUnreadNotifications = false.obs;

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/New_York'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();

    await _scheduleDailyCheck();
  }

  Future<void> _requestPermissions() async {
    if (GetPlatform.isIOS) {
      await Permission.notification.request();
    } else if (GetPlatform.isAndroid) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    Get.toNamed('/schedule');
  }

  Future<void> _scheduleDailyCheck() async {
    try {
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        8,
        0,
        0,
      );

      if (now.isAfter(scheduledDate)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        0,
        'BlushNote',
        'You have pending schedules today',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_schedule_check',
            'Daily Schedule Check',
            channelDescription: 'Daily reminder for pending schedules',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print('Error scheduling daily check: $e');
    }
  }

  Future<void> checkDueSchedules() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayStr = today.toIso8601String();
      final tomorrowStr = today.add(const Duration(days: 1)).toIso8601String();

      final schedules = await db.getSchedules(
        startDate: todayStr,
        endDate: tomorrowStr,
        isCompleted: 0,
      );

      if (schedules.isEmpty) {
        return;
      }

      await _sendSystemNotification(schedules);

      _addInAppNotifications(schedules);
    } catch (e) {
      print('Error checking due schedules: $e');
    }
  }

  Future<void> _sendSystemNotification(List<Schedule> schedules) async {
    final count = schedules.length;
    String title = 'Schedule Reminder';
    String body;

    if (count == 1) {
      body = schedules.first.content;
    } else {
      body = 'You have $count pending schedules today';
    }

    await _notifications.show(
      1,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'schedule_reminder',
          'Schedule Reminder',
          channelDescription: 'Reminder for due schedules',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  void _addInAppNotifications(List<Schedule> schedules) {
    final now = DateTime.now();
    
    for (var schedule in schedules) {
      final notification = ScheduleNotification(
        id: schedule.id!,
        title: 'Schedule Due',
        content: schedule.content,
        scheduleDateTime: schedule.dateTime,
        isRead: false,
        createdAt: now.toIso8601String(),
      );

      final exists = inAppNotifications.any((n) => 
        n.id == notification.id && 
        n.scheduleDateTime == notification.scheduleDateTime
      );

      if (!exists) {
        inAppNotifications.insert(0, notification);
      }
    }

    hasUnreadNotifications.value = inAppNotifications.any((n) => !n.isRead);
  }

  Future<void> markAsRead(int id, String scheduleDateTime) async {
    try {
      final schedule = await db.getScheduleById(id);
      if (schedule != null) {
        final updated = Schedule(
          id: schedule.id,
          content: schedule.content,
          eventColor: schedule.eventColor,
          dateTime: schedule.dateTime,
          repeatType: schedule.repeatType,
          repeatEndDate: schedule.repeatEndDate,
          reminderType: schedule.reminderType,
          isCompleted: 1,
          parentId: schedule.parentId,
          createdAt: schedule.createdAt,
          updatedAt: DateTime.now().toIso8601String(),
        );
        await db.updateSchedule(updated);
      }
    } catch (e) {
      print('Error marking schedule as completed: $e');
    }
    
    inAppNotifications.removeWhere(
      (n) => n.id == id && n.scheduleDateTime == scheduleDateTime,
    );
    hasUnreadNotifications.value = inAppNotifications.any((n) => !n.isRead);
  }

  Future<void> markAllAsRead() async {
    try {
      for (var notification in inAppNotifications) {
        final schedule = await db.getScheduleById(notification.id);
        if (schedule != null) {
          final updated = Schedule(
            id: schedule.id,
            content: schedule.content,
            eventColor: schedule.eventColor,
            dateTime: schedule.dateTime,
            repeatType: schedule.repeatType,
            repeatEndDate: schedule.repeatEndDate,
            reminderType: schedule.reminderType,
            isCompleted: 1,
            parentId: schedule.parentId,
            createdAt: schedule.createdAt,
            updatedAt: DateTime.now().toIso8601String(),
          );
          await db.updateSchedule(updated);
        }
      }
    } catch (e) {
      print('Error marking schedules as completed: $e');
    }
    
    inAppNotifications.clear();
    hasUnreadNotifications.value = false;
  }

  void clearNotification(int id, String scheduleDateTime) {
    inAppNotifications.removeWhere(
      (n) => n.id == id && n.scheduleDateTime == scheduleDateTime,
    );
    hasUnreadNotifications.value = inAppNotifications.any((n) => !n.isRead);
  }

  void clearAllNotifications() {
    inAppNotifications.clear();
    hasUnreadNotifications.value = false;
  }

  int get unreadCount => inAppNotifications.where((n) => !n.isRead).length;
}

class ScheduleNotification {
  final int id;
  final String title;
  final String content;
  final String scheduleDateTime;
  final bool isRead;
  final String createdAt;

  ScheduleNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.scheduleDateTime,
    required this.isRead,
    required this.createdAt,
  });
}

final notificationService = NotificationService();
