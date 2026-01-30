import 'package:get/get.dart';
import 'blush_note_settings_logic.dart';

class BlushNoteSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BlushNoteSettingsLogic());
  }
}
