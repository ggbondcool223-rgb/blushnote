import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:blush_note/utils/colors.dart';
import 'package:blush_note/components/global_notification_dialog.dart';
import 'package:blush_note/services/notification_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'blush_note_home_logic.dart';

class BlushNoteHomeView extends GetView<BlushNoteHomeLogic> {
  const BlushNoteHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlushNoteColors.bgMain,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildDecorationArea(),
              _buildMainFunctions(),
              _buildRemindersSection(),
              _buildTodaySection(),
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Note',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: BlushNoteColors.textMain,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'My Moments • Recording Beautiful Life',
                  style: TextStyle(
                      fontSize: 14.sp, color: BlushNoteColors.textSub),
                ),
              ],
            ),
          ),
          Obx(() {
            final hasUnread = notificationService.hasUnreadNotifications.value;
            return GestureDetector(
              onTap: () => GlobalNotificationDialog.show(),
              child: Stack(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: hasUnread
                          ? const Color(0xFFFFE8F0)
                          : Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasUnread
                          ? Icons.notifications_active
                          : Icons.notifications_outlined,
                      size: 22.sp,
                      color: hasUnread
                          ? const Color(0xFFFF6B9D)
                          : Colors.grey[600],
                    ),
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B9D),
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16.w,
                          minHeight: 16.w,
                        ),
                        child: Center(
                          child: Text(
                            '${notificationService.unreadCount}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDecorationArea() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      height: 176.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        image: DecorationImage(
          image: AssetImage('assets/bg.avif'),
          fit: BoxFit.cover,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BlushNoteColors.primary.withValues(alpha: 0.4),
            BlushNoteColors.accent.withValues(alpha: 0.2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: BlushNoteColors.primary.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20.w,
            top: -20.h,
            child: Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            left: -30.w,
            bottom: -30.h,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 24.h,
            left: 24.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, Darling!',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF535353),
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.4),
                        offset: const Offset(0, 0),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                Text(
                  'Record your happy moments today~',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF797878),
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.35),
                        offset: const Offset(0, 0),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFunctions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFunctionItem(
            icon: Icons.menu_book,
            label: 'Diary',
            color: Colors.pink.shade400,
            bgColor: Colors.pink.shade50,
            onTap: () => Get.toNamed('/diary'),
          ),
          _buildFunctionItem(
            icon: Icons.palette,
            label: 'Handbook',
            color: Colors.orange.shade400,
            bgColor: Colors.orange.shade50,
            onTap: () => Get.toNamed('/handbook'),
          ),
          _buildFunctionItem(
            icon: Icons.account_balance_wallet,
            label: 'Accounting',
            color: Colors.blue.shade400,
            bgColor: Colors.blue.shade50,
            onTap: () => Get.toNamed('/accounting'),
          ),
          _buildFunctionItem(
            icon: Icons.event_note,
            label: 'Schedule',
            color: Colors.purple.shade400,
            bgColor: Colors.purple.shade50,
            onTap: () => Get.toNamed('/schedule'),
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionItem({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, size: 24.w, color: color),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: BlushNoteColors.textMain),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: BlushNoteColors.accent,
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Reminders',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: BlushNoteColors.textMain,
                    ),
                  ),
                ],
              ),
              Obx(() {
                final count = controller.todayScheduleCount.value;
                if (count == 0) return const SizedBox.shrink();
                
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '$count ${count == 1 ? 'Task' : 'Tasks'}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: BlushNoteColors.accent,
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final count = controller.todayScheduleCount.value;
            
            if (count == 0) {
              return Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.pink.shade50, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48.sp,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'No pending tasks today',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return GestureDetector(
              onTap: () => Get.toNamed('/schedule'),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.pink.shade50, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8F0),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.event_note,
                        size: 24.sp,
                        color: BlushNoteColors.accent,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Schedule',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: BlushNoteColors.textMain,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'You have $count pending ${count == 1 ? 'task' : 'tasks'}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: BlushNoteColors.textSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 24.sp,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTodaySection() {
    return Obx(() {
      final hasDiaries = controller.todayDiaries.isNotEmpty;
      final hasHandbooks = controller.todayHandbooks.isNotEmpty;
      
      if (!hasDiaries && !hasHandbooks) {
        return const SizedBox.shrink();
      }

      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: BlushNoteColors.secondary,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: BlushNoteColors.textMain,
                      ),
                    ),
                  ],
                ),
                Text(
                  todayStr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: BlushNoteColors.textSub,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ...controller.todayDiaries.map((diary) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _buildDiaryCard(diary),
              );
            }),
            ...controller.todayHandbooks.map((handbook) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _buildHandbookCard(handbook),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildDiaryCard(dynamic diary) {
    List<dynamic> images = [];
    try {
      images = jsonDecode(diary.imagesJson);
    } catch (e) {
    }
    final hasImage = images.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          '/diary/edit',
          arguments: {'diaryId': diary.id},
        );
      },
      child: _buildTodayCard(
        icon: Icons.menu_book,
        iconColor: BlushNoteColors.accent,
        category: 'DIARY',
        title: diary.title,
        content: diary.content,
        hasImage: hasImage,
      ),
    );
  }

  Widget _buildHandbookCard(dynamic handbook) {
    final hasImage = handbook.imagePath != null && handbook.imagePath!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          '/handbook/edit',
          arguments: {'handbookId': handbook.id},
        );
      },
      child: _buildTodayCard(
        icon: Icons.palette,
        iconColor: Colors.orange.shade400,
        category: 'HANDBOOK',
        title: handbook.title,
        content: _extractTextFromHandbook(handbook),
        hasImage: hasImage,
      ),
    );
  }

  String _extractTextFromHandbook(dynamic handbook) {
    try {
      final elements = jsonDecode(handbook.elementsJson) as List;
      final textElements = elements
          .where((e) => e['type'] == 'text')
          .map((e) => e['text'] as String)
          .join(' ');
      return textElements.isNotEmpty ? textElements : 'Handbook content';
    } catch (e) {
      return 'Handbook content';
    }
  }

  Widget _buildTodayCard({
    required IconData icon,
    required Color iconColor,
    required String category,
    required String title,
    required String content,
    required bool hasImage,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.pink.shade50, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    iconColor.withValues(alpha: 0.2),
                    iconColor.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Icon(
                Icons.image,
                size: 32.w,
                color: iconColor.withValues(alpha: 0.3),
              ),
            )
          else
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.orange.shade50,
              ),
              child: Icon(
                Icons.image,
                size: 32.w,
                color: Colors.orange.shade200,
              ),
            ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 10.w, color: iconColor),
                    SizedBox(width: 4.w),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: BlushNoteColors.textMain,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: BlushNoteColors.textSub,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
