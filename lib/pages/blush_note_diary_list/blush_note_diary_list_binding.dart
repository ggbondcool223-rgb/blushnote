import 'package:get/get.dart';
import 'blush_note_diary_list_logic.dart';

class BlushNoteDiaryListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BlushNoteDiaryListLogic());
  }
}
