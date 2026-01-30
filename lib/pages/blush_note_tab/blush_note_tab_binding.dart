import 'package:get/get.dart';
import 'package:blush_note/pages/blush_note_home/blush_note_home_logic.dart';
import 'package:blush_note/pages/blush_note_diary_list/blush_note_diary_list_logic.dart';
import 'package:blush_note/pages/blush_note_accounting/blush_note_accounting_logic.dart';
import 'package:blush_note/pages/blush_note_settings/blush_note_settings_logic.dart';
import 'blush_note_tab_logic.dart';

class BlushNoteTabBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BlushNoteTabLogic());
    Get.lazyPut(() => BlushNoteHomeLogic());
    Get.lazyPut(() => BlushNoteDiaryListLogic());
    Get.lazyPut(() => BlushNoteAccountingLogic());
    Get.lazyPut(() => BlushNoteSettingsLogic());
  }
}
