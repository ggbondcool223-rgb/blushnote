import 'package:get/get.dart';

import 'blush_note_update_logic.dart';

class BlushNoteUpdateBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      BlushNoteUpdateLogic(),
      permanent: true,
    );
  }
}
