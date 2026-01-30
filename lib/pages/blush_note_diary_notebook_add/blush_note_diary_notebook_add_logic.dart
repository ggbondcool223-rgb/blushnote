import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blush_note/db_blush_note/index.dart';
import 'package:blush_note/db_blush_note/db_blush_note_entity.dart';
import 'package:blush_note/utils/index.dart';

class BlushNoteDiaryNotebookAddLogic extends GetxController {
  final selectedCover = 'book'.obs;
  final notebookName = ''.obs;
  
  late TextEditingController nameController;
  
  final coverColors = const [
    Color(0xFFFFB6C1),
    Color(0xFFFFDAB9),
    Color(0xFFB0E0E6),
    Color(0xFFDDA0DD),
    Color(0xFF98FB98),
    Color(0xFFFAFAD2),
    Color(0xFFFFB347),
    Color(0xFF87CEEB),
    Color(0xFFBA55D3),
    Color(0xFF90EE90),
    Color(0xFFFFE4B5),
    Color(0xFF7B68EE),
  ];
  
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    nameController = TextEditingController();
    nameController.addListener(() {
      notebookName.value = nameController.text;
    });
  }

  void selectCover(String cover) {
    selectedCover.value = cover;
  }

  bool validate() {
    if (notebookName.value.trim().isEmpty) {
      errorToast('Please enter notebook name');
      return false;
    }
    
    if (notebookName.value.length > 20) {
      errorToast('Name must be 20 characters or less');
      return false;
    }
    
    return true;
  }

  Future<void> save() async {
    if (!validate()) return;
    
    try {
      isSaving.value = true;
      
      final now = DateTime.now().toIso8601String();
      
      final notebook = Notebook(
        name: notebookName.value.trim(),
        cover: selectedCover.value,
        createdAt: now,
      );
      
      await db.insertNotebook(notebook);
      successToast('Notebook created');
      Get.back();
    } catch (e) {
      errorToast('Failed to create notebook');
      print('Error creating notebook: $e');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
