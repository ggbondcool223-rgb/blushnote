import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:blush_note/utils/colors.dart';
import 'blush_note_schedule_add_logic.dart';

class BlushNoteScheduleAddView extends GetView<BlushNoteScheduleAddLogic> {
  const BlushNoteScheduleAddView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlushNoteColors.bgMain,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: Colors.grey.shade400,
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Schedule',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: BlushNoteColors.textMain,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check_circle,
              color: BlushNoteColors.accent,
              size: 28.w,
            ),
            onPressed: () => controller.save(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            _buildContentCard(),
            SizedBox(height: 24.h),
            _buildSettingsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          TextField(
            controller: controller.contentController,
            decoration: InputDecoration(
              hintText: 'Task content',
              hintStyle: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey.shade200,
              ),
              border: InputBorder.none,
            ),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: BlushNoteColors.textMain,
            ),
            maxLines: 4,
            maxLength: 60,
            buildCounter:
                (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) => null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Obx(
              () => Text(
                '${controller.content.value.length} / 60',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: BlushNoteColors.textSub,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.push_pin,
              size: 40.w,
              color: BlushNoteColors.accent.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Column(
      children: [
        _buildSettingRow(
          'Event Color',
          trailing: Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: controller.colors.asMap().entries.map((entry) {
                final index = entry.key;
                final color = entry.value;
                return Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: GestureDetector(
                    onTap: () => controller.selectColor(index),
                    child: _buildColorDot(
                      color,
                      controller.selectedColor.value == index,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        _buildSettingRow(
          'Date',
          onTap: () => controller.selectDate(),
          trailing: Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('yyyy-MM-dd').format(controller.dateTime.value),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: BlushNoteColors.accent,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.chevron_right,
                  size: 16.w,
                  color: BlushNoteColors.accent,
                ),
              ],
            ),
          ),
        ),
        _buildSettingRow(
          'Repeat',
          onTap: () => controller.selectRepeatType(),
          trailing: Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.repeatLabels[controller.repeatType.value] ??
                      'No Repeat',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: BlushNoteColors.textSub,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.chevron_right,
                  size: 16.w,
                  color: BlushNoteColors.textSub,
                ),
              ],
            ),
          ),
        ),
        _buildSettingRow(
          'Reminder',
          onTap: () => controller.selectReminderType(),
          trailing: Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.reminderLabels[controller.reminderType.value] ??
                      'No Reminder',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: BlushNoteColors.textSub,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.chevron_right,
                  size: 16.w,
                  color: BlushNoteColors.textSub,
                ),
              ],
            ),
          ),
        ),
        _buildSettingRow(
          'Completed',
          trailing: Obx(
            () => _buildToggle(
              controller.isCompleted.value,
              controller.toggleComplete,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow(
    String label, {
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: const Color(0xFFFDF0F5), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: BlushNoteColors.textMain,
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color, bool selected) {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: selected ? Border.all(color: Colors.white, width: 2) : null,
        boxShadow: selected
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildToggle(bool value, VoidCallback onChanged) {
    return GestureDetector(
      onTap: onChanged,
      child: Container(
        width: 44.w,
        height: 24.h,
        decoration: BoxDecoration(
          color: value ? BlushNoteColors.accent : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20.w,
            height: 20.w,
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
