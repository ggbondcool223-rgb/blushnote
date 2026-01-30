import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:blush_note/utils/colors.dart';
import 'blush_note_settings_logic.dart';

class BlushNoteSettingsView extends GetView<BlushNoteSettingsLogic> {
  const BlushNoteSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlushNoteColors.bgMain,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: BlushNoteColors.textMain,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    _buildSettingsGroup([
                      _buildSettingItem(
                        icon: Icons.bar_chart,
                        iconColor: BlushNoteColors.primary,
                        iconBg: BlushNoteColors.primary.withValues(alpha: 0.1),
                        title: 'Life Statistics',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View insights',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: BlushNoteColors.textSub,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.chevron_right,
                              size: 16.w,
                              color: Colors.grey.shade200,
                            ),
                          ],
                        ),
                        onTap: () => Get.toNamed('/blush_statistics'),
                      ),
                    ]),
                    SizedBox(height: 16.h),
                    _buildSettingsGroup([
                      _buildSettingItem(
                        icon: Icons.info_outline,
                        iconColor: Colors.grey.shade400,
                        iconBg: Colors.grey.shade50,
                        title: 'About BlushNote',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'v1.0.0',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: BlushNoteColors.textSub,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.chevron_right,
                              size: 16.w,
                              color: Colors.grey.shade200,
                            ),
                          ],
                        ),
                        onTap: () {},
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: const Color(0xFFFDF0F5), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 16.w, color: iconColor),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: BlushNoteColors.textMain,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  size: 16.w,
                  color: Colors.grey.shade200,
                ),
          ],
        ),
      ),
    );
  }
}
