import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:blush_note/pages/blush_note_home/blush_note_home_view.dart';
import 'package:blush_note/pages/blush_note_diary_list/blush_note_diary_list_view.dart';
import 'package:blush_note/pages/blush_note_accounting/blush_note_accounting_view.dart';
import 'package:blush_note/pages/blush_note_settings/blush_note_settings_view.dart';
import 'package:blush_note/utils/colors.dart';
import 'blush_note_tab_logic.dart';

class BlushNoteTabView extends GetView<BlushNoteTabLogic> {
  const BlushNoteTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlushNoteColors.bgMain,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            BlushNoteHomeView(),
            BlushNoteDiaryListView(),
            BlushNoteAccountingView(),
            BlushNoteSettingsView(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() => _buildBottomNavigationBar(context)),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      height: 84.h,
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
            _buildTabItem(
              icon: Icons.home,
              label: 'Home',
              index: 0,
              isActive: controller.currentIndex.value == 0,
            ),
            _buildTabItem(
              icon: Icons.menu_book,
              label: 'Diary',
              index: 1,
              isActive: controller.currentIndex.value == 1,
            ),
            _buildFAB(context),
            _buildTabItem(
              icon: Icons.wallet,
              label: 'Money',
              index: 2,
              isActive: controller.currentIndex.value == 2,
            ),
            _buildTabItem(
              icon: Icons.person,
              label: 'Me',
              index: 3,
              isActive: controller.currentIndex.value == 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.onTabChange(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24.w,
                color: isActive
                    ? BlushNoteColors.accent
                    : BlushNoteColors.textSub,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isActive
                      ? BlushNoteColors.accent
                      : BlushNoteColors.textSub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -24.h),
      child: GestureDetector(
        onTap: () => _showQuickAddMenu(context),
        child: Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            color: BlushNoteColors.accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: BlushNoteColors.accent.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(Icons.add, size: 28.w, color: Colors.white),
        ),
      ),
    );
  }

  void _showQuickAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuickAddItem(
                icon: Icons.book_outlined,
                iconColor: Colors.pink.shade400,
                iconBg: Colors.pink.shade50,
                label: 'Add Diary',
                onTap: () {
                  Get.back();
                  Get.toNamed('/diary/edit');
                },
              ),
              _buildQuickAddItem(
                icon: Icons.palette_outlined,
                iconColor: Colors.orange.shade400,
                iconBg: Colors.orange.shade50,
                label: 'Add Handbook',
                onTap: () {
                  Get.back();
                  Get.toNamed('/handbook/edit');
                },
              ),
              _buildQuickAddItem(
                icon: Icons.wallet_outlined,
                iconColor: Colors.blue.shade400,
                iconBg: Colors.blue.shade50,
                label: 'Add Transaction',
                onTap: () {
                  Get.back();
                  Get.toNamed('/accounting/add/expense');
                },
              ),
              _buildQuickAddItem(
                icon: Icons.calendar_today_outlined,
                iconColor: Colors.purple.shade400,
                iconBg: Colors.purple.shade50,
                label: 'Add Schedule',
                onTap: () {
                  Get.back();
                  Get.toNamed('/schedule/add');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAddItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r)),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, size: 20.w, color: iconColor),
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: BlushNoteColors.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
