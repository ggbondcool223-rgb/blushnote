import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:blush_note/utils/colors.dart';
import 'blush_note_diary_notebook_add_logic.dart';

class BlushNoteDiaryNotebookAddView
    extends GetView<BlushNoteDiaryNotebookAddLogic> {
  const BlushNoteDiaryNotebookAddView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlushNoteColors.bgMain,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          color: Colors.grey.shade400,
          iconSize: 28.w,
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Add Notebook',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: BlushNoteColors.textMain,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => controller.save(),
            child: Text(
              'Confirm',
              style: TextStyle(
                fontSize: 16.sp,
                color: BlushNoteColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Cover',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: BlushNoteColors.textMain,
              ),
            ),
            SizedBox(height: 16.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                return _buildCoverOption(index);
              },
            ),
            SizedBox(height: 32.h),
            Text(
              'Notebook Name',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: BlushNoteColors.textMain,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          TextEditingController(
                              text: controller.notebookName.value,
                            )
                            ..selection = TextSelection.fromPosition(
                              TextPosition(
                                offset: controller.notebookName.value.length,
                              ),
                            ),
                      onChanged: (value) =>
                          controller.notebookName.value = value,
                      decoration: InputDecoration(
                        hintText: 'Enter name',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade200,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: BlushNoteColors.textMain,
                      ),
                      maxLength: 20,
                      buildCounter:
                          (
                            context, {
                            required currentLength,
                            required isFocused,
                            maxLength,
                          }) => null,
                    ),
                  ),
                  Obx(
                    () => Text(
                      '(${controller.notebookName.value.length}/20)',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: BlushNoteColors.textSub,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverOption(int index) {
    final coverIcons = [
      Icons.book,
      Icons.restaurant,
      Icons.mood,
      Icons.flight,
      Icons.work,
      Icons.school,
      Icons.favorite,
      Icons.pets,
      Icons.music_note,
      Icons.sports_soccer,
      Icons.shopping_bag,
      Icons.camera_alt,
    ];

    final coverKeys = [
      'book',
      'food',
      'mood',
      'travel',
      'work',
      'study',
      'love',
      'pet',
      'music',
      'sport',
      'shopping',
      'camera',
    ];

    final colors = [
      Colors.pink.shade200,
      Colors.orange.shade200,
      Colors.blue.shade200,
      Colors.purple.shade200,
      Colors.green.shade200,
      Colors.amber.shade200,
    ];

    return Obx(() {
      final isSelected = controller.selectedCover.value == coverKeys[index];
      return GestureDetector(
        onTap: () => controller.selectCover(coverKeys[index]),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors[index % 6],
                colors[index % 6].withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(8.r),
            border: isSelected
                ? Border.all(color: BlushNoteColors.accent, width: 3)
                : null,
            boxShadow: [
              BoxShadow(
                color: colors[index % 6].withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(coverIcons[index], color: Colors.white, size: 32.w),
              if (isSelected)
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 16.w,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
