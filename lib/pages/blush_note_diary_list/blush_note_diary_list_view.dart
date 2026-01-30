import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:blush_note/utils/colors.dart';
import 'package:blush_note/db_blush_note/db_blush_note_entity.dart';
import 'blush_note_diary_list_logic.dart';

class BlushNoteDiaryListView extends GetView<BlushNoteDiaryListLogic> {
  const BlushNoteDiaryListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlushNoteColors.bgMain,
      appBar: AppBar(
        title: Obx(() {
          Notebook? currentNotebook;
          try {
            currentNotebook = controller.notebooks.firstWhere(
              (n) => n.id == controller.currentNotebookId.value,
            );
          } catch (e) {
            currentNotebook = null;
          }
          return GestureDetector(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentNotebook?.name ?? 'All Diaries',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: BlushNoteColors.textMain,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
      body: Column(
        children: [
          _buildNotebookSelector(),
          _buildDiaryStats(),
          Expanded(child: _buildDiaryList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'diary_list_fab',
        onPressed: () => controller.editDiary(),
        backgroundColor: BlushNoteColors.accent,
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNotebookSelector() {
    return Container(
      height: 100.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: EdgeInsets.only(top: 16.h),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          itemCount: controller.notebooks.length + 2,
          separatorBuilder: (context, index) => SizedBox(width: 16.w),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildNotebookItem(null, 'All', Icons.menu_book);
            } else if (index == controller.notebooks.length + 1) {
              return _buildAddNotebookItem();
            } else {
              final notebook = controller.notebooks[index - 1];
              return _buildNotebookItem(
                notebook.id,
                notebook.name,
                _getNotebookIcon(notebook.cover),
              );
            }
          },
        );
      }),
    );
  }

  IconData _getNotebookIcon(String? cover) {
    switch (cover) {
      case 'food':
        return Icons.restaurant;
      case 'mood':
        return Icons.mood;
      case 'travel':
        return Icons.flight;
      case 'work':
        return Icons.work;
      case 'study':
        return Icons.school;
      default:
        return Icons.book;
    }
  }

  Widget _buildNotebookItem(int? notebookId, String name, IconData icon) {
    final notebookColors = [
      Colors.pink.shade200,
      Colors.orange.shade200,
      Colors.blue.shade200,
      Colors.purple.shade200,
      Colors.green.shade200,
      Colors.amber.shade200,
    ];

    final colorIndex = notebookId == null ? 0 : (notebookId % 6);
    final baseColor = notebookId == null
        ? BlushNoteColors.primary
        : notebookColors[colorIndex];

    return GestureDetector(
      onTap: () => controller.switchNotebook(notebookId),
      child: Obx(() {
        final selected = controller.currentNotebookId.value == notebookId;

        return Column(
          children: [
            Container(
              width: 52.w,
              height: 60.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    baseColor.withValues(alpha: 0.8),
                    baseColor.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: selected
                    ? Border.all(color: BlushNoteColors.accent, width: 3)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: baseColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 28.w, color: Colors.white),
                  if (selected)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 14.w,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              name,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected
                    ? BlushNoteColors.textMain
                    : BlushNoteColors.textSub,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAddNotebookItem() {
    return GestureDetector(
      onTap: () async {
        await Get.toNamed('/diary/notebook/add');
        controller.refreshData();
      },
      child: Column(
        children: [
          Container(
            width: 52.w,
            height: 60.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  BlushNoteColors.primary.withValues(alpha: 0.2),
                  BlushNoteColors.primary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: BlushNoteColors.primary,
                width: 2,
                style: BorderStyle.solid,
              ),
              boxShadow: [
                BoxShadow(
                  color: BlushNoteColors.primary.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.add, size: 28.w, color: BlushNoteColors.primary),
          ),
          SizedBox(height: 6.h),
          Text(
            'New',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: BlushNoteColors.textSub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryStats() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      color: Colors.white,
      child: Obx(() {
        final diaryCount = controller.getDiaryCount();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$diaryCount Diaries',
              style: TextStyle(fontSize: 12.sp, color: BlushNoteColors.textSub),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDiaryList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.diaries.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_stories_outlined,
                size: 80.sp,
                color: Colors.grey.shade300,
              ),
              SizedBox(height: 16.h),
              Text(
                'No diaries yet',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade400),
              ),
              SizedBox(height: 8.h),
              Text(
                'Tap + to create your first diary',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
        itemCount: controller.diaries.length,
        itemBuilder: (context, index) {
          return _buildDiaryTimelineItem(controller.diaries[index]);
        },
      );
    });
  }

  Widget _buildDiaryTimelineItem(diary) {
    final date = diary.date;
    final title = diary.title.isEmpty ? 'Untitled Diary' : diary.title;
    final content = diary.content;
    final weather = diary.weather;

    List<String> imagePaths = [];
    try {
      if (diary.images != null && diary.images.isNotEmpty) {
        final imageList = jsonDecode(diary.images) as List;
        imagePaths = imageList.cast<String>().take(2).toList();
      }
    } catch (e) {
      print('Error parsing images: $e');
    }

    final hasAudio = diary.audioPath != null && diary.audioPath.isNotEmpty;
    final hasVideo = diary.videoPath != null && diary.videoPath.isNotEmpty;

    return GestureDetector(
      onTap: () => controller.editDiary(diaryId: diary.id),
      onLongPress: () => _showDiaryOptions(diary),
      child: Container(
        margin: EdgeInsets.only(left: 20.w, bottom: 30.h),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: BlushNoteColors.primary,
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: -6.w,
              top: 6.h,
              child: Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: BlushNoteColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: BlushNoteColors.textSub,
                        ),
                      ),
                      if (weather != null && weather.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Text(
                          _getWeatherEmoji(weather),
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                      const Spacer(),
                      _buildMediaIndicators(
                        hasImages: imagePaths.isNotEmpty,
                        hasAudio: hasAudio,
                        hasVideo: hasVideo,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: BlushNoteColors.primary.withValues(
                            alpha: 0.08,
                          ),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: BlushNoteColors.textMain,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (content.isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          Text(
                            content,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: BlushNoteColors.textSub,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (imagePaths.isNotEmpty) ...[
                          SizedBox(height: 12.h),
                          _buildImageThumbnails(imagePaths),
                        ],
                      ],
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

  String _getWeatherEmoji(String weather) {
    switch (weather.toLowerCase()) {
      case 'sunny':
        return '☀️';
      case 'cloudy':
        return '☁️';
      case 'rainy':
        return '🌧️';
      case 'snowy':
        return '❄️';
      case 'windy':
        return '💨';
      default:
        return '🌤️';
    }
  }

  Widget _buildMediaIndicators({
    required bool hasImages,
    required bool hasAudio,
    required bool hasVideo,
  }) {
    if (!hasImages && !hasAudio && !hasVideo) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasImages) ...[
          Icon(
            Icons.image,
            size: 14.w,
            color: BlushNoteColors.accent.withValues(alpha: 0.7),
          ),
          SizedBox(width: 6.w),
        ],
        if (hasAudio) ...[
          Icon(
            Icons.audiotrack,
            size: 14.w,
            color: BlushNoteColors.accent.withValues(alpha: 0.7),
          ),
          SizedBox(width: 6.w),
        ],
        if (hasVideo) ...[
          Icon(
            Icons.videocam,
            size: 14.w,
            color: BlushNoteColors.accent.withValues(alpha: 0.7),
          ),
        ],
      ],
    );
  }

  Widget _buildImageThumbnails(List<String> imagePaths) {
    return Row(
      children: imagePaths.map((imagePath) {
        return Container(
          width: 80.w,
          height: 80.w,
          margin: EdgeInsets.only(right: 8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.r),
            child: File(imagePath).existsSync()
                ? Image.file(File(imagePath), fit: BoxFit.cover)
                : Container(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 32.sp,
                    ),
                  ),
          ),
        );
      }).toList(),
    );
  }

  void _showDiaryOptions(diary) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: BlushNoteColors.accent),
              title: const Text('Edit'),
              onTap: () {
                Get.back();
                controller.editDiary(diaryId: diary.id);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red.shade400),
              title: Text(
                'Delete',
                style: TextStyle(color: Colors.red.shade400),
              ),
              onTap: () {
                Get.back();
                _confirmDelete(diary);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(diary) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Diary'),
        content: const Text('Are you sure you want to delete this diary?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteDiary(diary.id!);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }
}
