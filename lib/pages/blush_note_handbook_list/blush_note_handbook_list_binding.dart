import 'package:get/get.dart';
import 'blush_note_handbook_list_logic.dart';

class BlushNoteHandbookListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BlushNoteHandbookListLogic());
  }
}
