import 'package:get/get.dart';
import 'blush_note_schedule_add_logic.dart';

class BlushNoteScheduleAddBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BlushNoteScheduleAddLogic());
  }
}
