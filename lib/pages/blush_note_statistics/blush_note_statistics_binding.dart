import 'package:get/get.dart';
import 'blush_note_statistics_logic.dart';

class BlushNoteStatisticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BlushNoteStatisticsLogic>(() => BlushNoteStatisticsLogic());
  }
}
