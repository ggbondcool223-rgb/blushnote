import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:blush_note/db_blush_note/index.dart';
import 'package:blush_note/utils/index.dart';

class BlushNoteHandbookEditLogic extends GetxController {
  int? handbookId;
  late TextEditingController titleController;
  
  final GlobalKey canvasKey = GlobalKey();
  
  final backgroundColorHex = 'FFFFFFFF'.obs;
  final elements = <Map<String, dynamic>>[].obs;
  
  final selectedTool = ''.obs;
  final isToolBarVisible = true.obs;
  final isDrawingMode = false.obs;
  final currentDrawingPoints = <Offset>[];
  final drawingUpdateTrigger = 0.obs;
  final drawingColorHex = 'FFFF0000'.obs;
  final brushWidth = 5.0.obs;
  final selectedTextId = Rxn<String>();
  final selectedImageId = Rxn<String>();
  final selectedStickerId = Rxn<String>();
  final isSaving = false.obs;
  
  final _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    titleController = TextEditingController();
    
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['handbookId'] != null) {
      handbookId = args['handbookId'] as int;
      loadHandbook();
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    super.onClose();
  }

  Future<void> loadHandbook() async {
    if (handbookId == null) return;
    
    try {
      final handbook = await db.getHandbookById(handbookId!);
      if (handbook != null) {
        titleController.text = handbook.title;
        backgroundColorHex.value = handbook.backgroundImage ?? 'FFFFFFFF';
        _deserializeElements(handbook.elementsJson);
      }
    } catch (e) {
      errorToast('Failed to load handbook: ${e.toString()}');
    }
  }

  void onTextToolTap() {
    if (selectedTool.value == 'Text') {
      selectedTool.value = '';
      isToolBarVisible.value = true;
    } else {
      selectedTool.value = 'Text';
      isDrawingMode.value = false;
      isToolBarVisible.value = false;
    }
  }

  void addTextElement() {
    final id = 'text_${DateTime.now().millisecondsSinceEpoch}';
    final element = {
      'type': 'text',
      'id': id,
      'content': 'Tap to edit',
      'fontSize': 24.0,
      'color': '#FFFFFF',
      'isBold': false,
      'isItalic': false,
      'x': 180.0,
      'y': 200.0,
    };
    elements.add(element);
    selectedTextId.value = id;
    successToast('Text added');
  }

  void selectTextElement(String id) {
    selectedTextId.value = id;
    selectedImageId.value = null;
    selectedStickerId.value = null;
    selectedTool.value = '';
    isToolBarVisible.value = false;
  }

  void updateTextContent(String id, String content) {
    final index = elements.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      elements[index]['content'] = content;
      elements.refresh();
    }
  }

  void updateTextStyle(
    String id, {
    double? fontSize,
    String? color,
    bool? isBold,
    bool? isItalic,
  }) {
    final index = elements.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      if (fontSize != null) elements[index]['fontSize'] = fontSize;
      if (color != null) elements[index]['color'] = color;
      if (isBold != null) elements[index]['isBold'] = isBold;
      if (isItalic != null) elements[index]['isItalic'] = isItalic;
      elements.refresh();
    }
  }

  void updateTextPosition(String id, double dx, double dy) {
    final index = elements.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      elements[index]['x'] = (elements[index]['x'] as double) + dx;
      elements[index]['y'] = (elements[index]['y'] as double) + dy;
      elements.refresh();
    }
  }

  void deleteTextElement(String id) {
    elements.removeWhere((e) => e['id'] == id);
    if (selectedTextId.value == id) {
      selectedTextId.value = null;
    }
    successToast('Text deleted');
  }

  void onImageToolTap() {
    if (selectedTool.value == 'Image') {
      selectedTool.value = '';
      isToolBarVisible.value = true;
    } else {
      selectedTool.value = 'Image';
      isDrawingMode.value = false;
      isToolBarVisible.value = false;
    }
  }

  Future<void> pickAndAddImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final imagePath = await FileHelper.saveImageFile(File(pickedFile.path));
      
      final id = 'image_${DateTime.now().millisecondsSinceEpoch}';
      final element = {
        'type': 'image',
        'id': id,
        'imagePath': imagePath,
        'x': 100.0,
        'y': 150.0,
        'width': 150.0,
        'height': 150.0,
        'scale': 1.0,
        'rotation': 0.0,
      };
      
      elements.add(element);
      selectedImageId.value = id;
      successToast('Image added');
    } catch (e) {
      errorToast('Failed to add image: ${e.toString()}');
    }
  }

  void selectImageElement(String id) {
    selectedImageId.value = id;
    selectedTextId.value = null;
    selectedStickerId.value = null;
    selectedTool.value = '';
    isToolBarVisible.value = false;
  }

  void updateImagePosition(String id, double dx, double dy) {
    final index = elements.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      elements[index]['x'] = (elements[index]['x'] as double) + dx;
      elements[index]['y'] = (elements[index]['y'] as double) + dy;
      elements.refresh();
    }
  }

  void updateImageScale(String id, double scale) {
    final index = elements.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      elements[index]['scale'] = scale;
      elements.refresh();
    }
  }

  void updateImageRotation(String id, double rotation) {
    final index = elements.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      elements[index]['rotation'] = rotation;
      elements.refresh();
    }
  }

  Future<void> deleteImageElement(String id) async {
    final index = elements.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      final imagePath = elements[index]['imagePath'] as String?;
      if (imagePath != null) {
        await FileHelper.deleteImageFile(imagePath);
      }
      elements.removeAt(index);
      if (selectedImageId.value == id) {
        selectedImageId.value = null;
      }
      successToast('Image deleted');
    }
  }

  void onStickerToolTap() {
    if (selectedTool.value == 'Sticker') {
      selectedTool.value = '';
      isToolBarVisible.value = true;
    } else {
      selectedTool.value = 'Sticker';
      isDrawingMode.value = false;
      isToolBarVisible.value = false;
    }
  }

  void addStickerElement(int iconCodePoint, String iconFamily) {
    final id = 'sticker_${DateTime.now().millisecondsSinceEpoch}';
    final element = {
      'type': 'sticker',
      'id': id,
      'iconCodePoint': iconCodePoint,
      'iconFamily': iconFamily,
      'x': 150.0,
      'y': 200.0,
      'size': 48.0,
      'color': '#FFE91E63',
      'scale': 1.0,
      'rotation': 0.0,
    };
    elements.add(element);
    selectedStickerId.value = id;
    successToast('Sticker added');
  }

  void selectStickerElement(String id) {
    selectedStickerId.value = id;
    selectedTextId.value = null;
    selectedImageId.value = null;
    selectedTool.value = '';
    isToolBarVisible.value = false;
  }

  void updateStickerPosition(String id, double dx, double dy) {
    final index = elements.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      elements[index]['x'] = (elements[index]['x'] as double) + dx;
      elements[index]['y'] = (elements[index]['y'] as double) + dy;
      elements.refresh();
    }
  }

  void updateStickerSize(String id, double size) {
    final index = elements.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      elements[index]['size'] = size;
      elements.refresh();
    }
  }

  void updateStickerColor(String id, Color color) {
    final index = elements.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      elements[index]['color'] = '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
      elements.refresh();
    }
  }

  void updateStickerScale(String id, double scale) {
    final index = elements.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      elements[index]['scale'] = scale;
      elements.refresh();
    }
  }

  void updateStickerRotation(String id, double rotation) {
    final index = elements.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      elements[index]['rotation'] = rotation;
      elements.refresh();
    }
  }

  void deleteStickerElement(String id) {
    elements.removeWhere((e) => e['id'] == id);
    if (selectedStickerId.value == id) {
      selectedStickerId.value = null;
    }
    successToast('Sticker deleted');
  }

  void onBgToolTap() {
    if (selectedTool.value == 'BG') {
      selectedTool.value = '';
      isToolBarVisible.value = true;
    } else {
      selectedTool.value = 'BG';
      isDrawingMode.value = false;
      isToolBarVisible.value = false;
    }
  }

  void selectBackgroundColor(Color color) {
    backgroundColorHex.value = color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
  }

  void onBrushToolTap() {
    if (selectedTool.value == 'Brush') {
      selectedTool.value = '';
      isDrawingMode.value = false;
      isToolBarVisible.value = true;
    } else {
      selectedTool.value = 'Brush';
      isDrawingMode.value = true;
      isToolBarVisible.value = false;
    }
  }

  void selectDrawingColor(Color color) {
    drawingColorHex.value = color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
  }

  void updateBrushWidth(double width) {
    brushWidth.value = width;
  }

  void startDrawing(Offset point) {
    if (!isDrawingMode.value) return;
    currentDrawingPoints.clear();
    currentDrawingPoints.add(point);
    drawingUpdateTrigger.value++;
  }

  void updateDrawing(Offset point) {
    if (!isDrawingMode.value) return;
    currentDrawingPoints.add(point);
    drawingUpdateTrigger.value++;
  }

  void endDrawing() {
    if (!isDrawingMode.value || currentDrawingPoints.length < 2) {
      currentDrawingPoints.clear();
      drawingUpdateTrigger.value++;
      return;
    }

    final id = 'drawing_${DateTime.now().millisecondsSinceEpoch}';
    final element = {
      'type': 'drawing',
      'id': id,
      'points': currentDrawingPoints
          .map((p) => {'x': p.dx, 'y': p.dy})
          .toList(),
      'strokeWidth': brushWidth.value,
      'color': '#$drawingColorHex',
    };
    elements.add(element);
    currentDrawingPoints.clear();
    drawingUpdateTrigger.value++;
  }

  void clearAllDrawings() {
    elements.removeWhere((e) => e['type'] == 'drawing');
    successToast('All drawings cleared');
  }

  void selectTool(String tool) {
    selectedTool.value = tool;
    if (tool == 'Brush') {
      isDrawingMode.value = true;
    } else {
      isDrawingMode.value = false;
    }
  }

  void closeToolPanel() {
    selectedTool.value = '';
    isDrawingMode.value = false;
    isToolBarVisible.value = true;
  }

  void closeEditPanel() {
    selectedTextId.value = null;
    selectedImageId.value = null;
    selectedStickerId.value = null;
    isToolBarVisible.value = true;
  }

  Future<void> onSaveTap() async {
    if (titleController.text.trim().isEmpty) {
      errorToast('Please enter a title');
      return;
    }

    if (elements.isEmpty) {
      errorToast('Please add at least one element');
      return;
    }

    try {
      isSaving.value = true;
      print('💾 开始保存手帐...');

      final now = DateTime.now().toIso8601String();
      
      final isNewHandbook = handbookId == null;
      String? imagePath;

      if (isNewHandbook) {
        print('📝 新建手帐模式');
        
        final handbook = Handbook(
          id: null,
          title: titleController.text.trim(),
          backgroundImage: backgroundColorHex.value,
          elementsJson: _serializeElements(),
          imagePath: null,
          createdAt: now,
          updatedAt: now,
        );

        final newId = await db.insertHandbook(handbook);
        print('✅ 手帐数据已插入，ID: $newId');
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        imagePath = await _exportAndSaveImage(newId);
        
        if (imagePath != null) {
          final updatedHandbook = Handbook(
            id: newId,
            title: titleController.text.trim(),
            backgroundImage: backgroundColorHex.value,
            elementsJson: _serializeElements(),
            imagePath: imagePath,
            createdAt: now,
            updatedAt: now,
          );
          await db.updateHandbook(updatedHandbook);
          print('✅ 图片路径已更新到数据库');
        } else {
          print('⚠️ 图片导出失败，但数据已保存');
        }
        
        successToast('Handbook created');
      } else {
        print('✏️ 编辑手帐模式，ID: $handbookId');
        
        imagePath = await _exportAndSaveImage(handbookId!);
        
        if (imagePath == null) {
          print('⚠️ 图片导出失败，尝试保留原图片路径');
          final oldHandbook = await db.getHandbookById(handbookId!);
          imagePath = oldHandbook?.imagePath;
        }
        
        final handbook = Handbook(
          id: handbookId,
          title: titleController.text.trim(),
          backgroundImage: backgroundColorHex.value,
          elementsJson: _serializeElements(),
          imagePath: imagePath,
          createdAt: (await db.getHandbookById(handbookId!))?.createdAt ?? now,
          updatedAt: now,
        );
        
        await db.updateHandbook(handbook);
        print('✅ 手帐数据已更新');
        successToast('Handbook updated');
      }

      Get.back();
    } catch (e) {
      print('❌ 保存失败: $e');
      errorToast('Failed to save: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  String _serializeElements() {
    return jsonEncode(elements);
  }

  void _deserializeElements(String json) {
    try {
      final decoded = jsonDecode(json) as List;
      elements.value = decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      errorToast('Failed to parse elements');
      elements.clear();
    }
  }
  
  Future<File?> exportCanvasToImage() async {
    try {
      final boundary = canvasKey.currentContext?.findRenderObject() 
          as RenderRepaintBoundary?;
      
      if (boundary == null) {
        errorToast('Failed to capture canvas');
        return null;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        errorToast('Failed to convert image');
        return null;
      }

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = Size(image.width.toDouble(), image.height.toDouble());
      
      final bgColorHex = backgroundColorHex.value;
      final bgColor = Color(int.parse('0x$bgColorHex'));
      final paint = Paint()..color = bgColor;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      
      canvas.drawImage(image, Offset.zero, Paint());
      
      final picture = recorder.endRecording();
      final finalImage = await picture.toImage(
        image.width,
        image.height,
      );
      final finalByteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      
      if (finalByteData == null) {
        errorToast('Failed to convert final image');
        return null;
      }

      final bytes = finalByteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/handbook_$timestamp.png');
      await file.writeAsBytes(bytes);

      image.dispose();
      finalImage.dispose();

      return file;
    } catch (e) {
      errorToast('Failed to export: ${e.toString()}');
      return null;
    }
  }

  Future<String?> _exportAndSaveImage(int handbookId) async {
    try {
      print('📸 开始导出图片，handbook ID: $handbookId');
      
      final tempFile = await exportCanvasToImage();
      if (tempFile == null) {
        print('❌ 导出画布失败');
        return null;
      }

      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/handbook_$handbookId.png';
      
      final targetFile = File(targetPath);
      if (await targetFile.exists()) {
        await targetFile.delete();
        print('🗑️ 已删除旧图片文件');
      }

      await tempFile.copy(targetPath);
      await tempFile.delete();
      
      print('✅ 图片已保存: $targetPath');
      return targetPath;
    } catch (e) {
      print('❌ 导出保存图片失败: $e');
      errorToast('Failed to save image: ${e.toString()}');
      return null;
    }
  }
}
