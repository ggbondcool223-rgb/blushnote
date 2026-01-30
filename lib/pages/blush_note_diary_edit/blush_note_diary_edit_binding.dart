import 'package:get/get.dart';
import 'blush_note_diary_edit_logic.dart';

class BlushNoteDiaryEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BlushNoteDiaryEditLogic());
  }
}
