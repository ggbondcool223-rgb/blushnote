import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:blush_note/utils/colors.dart';
import 'blush_note_handbook_edit_logic.dart';

class BlushNoteHandbookEditView extends GetView<BlushNoteHandbookEditLogic> {
  const BlushNoteHandbookEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          iconSize: 28.w,
          onPressed: () => Get.back(),
        ),
        title: SizedBox(
          width: 200.w,
          child: TextField(
            controller: controller.titleController,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Add Title',
              hintStyle: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade300,
              ),
              border: InputBorder.none,
            ),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: BlushNoteColors.textMain,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isSaving.value
                    ? null
                    : controller.onSaveTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BlushNoteColors.accent,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 6.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  elevation: 2,
                ),
                child: controller.isSaving.value
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildCanvas()),
          Obx(
            () => controller.isToolBarVisible.value
                ? _buildToolBar()
                : const SizedBox.shrink(),
          ),
          Obx(() {
            if (controller.selectedTextId.value != null) {
              return _buildTextEditPanel();
            } else if (controller.selectedImageId.value != null) {
              return _buildImageEditPanel();
            } else if (controller.selectedStickerId.value != null) {
              return _buildStickerEditPanel();
            }
            else if (controller.selectedTool.value == 'Text') {
              return _buildTextToolPanel();
            } else if (controller.selectedTool.value == 'Image') {
              return _buildImageToolPanel();
            } else if (controller.selectedTool.value == 'BG') {
              return _buildBgToolPanel();
            } else if (controller.selectedTool.value == 'Brush') {
              return _buildBrushToolPanel();
            } else if (controller.selectedTool.value == 'Sticker') {
              return _buildStickerToolPanel();
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Obx(() {
        final bgColorHex = controller.backgroundColorHex.value;
        final bgColor = Color(int.parse('0x$bgColorHex'));

        return GestureDetector(
          onPanStart: (details) {
            if (controller.isDrawingMode.value) {
              controller.startDrawing(details.localPosition);
            } else {
              final hadSelection =
                  controller.selectedTextId.value != null ||
                  controller.selectedImageId.value != null ||
                  controller.selectedStickerId.value != null;

              controller.selectedTextId.value = null;
              controller.selectedImageId.value = null;
              controller.selectedStickerId.value = null;

              if (hadSelection) {
                controller.isToolBarVisible.value = true;
              }
            }
          },
          onPanUpdate: (details) {
            if (controller.isDrawingMode.value) {
              controller.updateDrawing(details.localPosition);
            }
          },
          onPanEnd: (_) {
            if (controller.isDrawingMode.value) {
              controller.endDrawing();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _DotPatternPainter()),
                  ),
                  Positioned.fill(
                    child: RepaintBoundary(
                      key: controller.canvasKey,
                      child: Container(
                        color: Colors.transparent,
                        child: Obx(() {
                          controller.drawingUpdateTrigger.value;

                          return Stack(
                            children: [
                              ...controller.elements
                                  .where((e) => e['type'] == 'drawing')
                                  .map((element) {
                                    return _buildDrawingElement(element);
                                  }),
                              ...controller.elements
                                  .where((e) => e['type'] == 'image')
                                  .map((element) {
                                    return _buildImageElement(element);
                                  }),
                              ...controller.elements
                                  .where((e) => e['type'] == 'sticker')
                                  .map((element) {
                                    return _buildStickerElement(element);
                                  }),
                              ...controller.elements
                                  .where((e) => e['type'] == 'text')
                                  .map((element) {
                                    return _buildTextElement(element);
                                  }),
                              if (controller.isDrawingMode.value &&
                                  controller.currentDrawingPoints.isNotEmpty)
                                CustomPaint(
                                  painter: _DrawingPainter(
                                    points: controller.currentDrawingPoints,
                                    color: Color(
                                      int.parse(
                                        '0x${controller.drawingColorHex.value}',
                                      ),
                                    ),
                                    strokeWidth: controller.brushWidth.value,
                                  ),
                                  size: Size.infinite,
                                ),
                              if (controller.elements.isEmpty &&
                                  !controller.isDrawingMode.value)
                                Center(
                                  child: Text(
                                    'Tap tools below to add content',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  if (controller.isDrawingMode.value)
                    Positioned(
                      top: 20.h,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'Drawing mode - Draw on canvas',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextElement(Map<String, dynamic> element) {
    final id = element['id'] as String;
    final content = element['content'] as String;
    final fontSize = element['fontSize'] as double;
    final colorHex = (element['color'] as String).replaceFirst('#', '');
    final color = Color(int.parse('0xFF$colorHex'));
    final isBold = element['isBold'] as bool;
    final isItalic = element['isItalic'] as bool;
    final x = element['x'] as double;
    final y = element['y'] as double;

    return Obx(() {
      final isSelected = controller.selectedTextId.value == id;

      return Positioned(
        left: x,
        top: y,
        child: GestureDetector(
          onTap: () => controller.selectTextElement(id),
          onPanUpdate: (details) {
            controller.updateTextPosition(
              id,
              details.delta.dx,
              details.delta.dy,
            );
          },
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(color: BlushNoteColors.accent, width: 2)
                  : null,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: fontSize.sp,
                color: color,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildImageElement(Map<String, dynamic> element) {
    final id = element['id'] as String;
    final imagePath = element['imagePath'] as String;
    final x = element['x'] as double;
    final y = element['y'] as double;
    final width = element['width'] as double;
    final height = element['height'] as double;
    final scale = element['scale'] as double;
    final rotation = element['rotation'] as double;

    return Obx(() {
      final isSelected = controller.selectedImageId.value == id;

      return Positioned(
        left: x,
        top: y,
        child: GestureDetector(
          onTap: () => controller.selectImageElement(id),
          onPanUpdate: (details) {
            controller.updateImagePosition(
              id,
              details.delta.dx,
              details.delta.dy,
            );
          },
          child: Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: rotation,
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  border: isSelected
                      ? Border.all(color: BlushNoteColors.accent, width: 3)
                      : Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: File(imagePath).existsSync()
                      ? Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStickerElement(Map<String, dynamic> element) {
    final id = element['id'] as String;
    final iconCodePoint = element['iconCodePoint'] as int;
    final iconFamily = element['iconFamily'] as String;
    final x = element['x'] as double;
    final y = element['y'] as double;
    final size = element['size'] as double;
    final colorHex = (element['color'] as String).replaceFirst('#', '');
    final color = Color(int.parse('0x$colorHex'));
    final scale = element['scale'] as double;
    final rotation = element['rotation'] as double;

    return Obx(() {
      final isSelected = controller.selectedStickerId.value == id;

      return Positioned(
        left: x,
        top: y,
        child: GestureDetector(
          onTap: () => controller.selectStickerElement(id),
          onPanUpdate: (details) {
            controller.updateStickerPosition(
              id,
              details.delta.dx,
              details.delta.dy,
            );
          },
          child: Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: rotation,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? BlushNoteColors.accent.withValues(alpha: 0.1)
                      : Colors.transparent,
                  border: isSelected
                      ? Border.all(color: BlushNoteColors.accent, width: 2)
                      : null,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.star,
                  size: size,
                  color: color,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDrawingElement(Map<String, dynamic> element) {
    final points = (element['points'] as List).map((p) {
      return Offset(p['x'] as double, p['y'] as double);
    }).toList();
    final colorHex = (element['color'] as String).replaceFirst('#', '');
    final color = Color(int.parse('0x$colorHex'));
    final strokeWidth = element['strokeWidth'] as double;

    return CustomPaint(
      painter: _DrawingPainter(
        points: points,
        color: color,
        strokeWidth: strokeWidth,
      ),
      size: Size.infinite,
    );
  }

  Widget _buildToolBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 32.w,
        children: [
          _buildToolButton(Icons.text_fields, 'Text', controller.onTextToolTap),
          _buildToolButton(Icons.image, 'Image', controller.onImageToolTap),
          _buildToolButton(Icons.palette, 'BG', controller.onBgToolTap),
          _buildToolButton(Icons.brush, 'Brush', controller.onBrushToolTap),
          _buildToolButton(
            Icons.emoji_emotions,
            'Sticker',
            controller.onStickerToolTap,
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String label, VoidCallback onTap) {
    return Obx(() {
      final isSelected = controller.selectedTool.value == label;
      return GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24.w,
              color: isSelected ? BlushNoteColors.accent : Colors.grey.shade600,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: isSelected
                    ? BlushNoteColors.accent
                    : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTextToolPanel() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Text Tool',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: controller.closeToolPanel,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.addTextElement,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Text'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BlushNoteColors.accent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Obx(() {
                final selectedId = controller.selectedTextId.value;
                return Expanded(
                  child: ElevatedButton.icon(
                    onPressed: selectedId != null
                        ? () => controller.deleteTextElement(selectedId)
                        : null,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final selectedId = controller.selectedTextId.value;
            if (selectedId != null) {
              final element = controller.elements.firstWhereOrNull(
                (e) => e['id'] == selectedId,
              );
              if (element != null) {
                return Row(
                  children: [
                    Text('Size:', style: TextStyle(fontSize: 12.sp)),
                    Expanded(
                      child: Slider(
                        value: element['fontSize'] as double,
                        min: 12,
                        max: 48,
                        onChanged: (value) {
                          controller.updateTextStyle(
                            selectedId,
                            fontSize: value,
                          );
                        },
                      ),
                    ),
                    Text(
                      '${(element['fontSize'] as double).toInt()}',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ],
                );
              }
            }
            return Text(
              'Select a text element to edit',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            );
          }),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildImageToolPanel() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Image Tool',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: controller.closeToolPanel,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.pickAndAddImage,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Pick Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BlushNoteColors.accent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Obx(() {
                final selectedId = controller.selectedImageId.value;
                return Expanded(
                  child: ElevatedButton.icon(
                    onPressed: selectedId != null
                        ? () => controller.deleteImageElement(selectedId)
                        : null,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final selectedId = controller.selectedImageId.value;
            if (selectedId != null) {
              final element = controller.elements.firstWhereOrNull(
                (e) => e['id'] == selectedId,
              );
              if (element != null) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Text('Scale:', style: TextStyle(fontSize: 12.sp)),
                        Expanded(
                          child: Slider(
                            value: element['scale'] as double,
                            min: 0.5,
                            max: 2.0,
                            onChanged: (value) {
                              controller.updateImageScale(selectedId, value);
                            },
                          ),
                        ),
                        Text(
                          '${(element['scale'] as double).toStringAsFixed(1)}x',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Rotation:', style: TextStyle(fontSize: 12.sp)),
                        Expanded(
                          child: Slider(
                            value: element['rotation'] as double,
                            min: -3.14159,
                            max: 3.14159,
                            onChanged: (value) {
                              controller.updateImageRotation(selectedId, value);
                            },
                          ),
                        ),
                        Text(
                          '${((element['rotation'] as double) * 57.2958).toStringAsFixed(0)}°',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ],
                );
              }
            }
            return Text(
              'Select an image to edit',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            );
          }),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildBgToolPanel() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Background Color',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: controller.closeToolPanel,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children:
                [
                  Colors.white,
                  const Color(0xFFFFF0F5),
                  const Color(0xFFFFE4E1),
                  const Color(0xFFFFEBCD),
                  const Color(0xFFFFFACD),
                  const Color(0xFFE0FFE0),
                  const Color(0xFFE0F8FF),
                  const Color(0xFFE6E6FA),
                ].map((color) {
                  return GestureDetector(
                    onTap: () => controller.selectBackgroundColor(color),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  );
                }).toList(),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildBrushToolPanel() {
    final colors = [
      Colors.black,
      Colors.white,
      const Color(0xFFFF4458),
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFF3F51B5),
      const Color(0xFF2196F3),
      const Color(0xFF00BCD4),
      const Color(0xFF009688),
      const Color(0xFF4CAF50),
      const Color(0xFFFFEB3B),
      const Color(0xFFFF9800),
      const Color(0xFFFF5722),
      const Color(0xFF795548),
      const Color(0xFF9E9E9E),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Brush Tool',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                iconSize: 20.sp,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.w),
                onPressed: controller.closeToolPanel,
              ),
            ],
          ),
          SizedBox(height: 8.h),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Color',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    SizedBox(
                      height: 40.h,
                      child: Obx(() {
                        final currentColorHex =
                            controller.drawingColorHex.value;
                        final currentColor = Color(
                          int.parse('0x$currentColorHex'),
                        );

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: colors.length,
                          itemBuilder: (context, index) {
                            final color = colors[index];
                            final isSelected =
                                currentColor.value == color.value;

                            return GestureDetector(
                              onTap: () => controller.selectDrawingColor(color),
                              child: Container(
                                width: 32.w,
                                height: 32.w,
                                margin: EdgeInsets.only(right: 6.w),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? BlushNoteColors.accent
                                        : color == Colors.white
                                        ? const Color(0xFFE0E0E0)
                                        : Colors.transparent,
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    if (isSelected)
                                      BoxShadow(
                                        color: BlushNoteColors.accent
                                            .withValues(alpha: 0.3),
                                        blurRadius: 6.r,
                                        offset: const Offset(0, 2),
                                      ),
                                  ],
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        color: color.computeLuminance() > 0.5
                                            ? Colors.black
                                            : Colors.white,
                                        size: 16.sp,
                                      )
                                    : null,
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Width',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: BlushNoteColors.accent,
                                inactiveTrackColor: Colors.grey.shade300,
                                thumbColor: BlushNoteColors.accent,
                                overlayColor: BlushNoteColors.accent.withValues(
                                  alpha: 0.2,
                                ),
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: 6.r,
                                ),
                                trackHeight: 3.h,
                              ),
                              child: Slider(
                                value: controller.brushWidth.value,
                                min: 1,
                                max: 20,
                                onChanged: controller.updateBrushWidth,
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${controller.brushWidth.value.toInt()}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: BlushNoteColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: controller.clearAllDrawings,
              icon: Icon(Icons.delete_outline_rounded, size: 16.sp),
              label: const Text('Clear All'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                padding: EdgeInsets.symmetric(vertical: 8.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerToolPanel() {
    final stickers = [
      {'icon': Icons.favorite, 'label': 'Heart'},
      {'icon': Icons.star, 'label': 'Star'},
      {'icon': Icons.emoji_emotions, 'label': 'Smile'},
      {'icon': Icons.thumb_up, 'label': 'Like'},
      {'icon': Icons.celebration, 'label': 'Party'},
      {'icon': Icons.cake, 'label': 'Cake'},
      {'icon': Icons.local_florist, 'label': 'Flower'},
      {'icon': Icons.sunny, 'label': 'Sun'},
      {'icon': Icons.nightlight, 'label': 'Moon'},
      {'icon': Icons.cloud, 'label': 'Cloud'},
      {'icon': Icons.pets, 'label': 'Pet'},
      {'icon': Icons.music_note, 'label': 'Music'},
    ];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sticker Tool',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: controller.closeToolPanel,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 180.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Sticker:',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 8.w,
                      mainAxisSpacing: 8.h,
                    ),
                    itemCount: stickers.length,
                    itemBuilder: (context, index) {
                      final sticker = stickers[index];
                      return GestureDetector(
                        onTap: () {
                          controller.addStickerElement(
                            (sticker['icon'] as IconData).codePoint,
                            (sticker['icon'] as IconData).fontFamily ??
                                'MaterialIcons',
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Icon(
                            sticker['icon'] as IconData,
                            size: 28.w,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final selectedId = controller.selectedStickerId.value;
            if (selectedId != null) {
              final element = controller.elements.firstWhereOrNull(
                (e) => e['id'] == selectedId,
              );
              if (element != null) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                controller.deleteStickerElement(selectedId),
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Text('Size:', style: TextStyle(fontSize: 12.sp)),
                        Expanded(
                          child: Slider(
                            value: element['size'] as double,
                            min: 24,
                            max: 96,
                            onChanged: (value) {
                              controller.updateStickerSize(selectedId, value);
                            },
                          ),
                        ),
                        Text(
                          '${(element['size'] as double).toInt()}',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Color:', style: TextStyle(fontSize: 12.sp)),
                        SizedBox(width: 8.w),
                        ...[
                          const Color(0xFFE91E63),
                          const Color(0xFFF44336),
                          const Color(0xFF9C27B0),
                          const Color(0xFF2196F3),
                          const Color(0xFF4CAF50),
                          const Color(0xFFFFEB3B),
                        ].map((color) {
                          return GestureDetector(
                            onTap: () => controller.updateStickerColor(
                              selectedId,
                              color,
                            ),
                            child: Container(
                              width: 28.w,
                              height: 28.w,
                              margin: EdgeInsets.only(right: 8.w),
                              decoration: BoxDecoration(
                                color: color,
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text('Rotation:', style: TextStyle(fontSize: 12.sp)),
                        Expanded(
                          child: Slider(
                            value: element['rotation'] as double,
                            min: -3.14159,
                            max: 3.14159,
                            onChanged: (value) {
                              controller.updateStickerRotation(
                                selectedId,
                                value,
                              );
                            },
                          ),
                        ),
                        Text(
                          '${((element['rotation'] as double) * 57.2958).toStringAsFixed(0)}°',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ],
                );
              }
            }
            return Text(
              'Select a sticker to edit',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            );
          }),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildTextEditPanel() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit Text',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Obx(() {
                    final selectedId = controller.selectedTextId.value;
                    return IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: selectedId != null
                          ? () {
                              controller.deleteTextElement(selectedId);
                              controller.closeEditPanel();
                            }
                          : null,
                    );
                  }),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: controller.closeEditPanel,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final selectedId = controller.selectedTextId.value;
            if (selectedId != null) {
              final element = controller.elements.firstWhereOrNull(
                (e) => e['id'] == selectedId,
              );
              if (element != null) {
                final content = element['content'] as String;
                final fontSize = element['fontSize'] as double;
                final colorHex = (element['color'] as String).replaceFirst(
                  '#',
                  '',
                );
                final color = Color(int.parse('0x$colorHex'));
                final isBold = element['isBold'] as bool;
                final isItalic = element['isItalic'] as bool;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: TextEditingController(text: content)
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: content.length),
                        ),
                      decoration: InputDecoration(
                        labelText: 'Text Content',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                      ),
                      onChanged: (value) {
                        controller.updateTextContent(selectedId, value);
                      },
                      maxLines: 3,
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Text('Size:', style: TextStyle(fontSize: 12.sp)),
                        Expanded(
                          child: Slider(
                            value: fontSize,
                            min: 12,
                            max: 48,
                            onChanged: (value) {
                              controller.updateTextStyle(
                                selectedId,
                                fontSize: value,
                              );
                            },
                          ),
                        ),
                        Text(
                          '${fontSize.toInt()}',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Color:', style: TextStyle(fontSize: 12.sp)),
                        SizedBox(height: 8.h),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(8, (index) {
                              final colors = [
                                Colors.white,
                                Colors.black,
                                Colors.red,
                                Colors.blue,
                                Colors.green,
                                Colors.yellow,
                                Colors.purple,
                                Colors.orange,
                              ];
                              final itemColor = colors[index];
                              return GestureDetector(
                                onTap: () {
                                  controller.updateTextStyle(
                                    selectedId,
                                    color:
                                        '#${itemColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
                                  );
                                },
                                child: Container(
                                  width: 30.w,
                                  height: 30.w,
                                  margin: EdgeInsets.only(right: 8.w),
                                  decoration: BoxDecoration(
                                    color: itemColor,
                                    border: Border.all(
                                      color: color == itemColor
                                          ? BlushNoteColors.accent
                                          : Colors.grey,
                                      width: color == itemColor ? 3 : 1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text('Style:', style: TextStyle(fontSize: 12.sp)),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              controller.updateTextStyle(
                                selectedId,
                                isBold: !isBold,
                              );
                            },
                            icon: const Icon(Icons.format_bold),
                            label: const Text('Bold'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isBold
                                  ? BlushNoteColors.accent
                                  : Colors.grey.shade300,
                              foregroundColor: isBold
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              controller.updateTextStyle(
                                selectedId,
                                isItalic: !isItalic,
                              );
                            },
                            icon: const Icon(Icons.format_italic),
                            label: const Text('Italic'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isItalic
                                  ? BlushNoteColors.accent
                                  : Colors.grey.shade300,
                              foregroundColor: isItalic
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            }
            return const SizedBox.shrink();
          }),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildStickerEditPanel() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit Sticker',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Obx(() {
                    final selectedId = controller.selectedStickerId.value;
                    return IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: selectedId != null
                          ? () {
                              controller.deleteStickerElement(selectedId);
                              controller.closeEditPanel();
                            }
                          : null,
                    );
                  }),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: controller.closeEditPanel,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final selectedId = controller.selectedStickerId.value;
            if (selectedId != null) {
              final element = controller.elements.firstWhereOrNull(
                (e) => e['id'] == selectedId,
              );
              if (element != null) {
                final size = element['size'] as double;
                final scale = element['scale'] as double;
                final rotation = element['rotation'] as double;
                final colorHex = (element['color'] as String).replaceFirst(
                  '#',
                  '',
                );
                final color = Color(int.parse('0x$colorHex'));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Size:', style: TextStyle(fontSize: 12.sp)),
                        Expanded(
                          child: Slider(
                            value: size,
                            min: 20,
                            max: 120,
                            onChanged: (value) {
                              controller.updateStickerSize(selectedId, value);
                            },
                          ),
                        ),
                        Text(
                          '${size.toInt()}',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text('Scale:', style: TextStyle(fontSize: 12.sp)),
                        Expanded(
                          child: Slider(
                            value: scale,
                            min: 0.5,
                            max: 3.0,
                            onChanged: (value) {
                              controller.updateStickerScale(selectedId, value);
                            },
                          ),
                        ),
                        Text(
                          '${scale.toStringAsFixed(1)}x',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text('Rotation:', style: TextStyle(fontSize: 12.sp)),
                        Expanded(
                          child: Slider(
                            value: rotation,
                            min: -3.14159,
                            max: 3.14159,
                            onChanged: (value) {
                              controller.updateStickerRotation(
                                selectedId,
                                value,
                              );
                            },
                          ),
                        ),
                        Text(
                          '${((rotation) * 57.2958).toStringAsFixed(0)}°',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Color:', style: TextStyle(fontSize: 12.sp)),
                        SizedBox(height: 8.h),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(8, (index) {
                              final colors = [
                                Colors.red,
                                Colors.blue,
                                Colors.green,
                                Colors.yellow,
                                Colors.purple,
                                Colors.orange,
                                Colors.pink,
                                Colors.black,
                              ];
                              final itemColor = colors[index];
                              return GestureDetector(
                                onTap: () {
                                  controller.updateStickerColor(
                                    selectedId,
                                    itemColor,
                                  );
                                },
                                child: Container(
                                  width: 30.w,
                                  height: 30.w,
                                  margin: EdgeInsets.only(right: 8.w),
                                  decoration: BoxDecoration(
                                    color: itemColor,
                                    border: Border.all(
                                      color: color == itemColor
                                          ? BlushNoteColors.accent
                                          : Colors.grey,
                                      width: color == itemColor ? 3 : 1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            }
            return const SizedBox.shrink();
          }),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildImageEditPanel() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit Image',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Obx(() {
                    final selectedId = controller.selectedImageId.value;
                    return IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: selectedId != null
                          ? () {
                              controller.deleteImageElement(selectedId);
                              controller.closeEditPanel();
                            }
                          : null,
                    );
                  }),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: controller.closeEditPanel,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final selectedId = controller.selectedImageId.value;
            if (selectedId != null) {
              final element = controller.elements.firstWhereOrNull(
                (e) => e['id'] == selectedId,
              );
              if (element != null) {
                final scale = element['scale'] as double;
                final rotation = element['rotation'] as double;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Scale:', style: TextStyle(fontSize: 12.sp)),
                        Expanded(
                          child: Slider(
                            value: scale,
                            min: 0.5,
                            max: 3.0,
                            onChanged: (value) {
                              controller.updateImageScale(selectedId, value);
                            },
                          ),
                        ),
                        Text(
                          '${scale.toStringAsFixed(1)}x',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text('Rotation:', style: TextStyle(fontSize: 12.sp)),
                        Expanded(
                          child: Slider(
                            value: rotation,
                            min: -3.14159,
                            max: 3.14159,
                            onChanged: (value) {
                              controller.updateImageRotation(selectedId, value);
                            },
                          ),
                        ),
                        Text(
                          '${((rotation) * 57.2958).toStringAsFixed(0)}°',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ],
                );
              }
            }
            return const SizedBox.shrink();
          }),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  _DrawingPainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD1DC).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    const dotSpacing = 20.0;
    const dotRadius = 1.5;

    for (double x = 0; x < size.width; x += dotSpacing) {
      for (double y = 0; y < size.height; y += dotSpacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
