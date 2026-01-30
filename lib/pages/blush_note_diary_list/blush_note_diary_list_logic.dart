import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blush_note/db_blush_note/index.dart';
import 'package:blush_note/db_blush_note/db_blush_note_entity.dart';
import 'package:blush_note/utils/index.dart';

class BlushNoteDiaryListLogic extends GetxController {
  final notebooks = <Notebook>[].obs;
  final currentNotebookId = Rxn<int>();
  final currentNotebookName = 'All Diaries'.obs;
  
  final diaries = <Diary>[].obs;
  
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      await loadNotebooks();
      await loadDiaries();
    } catch (e) {
      errorToast('Failed to load data');
      print('Error loading diary data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadNotebooks() async {
    try {
      final result = await db.getNotebooks();
      notebooks.value = result;
    } catch (e) {
      print('Error loading notebooks: $e');
      rethrow;
    }
  }

  Future<void> loadDiaries() async {
    try {
      final result = await db.getDiaries(
        notebookId: currentNotebookId.value,
      );
      diaries.value = result;
    } catch (e) {
      print('Error loading diaries: $e');
      rethrow;
    }
  }

  Future<void> switchNotebook(int? notebookId) async {
    if (currentNotebookId.value == notebookId) return;
    
    currentNotebookId.value = notebookId;
    
    if (notebookId == null) {
      currentNotebookName.value = 'All Diaries';
    } else {
      final notebook = notebooks.firstWhereOrNull((n) => n.id == notebookId);
      currentNotebookName.value = notebook?.name ?? 'Unknown';
    }
    
    await loadDiaries();
  }

  int getDiaryCount() {
    return diaries.length;
  }

  Future<void> deleteDiary(int diaryId) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Diary'),
          content: const Text('Are you sure you want to delete this diary?'),
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
        await db.deleteDiary(diaryId);
        successToast('Diary deleted');
        await refreshData();
      }
    } catch (e) {
      errorToast('Failed to delete diary');
      print('Error deleting diary: $e');
    }
  }

  Future<void> editDiary({int? diaryId}) async {
    await Get.toNamed(
      '/diary/edit',
      arguments: {
        'diaryId': diaryId,
        'notebookId': currentNotebookId.value,
      },
    );
    await refreshData();
  }

  Future<void> addNotebook() async {
    await Get.toNamed('/diary/notebook/add');
    await refreshData();
  }

  Future<void> refreshData() async {
    await loadData();
  }
}
