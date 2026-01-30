import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:blush_note/db_blush_note/index.dart';
import 'package:blush_note/utils/index.dart';

class BlushNoteDiaryEditLogic extends GetxController {
  int? diaryId;
  
  final notebooks = <Notebook>[].obs;
  final notebookId = Rxn<int>();
  
  final title = ''.obs;
  final content = ''.obs;
  final date = ''.obs;
  final weather = 'sunny'.obs;
  final selectedImages = <String>[].obs;
  final audioPath = Rxn<String>();
  final videoPath = Rxn<String>();
  final paperBackground = Rxn<String>();
  final wordCount = 0.obs;
  
  late TextEditingController titleController;
  late TextEditingController contentController;
  
  final _picker = ImagePicker();
  
  final _audioRecorder = AudioRecorder();
  final isRecording = false.obs;
  final recordingDuration = 0.obs;
  Timer? _recordingTimer;
  
  final _audioPlayer = AudioPlayer();
  final isPlaying = false.obs;
  final audioDuration = Duration.zero.obs;
  final audioPosition = Duration.zero.obs;
  
  Timer? _autoSaveTimer;
  
  final isLoading = false.obs;
  final isSaving = false.obs;
  
  final weatherOptions = const [
    {'name': 'Sunny', 'value': 'sunny', 'icon': Icons.wb_sunny},
    {'name': 'Cloudy', 'value': 'cloudy', 'icon': Icons.cloud},
    {'name': 'Rainy', 'value': 'rainy', 'icon': Icons.umbrella},
    {'name': 'Snowy', 'value': 'snowy', 'icon': Icons.ac_unit},
  ];

  @override
  void onInit() {
    super.onInit();
    
    titleController = TextEditingController();
    contentController = TextEditingController();
    
    titleController.addListener(() {
      title.value = titleController.text;
      updateWordCount();
      _scheduleAutoSave();
    });
    contentController.addListener(() {
      content.value = contentController.text;
      updateWordCount();
      _scheduleAutoSave();
    });
    
    _audioPlayer.onDurationChanged.listen((duration) {
      audioDuration.value = duration;
      print('Audio duration loaded: ${duration.inSeconds}s');
    });
    _audioPlayer.onPositionChanged.listen((position) {
      audioPosition.value = position;
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      isPlaying.value = false;
      audioPosition.value = Duration.zero;
      print('Audio playback completed');
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      print('Audio player state: $state');
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        isPlaying.value = false;
      }
    });
    
    final args = Get.arguments as Map<String, dynamic>?;
    diaryId = args?['diaryId'];
    notebookId.value = args?['notebookId'];
    
    date.value = getDateString(DateTime.now());
    
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      
      await loadNotebooks();
      
