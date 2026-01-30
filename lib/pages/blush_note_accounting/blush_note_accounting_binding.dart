import 'package:get/get.dart';
import 'blush_note_accounting_logic.dart';

class BlushNoteAccountingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BlushNoteAccountingLogic());
  }
}
