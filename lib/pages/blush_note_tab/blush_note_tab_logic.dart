import 'package:get/get.dart';
import 'package:blush_note/pages/blush_note_home/blush_note_home_logic.dart';

class BlushNoteTabLogic extends GetxController {
  final currentIndex = 0.obs;

  void onTabChange(int index) {
    if (currentIndex.value == index) return;
    currentIndex.value = index;
    
    if (index == 0) {
      try {
        final homeLogic = Get.find<BlushNoteHomeLogic>();
        homeLogic.refreshData();
      } catch (e) {
      }
    }
  }
}
