import 'package:get/get.dart';
import 'blush_note_schedule_logic.dart';

class BlushNoteScheduleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BlushNoteScheduleLogic());
  }
}
