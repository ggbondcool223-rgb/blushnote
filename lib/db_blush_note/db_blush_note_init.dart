import 'package:get/get.dart';
import 'data.dart';

Future<void> initDatabase() async {
  await Get.putAsync<BlushNoteDatabase>(() async {
    final db = BlushNoteDatabase();
    await db.database;
    return db;
  });
}

BlushNoteDatabase get db => Get.find<BlushNoteDatabase>();
