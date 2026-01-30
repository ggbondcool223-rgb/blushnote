import 'package:get/get.dart';
import 'package:blush_note/components/global_notification_dialog.dart';
import 'package:blush_note/db_blush_note/index.dart';
import 'package:intl/intl.dart';

class BlushNoteHomeLogic extends GetxController {
  final todayScheduleCount = 0.obs;
  
  final todayDiaries = <Diary>[].obs;
  final todayHandbooks = <Handbook>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadTodayScheduleCount();
    _loadTodayContent();
    _checkAndShowNotification();
  }
  
  Future<void> _loadTodayScheduleCount() async {
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
      
      todayScheduleCount.value = schedules.length;
    } catch (e) {
      print('Error loading schedule count: $e');
    }
  }
  
  Future<void> _loadTodayContent() async {
    try {
      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);
      
      final diaries = await db.getDiariesByDate(todayStr);
      todayDiaries.value = diaries;
      
      final handbooks = await db.getHandbooksByDate(todayStr);
      todayHandbooks.value = handbooks;
    } catch (e) {
      print('Error loading today content: $e');
    }
  }
  
  void _checkAndShowNotification() {
    GlobalNotificationDialog.showIfNeeded();
  }
  
  Future<void> refreshData() async {
    await _loadTodayScheduleCount();
    await _loadTodayContent();
  }
}
