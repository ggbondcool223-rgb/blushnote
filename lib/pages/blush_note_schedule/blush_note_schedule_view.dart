import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:blush_note/utils/colors.dart';
import 'package:blush_note/utils/index.dart';
import 'package:intl/intl.dart';
import 'package:blush_note/components/notification_panel.dart';
import 'blush_note_schedule_logic.dart';

class BlushNoteScheduleView extends GetView<BlushNoteScheduleLogic> {
  const BlushNoteScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlushNoteColors.bgMain,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: BlushNoteColors.textMain,
          onPressed: () => Get.back(),
        ),
        title: GestureDetector(
          onTap: () => controller.showMonthPicker(),
          child: Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatYearMonthDisplay(controller.currentYearMonth.value),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: BlushNoteColors.accent,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20.w,
                  color: BlushNoteColors.accent,
                ),
              ],
            ),
          ),
        ),
        actions: [const NotificationBadgeIcon()],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.expandedSchedules.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_note_outlined,
                  size: 80.sp,
                  color: Colors.grey.shade300,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No schedules yet',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tap + to create your first schedule',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          );
        }

        final grouped = <String, List<dynamic>>{};
        for (var expanded in controller.expandedSchedules) {
          final dateKey = getDateString(expanded.displayDate);
          if (!grouped.containsKey(dateKey)) {
            grouped[dateKey] = [];
          }
          grouped[dateKey]!.add(expanded);
        }

        final dates = grouped.keys.toList()..sort();

        return Column(
          children: [
            const NotificationPanel(),

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final dateStr = dates[index];
                  final date = DateTime.parse(dateStr);
                  final items = grouped[dateStr]!;
                  return _buildDateRow(date, items);
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'schedule_fab',
        onPressed: () => controller.goToAddPage(),
        backgroundColor: BlushNoteColors.accent,
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDateRow(DateTime date, List items) {
    final day = date.day;
    final weekday = DateFormat('E').format(date);
    final hasSchedule = items.isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFFDF0F5), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44.w,
            child: Column(
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: hasSchedule
                        ? BlushNoteColors.textMain
                        : Colors.grey.shade300,
                  ),
                ),
                Text(
                  weekday,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: BlushNoteColors.textSub,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          if (hasSchedule)
            Expanded(
              child: Column(
                children: items.map((expanded) {
                  return _buildScheduleItem(expanded);
                }).toList(),
              ),
            )
          else
            Expanded(
              child: Text(
                'No plans',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade300,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(expanded) {
    final schedule = expanded.schedule;
    final isCompleted = schedule.isCompleted == 1;
    final color = Color(int.parse('0xFF${schedule.eventColor}'));

    return GestureDetector(
      onTap: () => controller.goToAddPage(scheduleId: schedule.id),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        child: Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Opacity(
                opacity: isCompleted ? 0.5 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.content,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: BlushNoteColors.textMain,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (isCompleted) ...[
                      SizedBox(height: 2.h),
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: BlushNoteColors.textSub,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () =>
                  controller.toggleComplete(schedule.id!, !isCompleted),
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 20.w,
                color: isCompleted
                    ? Colors.green.shade400
                    : Colors.grey.shade300,
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () => controller.deleteSchedule(schedule.id!),
              child: Icon(
                Icons.delete_outline,
                size: 20.w,
                color: Colors.grey.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
