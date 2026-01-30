import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:blush_note/utils/colors.dart';
import 'blush_note_diary_edit_logic.dart';

class BlushNoteDiaryEditView extends GetView<BlushNoteDiaryEditLogic> {
  const BlushNoteDiaryEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlushNoteColors.bgMain,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Obx(() {
          final currentNotebook = controller.notebooks.firstWhereOrNull(
            (n) => n.id == controller.notebookId.value,
          );
          return GestureDetector(
            onTap: () => _showNotebookSelector(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getNotebookIcon(currentNotebook?.cover),
                  size: 20.w,
                  color: BlushNoteColors.accent,
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    currentNotebook?.name ?? 'Select Notebook',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: BlushNoteColors.textMain,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 18.w,
                  color: BlushNoteColors.accent,
                ),
              ],
            ),
          );
        }),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: GestureDetector(
              onTap: () => controller.selectDate(),
              child: Obx(() {
                final date = DateTime.parse(controller.date.value);
                return Row(
                  children: [
                    Text(
                      DateFormat('dd').format(date),
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: BlushNoteColors.accent,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE').format(date),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: BlushNoteColors.textMain,
                          ),
                        ),
                        Text(
                          DateFormat('MMM yyyy').format(date),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: BlushNoteColors.textSub,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(height: 1.h, color: Colors.grey.shade200),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildDiaryPaper()),
          _buildMediaSection(),
          _buildWordCount(),
          _buildToolBar(),
        ],
      ),
    );
  }

  Widget _buildDiaryPaper() {
    return Obx(() {
      final bgColor = _parsePaperBackground(controller.paperBackground.value);

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: BlushNoteColors.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: TextEditingController(text: controller.title.value)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.title.value.length),
                ),
              onChanged: (value) {
                controller.title.value = value;
                controller.updateWordCount();
              },
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade200,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: BlushNoteColors.textMain,
              ),
            ),
            SizedBox(height: 8.h),
            _buildWeatherSection(),
            Divider(color: Colors.grey.shade200),
            SizedBox(height: 16.h),
            Expanded(
              child: SingleChildScrollView(
                child: TextField(
                  controller:
                      TextEditingController(text: controller.content.value)
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: controller.content.value.length),
                        ),
                  onChanged: (value) {
                    controller.content.value = value;
                    controller.updateWordCount();
                  },
                  decoration: InputDecoration(
                    hintText: 'Write your story...',
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade200,
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: BlushNoteColors.textMain,
                    height: 2.0,
                  ),
                  maxLines: null,
                  minLines: 10,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Color _parsePaperBackground(String? background) {
    if (background == null || background.isEmpty) return Colors.white;
    try {
      return Color(int.parse('0x$background'));
    } catch (e) {
      return Colors.white;
    }
  }

  Widget _buildWeatherSection() {
    return Obx(() {
      final weather = controller.weather.value;
      final weatherInfo = _getWeatherInfo(weather);

      return GestureDetector(
        onTap: () => controller.selectWeather(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: weatherInfo['color'].withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: weatherInfo['color'].withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                weatherInfo['icon'],
                size: 16.w,
                color: weatherInfo['color'],
              ),
              SizedBox(width: 6.w),
              Text(
                weatherInfo['name'],
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: weatherInfo['color'],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Map<String, dynamic> _getWeatherInfo(String weather) {
    switch (weather) {
      case 'sunny':
        return {
          'name': 'Sunny',
          'icon': Icons.wb_sunny,
          'color': const Color(0xFFFFA726),
        };
      case 'cloudy':
        return {
          'name': 'Cloudy',
          'icon': Icons.cloud,
          'color': const Color(0xFF90A4AE),
        };
      case 'rainy':
        return {
          'name': 'Rainy',
          'icon': Icons.umbrella,
          'color': const Color(0xFF42A5F5),
        };
      case 'snowy':
        return {
          'name': 'Snowy',
          'icon': Icons.ac_unit,
          'color': const Color(0xFF64B5F6),
        };
      default:
        return {
          'name': 'Sunny',
          'icon': Icons.wb_sunny,
          'color': const Color(0xFFFFA726),
        };
    }
  }

  Widget _buildMediaSection() {
    return Obx(() {
      final hasImages = controller.selectedImages.isNotEmpty;
      final hasAudio = controller.audioPath.value != null;
      final hasVideo = controller.videoPath.value != null;

      if (!hasImages && !hasAudio && !hasVideo) {
        return const SizedBox.shrink();
      }

      return Container(
        constraints: BoxConstraints(maxHeight: 200.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImages) ...[
                _buildImagesSection(),
                if (hasAudio || hasVideo) SizedBox(height: 12.h),
              ],
              if (hasAudio) ...[
                _buildAudioSection(),
                if (hasVideo) SizedBox(height: 12.h),
              ],
              if (hasVideo) _buildVideoSection(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildImagesSection() {
    return Obx(() {
      return SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: controller.selectedImages.asMap().entries.map((entry) {
            final index = entry.key;
            final imagePath = entry.value;
            return _buildImageItem(imagePath, index);
          }).toList(),
        ),
      );
    });
  }

  Widget _buildImageItem(String imagePath, int index) {
    return Stack(
      children: [
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7.r),
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
        ),
        Positioned(
          top: 4.h,
          right: 4.w,
          child: GestureDetector(
            onTap: () => controller.removeImage(index),
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 16.w, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioSection() {
    return Obx(() {
      final audioPath = controller.audioPath.value;
      if (audioPath == null) return const SizedBox.shrink();

      final isPlaying = controller.isPlaying.value;
      final duration = controller.audioDuration.value;
      final position = controller.audioPosition.value;

      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: BlushNoteColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: BlushNoteColors.accent.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.audiotrack,
                  color: BlushNoteColors.accent,
                  size: 24.w,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audio Recording',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: BlushNoteColors.textMain,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _formatDuration(position) +
                            ' / ' +
                            _formatDuration(duration),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: BlushNoteColors.textSub,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: BlushNoteColors.accent,
                    size: 32.w,
                  ),
                  onPressed: () => controller.toggleAudioPlayback(),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red.shade400,
                    size: 20.w,
                  ),
                  onPressed: () => controller.removeAudio(),
                ),
              ],
            ),
            if (duration.inMilliseconds > 0) ...[
              SizedBox(height: 8.h),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 2.h,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.w),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 12.w),
                ),
                child: Slider(
                  value: position.inMilliseconds.toDouble(),
                  max: duration.inMilliseconds.toDouble(),
                  activeColor: BlushNoteColors.accent,
                  inactiveColor: BlushNoteColors.accent.withValues(alpha: 0.3),
                  onChanged: (value) {
                    controller.seekAudio(Duration(milliseconds: value.toInt()));
                  },
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildVideoSection() {
    return Obx(() {
      final videoPath = controller.videoPath.value;
      if (videoPath == null) return const SizedBox.shrink();

      return Container(
        height: 180.h,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Stack(
          children: [
            Center(child: _VideoPreview(videoPath: videoPath)),
            Positioned(
              top: 8.h,
              right: 8.w,
              child: GestureDetector(
                onTap: () => controller.removeVideo(),
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 20.w, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildWordCount() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w).copyWith(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Obx(
            () => Text(
              '${controller.wordCount.value} words',
              style: TextStyle(fontSize: 10.sp, color: BlushNoteColors.textSub),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolBar() {
    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFF0F0F0), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildToolButton(
              Icons.camera_alt,
              BlushNoteColors.accent,
              () => controller.pickImages(),
            ),
            Obx(() {
              final isRecording = controller.isRecording.value;
              return _buildToolButton(
                isRecording ? Icons.stop : Icons.mic,
                isRecording ? Colors.red : BlushNoteColors.accent,
                () => controller.toggleRecording(),
              );
            }),
            _buildToolButton(
              Icons.videocam,
              BlushNoteColors.accent,
              () => controller.pickVideo(),
            ),
            _buildToolButton(
              Icons.water_drop,
              BlushNoteColors.accent,
              () => controller.selectWeather(),
            ),
            _buildToolButton(
              Icons.check_circle,
              BlushNoteColors.accent,
              () => controller.save(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: color),
      iconSize: 24.w,
      onPressed: onPressed,
    );
  }

  void _showNotebookSelector() {
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
        child: Obx(() {
          if (controller.notebooks.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(20.w),
              child: const Center(
                child: Text('No notebooks available. Please create one first.'),
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Notebook',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: BlushNoteColors.textMain,
                ),
              ),
              SizedBox(height: 16.h),
              ...controller.notebooks.map((notebook) {
                return ListTile(
                  leading: Icon(
                    _getNotebookIcon(notebook.cover),
                    color: BlushNoteColors.accent,
                  ),
                  title: Text(notebook.name),
                  trailing: controller.notebookId.value == notebook.id
                      ? Icon(Icons.check, color: BlushNoteColors.accent)
                      : null,
                  onTap: () {
                    controller.selectNotebook(notebook.id!);
                    Get.back();
                  },
                );
              }),
            ],
          );
        }),
      ),
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
}

class _VideoPreview extends StatefulWidget {
  final String videoPath;

  const _VideoPreview({required this.videoPath});

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.file(File(widget.videoPath));
    try {
      await _controller.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Center(
        child: CircularProgressIndicator(color: BlushNoteColors.accent),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (!_controller.value.isPlaying)
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow, color: Colors.white, size: 40.w),
            ),
        ],
      ),
    );
  }
}
