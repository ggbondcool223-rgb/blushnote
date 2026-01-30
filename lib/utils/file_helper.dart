import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileHelper {
  static Future<String> getHandbookImageDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final handbookDir = Directory(path.join(appDir.path, 'handbook_images'));
    
    if (!await handbookDir.exists()) {
      await handbookDir.create(recursive: true);
    }
    
    return handbookDir.path;
  }

  static Future<String> saveImageFile(File imageFile) async {
    try {
      final dir = await getHandbookImageDir();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path);
      final fileName = 'handbook_$timestamp$extension';
      final targetPath = path.join(dir, fileName);
      
      await imageFile.copy(targetPath);
      
      return targetPath;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteImageFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
    }
  }

  static Future<void> deleteHandbookImages(List<String> imagePaths) async {
    for (final imagePath in imagePaths) {
      await deleteImageFile(imagePath);
    }
  }
}
