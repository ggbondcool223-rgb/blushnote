import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:blush_note/services/notification_service.dart';

class GlobalNotificationDialog {
  static void showIfNeeded() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (notificationService.hasUnreadNotifications.value &&
          notificationService.inAppNotifications.isNotEmpty) {
        show();
      }
    });
  }

  static void show() {
    Get.dialog(
      const _NotificationDialogContent(),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }
}

class _NotificationDialogContent extends StatelessWidget {
  const _NotificationDialogContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 32.w),
        constraints: BoxConstraints(maxHeight: 500.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFF6B9D),
                    const Color(0xFFFF6B9D).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule Reminders',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Obx(() {
                          final count = notificationService.unreadCount;
                          return Text(
                            '$count pending ${count == 1 ? 'task' : 'tasks'} today',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.white.withOpacity(0.9),
                              decoration: TextDecoration.none,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Flexible(
              child: Obx(() {
                final notifications = notificationService.inAppNotifications;

                if (notifications.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(40.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64.sp,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'All caught up!',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'No pending schedules',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[500],
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey[200],
                    indent: 20.w,
                    endIndent: 20.w,
                  ),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationItem(notification);
                  },
                );
              }),
            ),

            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await notificationService.markAllAsRead();
                        Get.back();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            'Mark All Read',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        Get.toNamed('/schedule');
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFF6B9D),
                              const Color(0xFFFF6B9D).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(ScheduleNotification notification) {
    return GestureDetector(
      onTap: () async {
        await notificationService.markAsRead(
          notification.id,
          notification.scheduleDateTime,
        );
        Get.back();
        Get.toNamed(
          '/schedule/add',
          arguments: {'scheduleId': notification.id},
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        color: const Color(0xFFFFF8FA),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE8F0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_note,
                size: 20.sp,
                color: const Color(0xFFFF6B9D),
              ),
            ),
            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        margin: EdgeInsets.only(right: 6.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B9D),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          notification.content,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333333),
                            decoration: TextDecoration.none,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _formatTime(notification.scheduleDateTime),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right, size: 20.sp, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  String _formatTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final scheduleDate = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
      );

      if (scheduleDate == today) {
        final hour = dateTime.hour.toString().padLeft(2, '0');
        final minute = dateTime.minute.toString().padLeft(2, '0');
        return 'Today at $hour:$minute';
      } else if (scheduleDate == today.add(const Duration(days: 1))) {
        return 'Tomorrow';
      } else if (scheduleDate.isBefore(today)) {
        final diff = today.difference(scheduleDate).inDays;
        return '$diff ${diff == 1 ? 'day' : 'days'} overdue';
      } else {
        return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return dateTimeStr;
    }
  }
}
