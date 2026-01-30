import 'package:get/get.dart';
import 'blush_note_handbook_edit_logic.dart';

class BlushNoteHandbookEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BlushNoteHandbookEditLogic());
  }
}
