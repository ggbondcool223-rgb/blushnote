import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:blush_note/db_blush_note/index.dart';
import 'package:blush_note/utils/index.dart';

class BlushNoteHandbookListLogic extends GetxController {
  final handbookList = <Handbook>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadHandbooks();
  }

  Future<void> loadHandbooks() async {
    try {
      isLoading.value = true;
      final list = await db.getHandbooks();
      handbookList.value = list;
    } catch (e) {
      errorToast('Failed to load handbooks: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onAddTap() async {
    await Get.toNamed('/handbook/edit');
    await refreshHandbooks();
  }

  Future<void> onItemTap(int? id) async {
    if (id == null) return;
    await Get.toNamed(
      '/handbook/edit',
      arguments: {'handbookId': id},
    );
    await refreshHandbooks();
  }
  
  Future<void> refreshHandbooks() async {
    await loadHandbooks();
  }

  Future<void> onDeleteTap(int id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Handbook'),
        content: const Text('Are you sure you want to delete this handbook?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await db.deleteHandbook(id);
      successToast('Handbook deleted');
      await loadHandbooks();
    } catch (e) {
      errorToast('Failed to delete: ${e.toString()}');
    }
  }

  void onRefresh() {
    loadHandbooks();
  }
  
  Future<void> onSaveToGallery(int id) async {
    try {
      print('🎯 开始保存手帐到相册，ID: $id');
      
      final hasPermission = await _requestStoragePermission();
      print('🔑 权限检查结果: $hasPermission');
      
      if (!hasPermission) {
        errorToast('Storage permission denied');
        print('❌ 权限被拒绝，保存终止');
        return;
      }

      print('✅ 权限已授予，开始读取图片');
      
      final handbook = await db.getHandbookById(id);
      
      if (handbook == null) {
        errorToast('Handbook not found');
        print('❌ 手帐记录不存在');
        return;
      }
      
      if (handbook.imagePath == null || handbook.imagePath!.isEmpty) {
        errorToast('Please edit and save the handbook first');
        print('❌ 图片路径为空，需要先编辑保存');
        return;
      }
      
      print('📂 图片路径: ${handbook.imagePath}');
      
      final imageFile = File(handbook.imagePath!);
      if (!await imageFile.exists()) {
        errorToast('Image file not found. Please edit and save again');
        print('❌ 图片文件不存在: ${handbook.imagePath}');
        return;
      }

      print('💾 开始保存到相册...');
      
      final result = await ImageGallerySaver.saveFile(
        handbook.imagePath!,
        name: 'handbook_${DateTime.now().millisecondsSinceEpoch}',
      );

      print('📊 保存结果: $result');

      if (result['isSuccess'] == true) {
        successToast('Saved to gallery');
        print('✅ 保存成功！');
      } else {
        errorToast('Failed to save to gallery');
        print('❌ 保存失败: $result');
      }
    } catch (e) {
      errorToast('Failed to save: ${e.toString()}');
      print('❌ 保存过程出错: $e');
    }
  }
  
  Future<bool> _requestStoragePermission() async {
    if (GetPlatform.isIOS) {
      final currentStatus = await Permission.photos.status;
      print('📱 iOS Current permission status: $currentStatus');
      
      if (currentStatus.isGranted) {
        return true;
      }
      
      if (currentStatus.isPermanentlyDenied || currentStatus.isRestricted) {
        errorToast('Photo access denied. Please enable it in Settings');
        return false;
      }
      
      final status = await Permission.photos.request();
      print('📱 iOS Permission request result: $status');
      
      if (status.isGranted) {
        return true;
      } else if (status.isDenied) {
        errorToast('Photo access is needed to save handbooks');
        return false;
      } else if (status.isPermanentlyDenied) {
        errorToast('Photo access denied. Please enable it in Settings');
        return false;
      }
      
      return false;
    }
    
    if (GetPlatform.isAndroid) {
      final androidInfo = await _getAndroidVersion();
      if (androidInfo >= 33) {
        return true;
      } else if (androidInfo >= 30) {
        final status = await Permission.photos.request();
        if (status.isGranted) return true;
        
        final storageStatus = await Permission.storage.request();
        return storageStatus.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    
    return false;
  }
  
  Future<int> _getAndroidVersion() async {
    try {
      if (await Permission.photos.isGranted || 
          await Permission.photos.isDenied ||
          await Permission.photos.isPermanentlyDenied) {
        return 33;
      }
      return 29;
    } catch (e) {
      return 29;
    }
  }
  
  Future<void> showHandbookMenu(int id) async {
    final result = await Get.bottomSheet<String>(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              ListTile(
                leading: const Icon(Icons.save_alt, color: Colors.blue),
                title: const Text('Save to Gallery'),
                onTap: () => Get.back(result: 'save'),
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () => Get.back(result: 'delete'),
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.grey),
                title: const Text('Cancel'),
                onTap: () => Get.back(),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isDismissible: true,
    );

    if (result == 'save') {
      await onSaveToGallery(id);
    } else if (result == 'delete') {
      await onDeleteTap(id);
    }
  }
}
