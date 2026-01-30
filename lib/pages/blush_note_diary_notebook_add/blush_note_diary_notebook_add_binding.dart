import 'package:get/get.dart';
import 'blush_note_diary_notebook_add_logic.dart';

class BlushNoteDiaryNotebookAddBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BlushNoteDiaryNotebookAddLogic());
  }
}
