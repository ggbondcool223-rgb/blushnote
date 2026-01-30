import 'package:get/get.dart';
import 'blush_note_accounting_add_logic.dart';

class BlushNoteAccountingAddBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BlushNoteAccountingAddLogic());
  }
}
