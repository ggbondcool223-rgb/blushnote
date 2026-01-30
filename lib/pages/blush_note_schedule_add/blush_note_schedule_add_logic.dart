import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blush_note/db_blush_note/index.dart';
import 'package:blush_note/db_blush_note/db_blush_note_entity.dart';
import 'package:blush_note/utils/index.dart';

class BlushNoteScheduleAddLogic extends GetxController {
  int? scheduleId;
  
  final content = ''.obs;
  final selectedColor = 0.obs;
  final dateTime = DateTime.now().obs;
  final repeatType = 'none'.obs;
  final repeatEndDate = Rxn<DateTime>();
  final reminderType = 'same_day'.obs;
  final isCompleted = false.obs;
  
  late TextEditingController contentController;
  
  final colors = const [
    Color(0xFFFF6B9D),
    Color(0xFFFFB74D),
    Color(0xFF64B5F6),
    Color(0xFFBA68C8),
    Color(0xFF81C784),
    Color(0xFFFFD54F),
  ];
  
  final repeatOptions = const [
    'none',
    'daily',
    'weekly',
    'monthly',
    'yearly',
  ];
  
  final repeatLabels = const {
    'none': 'No Repeat',
    'daily': 'Every Day',
    'weekly': 'Every Week',
    'monthly': 'Every Month',
    'yearly': 'Every Year',
  };
  
  final reminderOptions = const [
    'none',
    'same_day',
    'one_day',
    'three_days',
    'one_week',
  ];
  
  final reminderLabels = const {
    'none': 'No Reminder',
    'same_day': 'Same Day',
    'one_day': '1 Day Before',
    'three_days': '3 Days Before',
    'one_week': '1 Week Before',
  };
  
  final isLoading = false.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    contentController = TextEditingController();
    contentController.addListener(() {
      content.value = contentController.text;
    });
    
    final args = Get.arguments as Map<String, dynamic>?;
    scheduleId = args?['scheduleId'];
    
    if (scheduleId != null) {
      _loadSchedule();
    }
  }

  Future<void> _loadSchedule() async {
    try {
      isLoading.value = true;
      
      final schedule = await db.getScheduleById(scheduleId!);
      if (schedule == null) {
        errorToast('Schedule not found');
        Get.back();
        return;
      }
      
      contentController.text = schedule.content;
      selectedColor.value = _getColorIndex(schedule.eventColor);
      dateTime.value = DateTime.parse(schedule.dateTime);
      repeatType.value = schedule.repeatType;
      if (schedule.repeatEndDate != null) {
        repeatEndDate.value = DateTime.parse(schedule.repeatEndDate!);
      }
      reminderType.value = schedule.reminderType;
      isCompleted.value = schedule.isCompleted == 1;
    } catch (e) {
      errorToast('Failed to load schedule');
      print('Error loading schedule: $e');
    } finally {
      isLoading.value = false;
    }
  }

  int _getColorIndex(String colorHex) {
    try {
      final color = Color(int.parse('0x$colorHex'));
      final index = colors.indexWhere((c) => c.value == color.value);
      return index >= 0 ? index : 0;
    } catch (e) {
      return 0;
    }
  }

  void selectColor(int index) {
    if (index >= 0 && index < colors.length) {
      selectedColor.value = index;
    }
  }

  Future<void> selectDate() async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: dateTime.value,
      firstDate: DateTime(2020, 1),
      lastDate: DateTime(2030, 12),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6B9D),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      dateTime.value = DateTime(
        date.year,
        date.month,
        date.day,
      );
    }
  }

  Future<void> selectRepeatType() async {
    final selected = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Repeat'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: repeatOptions.length,
            itemBuilder: (context, index) {
              final option = repeatOptions[index];
              final isSelected = repeatType.value == option;
              
              return ListTile(
                title: Text(repeatLabels[option]!),
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () => Get.back(result: option),
              );
            },
          ),
        ),
      ),
    );
    
    if (selected != null) {
      repeatType.value = selected;
      
      if (selected != 'none' && repeatEndDate.value == null) {
        await _selectRepeatEndDate();
      }
    }
  }

  Future<void> _selectRepeatEndDate() async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: dateTime.value.add(const Duration(days: 365)),
      firstDate: dateTime.value,
      lastDate: DateTime(2030, 12),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6B9D),
            ),
          ),
          child: child!,
        );
      },
      helpText: 'Repeat Until',
    );
    
    if (date != null) {
      repeatEndDate.value = date;
    }
  }

  Future<void> selectReminderType() async {
    final selected = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Reminder'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: reminderOptions.length,
            itemBuilder: (context, index) {
              final option = reminderOptions[index];
              final isSelected = reminderType.value == option;
              
              return ListTile(
                title: Text(reminderLabels[option]!),
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () => Get.back(result: option),
              );
            },
          ),
        ),
      ),
    );
    
    if (selected != null) {
      reminderType.value = selected;
    }
  }

  void toggleComplete() {
    isCompleted.value = !isCompleted.value;
  }

  bool validate() {
    if (content.value.trim().isEmpty) {
      errorToast('Please enter schedule content');
      return false;
    }
    
    if (content.value.length > 60) {
      errorToast('Content must be 60 characters or less');
      return false;
    }
    
    return true;
  }

  Future<void> save() async {
    if (!validate()) return;
    
    try {
      isSaving.value = true;
      
      final now = DateTime.now().toIso8601String();
      final colorHex = colors[selectedColor.value].value.toRadixString(16).substring(2);
      
      if (scheduleId == null) {
        final schedule = Schedule(
          content: content.value.trim(),
          eventColor: colorHex,
          dateTime: dateTime.value.toIso8601String(),
          repeatType: repeatType.value,
          repeatEndDate: repeatEndDate.value?.toIso8601String(),
          reminderType: reminderType.value,
          isCompleted: isCompleted.value ? 1 : 0,
          parentId: null,
          createdAt: now,
          updatedAt: now,
        );
        
        await db.insertSchedule(schedule);
        successToast('Schedule added');
      } else {
        final original = await db.getScheduleById(scheduleId!);
        if (original == null) {
          errorToast('Schedule not found');
          return;
        }
        
        final schedule = Schedule(
          id: scheduleId,
          content: content.value.trim(),
          eventColor: colorHex,
          dateTime: dateTime.value.toIso8601String(),
          repeatType: repeatType.value,
          repeatEndDate: repeatEndDate.value?.toIso8601String(),
          reminderType: reminderType.value,
          isCompleted: isCompleted.value ? 1 : 0,
          parentId: original.parentId,
          createdAt: original.createdAt,
          updatedAt: now,
        );
        
        await db.updateSchedule(schedule);
        successToast('Schedule updated');
      }
      
      Get.back();
    } catch (e) {
      errorToast('Failed to save schedule');
      print('Error saving schedule: $e');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    contentController.dispose();
    super.onClose();
  }
}
