import 'package:get/get.dart';
import 'blush_note_home_logic.dart';

class BlushNoteHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BlushNoteHomeLogic());
  }
}
