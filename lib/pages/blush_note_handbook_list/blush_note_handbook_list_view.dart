import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:blush_note/utils/colors.dart';
import 'package:blush_note/db_blush_note/index.dart';
import 'blush_note_handbook_list_logic.dart';

class BlushNoteHandbookListView extends GetView<BlushNoteHandbookListLogic> {
  const BlushNoteHandbookListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlushNoteColors.bgMain,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Handbook',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: BlushNoteColors.textMain,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        if (controller.handbookList.isEmpty) {
          return _buildEmptyState();
        }

        return GridView.builder(
          padding: EdgeInsets.all(20.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
          ),
          itemCount: controller.handbookList.length,
          itemBuilder: (context, index) {
            final handbook = controller.handbookList[index];
            return _buildHandbookCard(handbook);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'handbook_list_fab',
        onPressed: controller.onAddTap,
        backgroundColor: BlushNoteColors.accent,
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHandbookCard(Handbook handbook) {
    Color bgColor = Colors.white;
    try {
      final bgColorHex = handbook.backgroundImage ?? 'FFFFFFFF';
      bgColor = Color(int.parse('0x$bgColorHex'));
    } catch (e) {
      print('Error parsing background color: $e');
    }

    return GestureDetector(
      onTap: () => controller.onItemTap(handbook.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: BlushNoteColors.primary.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
                child:
                    handbook.imagePath != null && handbook.imagePath!.isNotEmpty
                    ? Image.file(
                        File(handbook.imagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: bgColor,
                            width: double.infinity,
                            child: Center(
                              child: Icon(
                                Icons.auto_stories_outlined,
                                size: 48.w,
                                color: Colors.grey.shade300.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: bgColor,
                        width: double.infinity,
                        child: Center(
                          child: Icon(
                            Icons.auto_stories_outlined,
                            size: 48.w,
                            color: Colors.grey.shade300.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          handbook.title.isEmpty ? 'Untitled' : handbook.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: BlushNoteColors.textMain,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          handbook.createdAt.split('T')[0],
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: BlushNoteColors.textSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => controller.onSaveToGallery(handbook.id!),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.download,
                        size: 18.sp,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => controller.onDeleteTap(handbook.id!),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Icons.delete, size: 18.sp, color: Colors.red),
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

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories, size: 80.w, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(
            'No Handbooks Yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: BlushNoteColors.textSub,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap + to create your first handbook',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
