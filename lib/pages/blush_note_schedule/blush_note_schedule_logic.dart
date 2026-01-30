import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:blush_note/db_blush_note/index.dart';
import 'package:blush_note/db_blush_note/db_blush_note_entity.dart';
import 'package:blush_note/utils/index.dart';
import 'package:blush_note/utils/colors.dart';

class BlushNoteScheduleLogic extends GetxController {
  final currentYearMonth = ''.obs;
  
  final schedules = <Schedule>[].obs;
  final expandedSchedules = <ExpandedSchedule>[].obs;
  
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    currentYearMonth.value = getYearMonth(DateTime.now());
    loadMonthSchedules();
  }

  Future<void> loadMonthSchedules() async {
    try {
      isLoading.value = true;
      
      final date = parseYearMonth(currentYearMonth.value);
      final startDate = DateTime(date.year, date.month, 1);
      final endDate = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
      
      final result = await db.getSchedules(
        startDate: startDate.toIso8601String(),
        endDate: endDate.toIso8601String(),
      );
      
      schedules.value = result;
      
      _expandRepeatingSchedules(startDate, endDate);
    } catch (e) {
      errorToast('Failed to load schedules');
      print('Error loading schedules: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _expandRepeatingSchedules(DateTime startDate, DateTime endDate) {
    final expanded = <ExpandedSchedule>[];
    
    for (var schedule in schedules) {
      final scheduleDate = DateTime.parse(schedule.dateTime);
      
      if (schedule.repeatType == 'none') {
        if (scheduleDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            scheduleDate.isBefore(endDate.add(const Duration(days: 1)))) {
          expanded.add(ExpandedSchedule(
            schedule: schedule,
            displayDate: scheduleDate,
          ));
        }
      } else {
        final occurrences = _generateOccurrences(
          schedule,
          scheduleDate,
          startDate,
          endDate,
        );
        expanded.addAll(occurrences);
      }
    }
    
    expanded.sort((a, b) => a.displayDate.compareTo(b.displayDate));
    expandedSchedules.value = expanded;
  }

  List<ExpandedSchedule> _generateOccurrences(
    Schedule schedule,
    DateTime originalDate,
    DateTime rangeStart,
    DateTime rangeEnd,
  ) {
    final occurrences = <ExpandedSchedule>[];
    final repeatEndDate = schedule.repeatEndDate != null
        ? DateTime.parse(schedule.repeatEndDate!)
        : rangeEnd;
    
    switch (schedule.repeatType) {
      case 'daily':
        var current = originalDate;
        while (current.isBefore(repeatEndDate.add(const Duration(days: 1)))) {
          if (current.isAfter(rangeStart.subtract(const Duration(days: 1))) &&
              current.isBefore(rangeEnd.add(const Duration(days: 1)))) {
            occurrences.add(ExpandedSchedule(
              schedule: schedule,
              displayDate: current,
            ));
          }
          current = current.add(const Duration(days: 1));
        }
        break;
        
      case 'weekly':
        var current = originalDate;
        while (current.isBefore(repeatEndDate.add(const Duration(days: 1)))) {
          if (current.isAfter(rangeStart.subtract(const Duration(days: 1))) &&
              current.isBefore(rangeEnd.add(const Duration(days: 1)))) {
            occurrences.add(ExpandedSchedule(
              schedule: schedule,
              displayDate: current,
            ));
          }
          current = current.add(const Duration(days: 7));
        }
        break;
        
      case 'monthly':
        var current = originalDate;
        while (current.isBefore(repeatEndDate.add(const Duration(days: 1)))) {
          if (current.isAfter(rangeStart.subtract(const Duration(days: 1))) &&
              current.isBefore(rangeEnd.add(const Duration(days: 1)))) {
            occurrences.add(ExpandedSchedule(
              schedule: schedule,
              displayDate: current,
            ));
          }
          final nextMonth = current.month == 12 ? 1 : current.month + 1;
          final nextYear = current.month == 12 ? current.year + 1 : current.year;
          current = DateTime(nextYear, nextMonth, current.day);
        }
        break;
        
      case 'yearly':
        var current = originalDate;
        while (current.isBefore(repeatEndDate.add(const Duration(days: 1)))) {
          if (current.isAfter(rangeStart.subtract(const Duration(days: 1))) &&
              current.isBefore(rangeEnd.add(const Duration(days: 1)))) {
            occurrences.add(ExpandedSchedule(
              schedule: schedule,
              displayDate: current,
            ));
          }
          current = DateTime(current.year + 1, current.month, current.day);
        }
        break;
    }
    
    return occurrences;
  }

  Future<void> showMonthPicker() async {
    final currentDate = parseYearMonth(currentYearMonth.value);
    int selectedYear = currentDate.year;
    int selectedMonth = currentDate.month;

    final result = await Get.dialog<DateTime>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(24.w),
              width: 320.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select Month',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: BlushNoteColors.textMain,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            selectedYear--;
                          });
                        },
                        icon: const Icon(Icons.chevron_left),
                        color: BlushNoteColors.accent,
                      ),
                      SizedBox(
                        width: 80.w,
                        child: Text(
                          '$selectedYear',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: BlushNoteColors.textMain,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            selectedYear++;
                          });
                        },
                        icon: const Icon(Icons.chevron_right),
                        color: BlushNoteColors.accent,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 2.0,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final month = index + 1;
                      final isSelected = month == selectedMonth;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedMonth = month;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? BlushNoteColors.accent
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _getMonthName(month),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : BlushNoteColors.textMain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: BlushNoteColors.textSub,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.back(
                            result: DateTime(selectedYear, selectedMonth, 1),
                          ),
                          child: Container(
                            height: 48.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  BlushNoteColors.accent,
                                  BlushNoteColors.accent.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: BlushNoteColors.accent.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Confirm',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    if (result != null) {
      changeMonth(getYearMonth(result));
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Future<void> changeMonth(String yearMonth) async {
    if (yearMonth == currentYearMonth.value) return;
    
    currentYearMonth.value = yearMonth;
    await loadMonthSchedules();
  }

  Future<void> toggleComplete(int scheduleId, bool isCompleted) async {
    try {
      await db.toggleScheduleComplete(scheduleId, isCompleted ? 1 : 0);
      await refreshData();
    } catch (e) {
      errorToast('Failed to update status');
      print('Error toggling complete: $e');
    }
  }

  Future<void> deleteSchedule(int scheduleId) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Schedule'),
          content: const Text('Are you sure you want to delete this schedule?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        await db.deleteSchedule(scheduleId);
        successToast('Schedule deleted');
        await refreshData();
      }
    } catch (e) {
      errorToast('Failed to delete schedule');
      print('Error deleting schedule: $e');
    }
  }

  Future<void> goToAddPage({int? scheduleId}) async {
    await Get.toNamed(
      '/schedule/add',
      arguments: {'scheduleId': scheduleId},
    );
    await refreshData();
  }

  Future<void> refreshData() async {
    await loadMonthSchedules();
  }
}

class ExpandedSchedule {
  final Schedule schedule;
  final DateTime displayDate;
  
  ExpandedSchedule({
    required this.schedule,
    required this.displayDate,
  });
}
