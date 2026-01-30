import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:blush_note/services/notification_service.dart';

class NotificationPanel extends StatelessWidget {
  const NotificationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final notifications = notificationService.inAppNotifications;
      
      if (notifications.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3F8),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFFF6B9D), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B9D).withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: const Color(0xFFFF6B9D),
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Schedule Reminders',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF6B9D),
                    ),
                  ),
                  const Spacer(),
                  Obx(() {
                    final unreadCount = notificationService.unreadCount;
                    if (unreadCount == 0) return const SizedBox.shrink();
                    
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B9D),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '$unreadCount',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () async {
                      await notificationService.markAllAsRead();
                    },
                    child: Text(
                      'Mark all read',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFFFF6B9D),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: () {
                      notificationService.clearAllNotifications();
                    },
                    child: Icon(
                      Icons.close,
                      size: 18.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notifications.length > 3 ? 3 : notifications.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey[300],
              ),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationItem(notification);
              },
            ),
            
            if (notifications.length > 3)
              GestureDetector(
                onTap: () {
                  _showAllNotifications(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12.r),
                      bottomRight: Radius.circular(12.r),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Show ${notifications.length - 3} more',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFFFF6B9D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildNotificationItem(ScheduleNotification notification) {
    return GestureDetector(
      onTap: () async {
        await notificationService.markAsRead(
          notification.id,
          notification.scheduleDateTime,
        );
        Get.toNamed('/schedule');
      },
      child: Container(
        color: const Color(0xFFFF6B9D).withOpacity(0.05),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B9D),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.content,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF666666),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _formatTime(notification.scheduleDateTime),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      '/schedule/add',
                      arguments: {'scheduleId': notification.id},
                    );
                  },
                  child: Icon(
                    Icons.edit_outlined,
                    size: 18.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () {
                    notificationService.clearNotification(
                      notification.id,
                      notification.scheduleDateTime,
                    );
                  },
                  child: Icon(
                    Icons.close,
                    size: 18.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      if (diff.inMinutes < 1) {
        return 'Just now';
      } else if (diff.inHours < 1) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inDays < 1) {
        return '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      } else {
        return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return dateTimeStr;
    }
  }

  void _showAllNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'All Notifications',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      await notificationService.markAllAsRead();
                    },
                    child: Text(
                      'Mark all read',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFFFF6B9D),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      size: 24.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Obx(() {
                final notifications = notificationService.inAppNotifications;
                
                if (notifications.isEmpty) {
                  return Center(
                    child: Text(
                      'No notifications',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  );
                }
                
                return ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey[200],
                  ),
                  itemBuilder: (context, index) {
                    return _buildNotificationItem(notifications[index]);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationBadgeIcon extends StatelessWidget {
  const NotificationBadgeIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasUnread = notificationService.hasUnreadNotifications.value;
      
      return Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              _showNotificationPanel(context);
            },
          ),
          if (hasUnread)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 10.w,
                height: 10.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6B9D),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      );
    });
  }

  void _showNotificationPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      await notificationService.markAllAsRead();
                    },
                    child: Text(
                      'Mark all read',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFFFF6B9D),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      size: 24.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Obx(() {
                final notifications = notificationService.inAppNotifications;
                
                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64.sp,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No notifications',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey[200],
                  ),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return GestureDetector(
                      onTap: () async {
                        await notificationService.markAsRead(
                          notification.id,
                          notification.scheduleDateTime,
                        );
                        Navigator.pop(context);
                        Get.toNamed('/schedule');
                      },
                      child: Container(
                        color: const Color(0xFFFF6B9D).withOpacity(0.05),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                color: notification.isRead 
                                    ? Colors.transparent 
                                    : const Color(0xFFFF6B9D),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.title,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF333333),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    notification.content,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF666666),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    _formatTime(notification.scheduleDateTime),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      if (diff.inMinutes < 1) {
        return 'Just now';
      } else if (diff.inHours < 1) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inDays < 1) {
        return '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      } else {
        return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return dateTimeStr;
    }
  }
}