      if (diaryId != null) {
        await loadDiary(diaryId!);
      }
    } catch (e) {
      errorToast('Failed to load data');
      print('Error loading diary data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadNotebooks() async {
    try {
      final result = await db.getNotebooks();
      notebooks.value = result;
    } catch (e) {
      print('Error loading notebooks: $e');
      rethrow;
    }
  }

  Future<void> loadDiary(int id) async {
    try {
      final diary = await db.getDiaryById(id);
      if (diary == null) {
        errorToast('Diary not found');
        Get.back();
        return;
      }
      
      titleController.text = diary.title;
      contentController.text = diary.content;
      date.value = diary.date;
      weather.value = diary.weather ?? 'sunny';
      notebookId.value = diary.notebookId;
      paperBackground.value = diary.paperBackground;
      audioPath.value = diary.audioPath;
      videoPath.value = diary.videoPath;
      
      if (diary.audioPath != null && diary.audioPath!.isNotEmpty) {
        await _loadAudioFile(diary.audioPath!);
      }
      
      try {
        if (diary.imagesJson.isNotEmpty) {
          final imagesList = jsonDecode(diary.imagesJson) as List;
          selectedImages.value = imagesList.map((e) => e.toString()).toList();
        }
      } catch (e) {
        print('Error parsing images: $e');
      }
      
      updateWordCount();
    } catch (e) {
      print('Error loading diary: $e');
      rethrow;
    }
  }

  void selectNotebook(int id) {
    notebookId.value = id;
  }

  Future<void> selectDate() async {
    final selected = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.parse(date.value),
      firstDate: DateTime(2020, 1),
      lastDate: DateTime(2030, 12),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6B9D),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (selected != null) {
      date.value = getDateString(selected);
      _scheduleAutoSave();
    }
  }

  Future<void> selectWeather() async {
    final selected = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Select Weather'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: weatherOptions.length,
            itemBuilder: (context, index) {
              final option = weatherOptions[index];
              final isSelected = weather.value == option['value'];
              
              return ListTile(
                leading: Icon(option['icon'] as IconData),
                title: Text(option['name'] as String),
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () => Get.back(result: option['value']),
              );
            },
          ),
        ),
      ),
    );
    
    if (selected != null) {
      weather.value = selected;
      _scheduleAutoSave();
    }
  }

  Future<void> pickImages() async {
    try {
      final images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        for (var image in images) {
          if (selectedImages.length < 9) {
            selectedImages.add(image.path);
          }
        }
        if (images.length + selectedImages.length > 9) {
          errorToast('Maximum 9 images allowed');
        }
        _scheduleAutoSave();
      }
    } catch (e) {
      errorToast('Failed to pick images');
      print('Error picking images: $e');
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
      _scheduleAutoSave();
    }
  }

  Future<void> pickVideo() async {
    try {
      final video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        videoPath.value = video.path;
        successToast('Video selected');
        _scheduleAutoSave();
      }
    } catch (e) {
      errorToast('Failed to pick video');
      print('Error picking video: $e');
    }
  }

  void removeVideo() {
    videoPath.value = null;
    _scheduleAutoSave();
  }

  Future<void> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path = '${dir.path}/audio_$timestamp.m4a';
        
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );
        
        isRecording.value = true;
        recordingDuration.value = 0;
        
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          recordingDuration.value++;
        });
        
        successToast('Recording started');
      } else {
        errorToast('Microphone permission denied');
      }
    } catch (e) {
      errorToast('Failed to start recording');
      print('Error starting recording: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      
      _recordingTimer?.cancel();
      isRecording.value = false;
      
      if (path != null) {
        audioPath.value = path;
        successToast('Recording saved (${recordingDuration.value}s)');
        await _loadAudioFile(path);
        _scheduleAutoSave();
      }
      
      recordingDuration.value = 0;
    } catch (e) {
      errorToast('Failed to stop recording');
      print('Error stopping recording: $e');
    }
  }

  Future<void> _loadAudioFile(String path) async {
    try {
      await _audioPlayer.setSourceDeviceFile(path);
    } catch (e) {
      print('Error loading audio file: $e');
    }
  }

  void removeAudio() {
    _audioPlayer.stop();
    audioPath.value = null;
    isPlaying.value = false;
    _scheduleAutoSave();
  }

  Future<void> toggleAudioPlayback() async {
    if (audioPath.value == null) return;
    
    try {
      if (isPlaying.value) {
        await _audioPlayer.pause();
        isPlaying.value = false;
      } else {
        if (_audioPlayer.state == PlayerState.stopped || 
            _audioPlayer.state == PlayerState.completed) {
          await _audioPlayer.setSourceDeviceFile(audioPath.value!);
        }
        await _audioPlayer.resume();
        isPlaying.value = true;
      }
    } catch (e) {
      errorToast('Failed to play audio');
      print('Error playing audio: $e');
    }
  }

  Future<void> stopAudioPlayback() async {
    try {
      await _audioPlayer.stop();
      isPlaying.value = false;
      audioPosition.value = Duration.zero;
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  Future<void> seekAudio(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking audio: $e');
    }
  }

  Future<void> toggleRecording() async {
    if (isRecording.value) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }

  void selectPaperBackground(String? background) {
    paperBackground.value = background;
    _scheduleAutoSave();
  }

  void updateWordCount() {
    wordCount.value = title.value.length + content.value.length;
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      autoSave();
    });
  }

  Future<void> autoSave() async {
    if (title.value.isEmpty && content.value.isEmpty) return;
    
    try {
      await _saveDiary(showToast: false);
    } catch (e) {
      print('Auto-save failed: $e');
    }
  }

  Future<void> save() async {
    await _saveDiary(showToast: true);
  }

  Future<void> _saveDiary({required bool showToast}) async {
    if (notebookId.value == null) {
      if (showToast) errorToast('Please select a notebook');
      return;
    }
    
    try {
      isSaving.value = true;
      
      final now = DateTime.now().toIso8601String();
      final imagesJson = jsonEncode(selectedImages);
      
      if (diaryId == null) {
        final diary = Diary(
          notebookId: notebookId.value!,
          title: title.value,
          content: content.value,
          date: date.value,
          weather: weather.value,
          imagesJson: imagesJson,
          audioPath: audioPath.value,
          videoPath: videoPath.value,
          paperBackground: paperBackground.value,
          wordCount: wordCount.value,
          createdAt: now,
          updatedAt: now,
        );
        
        final id = await db.insertDiary(diary);
        diaryId = id;
        
        if (showToast) successToast('Diary saved');
      } else {
        final original = await db.getDiaryById(diaryId!);
        if (original == null) {
          if (showToast) errorToast('Diary not found');
          return;
        }
        
        final diary = Diary(
          id: diaryId,
          notebookId: notebookId.value!,
          title: title.value,
          content: content.value,
          date: date.value,
          weather: weather.value,
          imagesJson: imagesJson,
          audioPath: audioPath.value,
          videoPath: videoPath.value,
          paperBackground: paperBackground.value,
          wordCount: wordCount.value,
          createdAt: original.createdAt,
          updatedAt: now,
        );
        
        await db.updateDiary(diary);
        
        if (showToast) successToast('Diary updated');
      }
    } catch (e) {
      if (showToast) errorToast('Failed to save diary');
      print('Error saving diary: $e');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    _autoSaveTimer?.cancel();
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    titleController.dispose();
    contentController.dispose();
    
    if (title.value.isNotEmpty || content.value.isNotEmpty) {
      autoSave();
    }
    
    super.onClose();
  }
}
