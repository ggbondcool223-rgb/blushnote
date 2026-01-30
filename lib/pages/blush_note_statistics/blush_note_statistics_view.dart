import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:blush_note/utils/colors.dart';
import 'blush_note_statistics_logic.dart';

class BlushNoteStatisticsView extends GetView<BlushNoteStatisticsLogic> {
  const BlushNoteStatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlushNoteColors.bgMain,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: Obx(
                () => controller.isLoading.value
                    ? _buildLoading()
                    : SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.h),
                            _buildOverviewCards(),
                            SizedBox(height: 20.h),
                            _buildDiarySection(),
                            SizedBox(height: 20.h),
                            _buildAccountingSection(),
                            SizedBox(height: 20.h),
                            _buildScheduleSection(),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 15.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 32.w,
              height: 32.w,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: BlushNoteColors.textMain,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Life Statistics',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: BlushNoteColors.textMain,
                  ),
                ),
                Text(
                  'Your life journey at a glance',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: BlushNoteColors.textSub,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.calendar_month,
              size: 22.w,
              color: BlushNoteColors.primary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            onSelected: (value) {
              controller.changePeriod(value);
            },
            itemBuilder: (context) => [
              _buildMenuItem('This Month', 'month'),
              _buildMenuItem('Last 3 Months', '3months'),
              _buildMenuItem('This Year', 'year'),
              _buildMenuItem('All Time', 'all'),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuEntry<String> _buildMenuItem(String label, String value) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: controller.selectedPeriod.value == value
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: controller.selectedPeriod.value == value
                  ? BlushNoteColors.primary
                  : BlushNoteColors.textMain,
            ),
          ),
          if (controller.selectedPeriod.value == value) ...[
            SizedBox(width: 8.w),
            Icon(Icons.check, size: 16.w, color: BlushNoteColors.primary),
          ],
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(BlushNoteColors.primary),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Obx(
      () => Row(
        children: [
          _buildOverviewCard(
            icon: Icons.auto_stories,
            iconColor: const Color(0xFFFF9AA2),
            title: 'Diaries',
            value: controller.stats.value.totalDiaries.toString(),
            subtitle: '${controller.stats.value.totalWords} words',
          ),
          SizedBox(width: 12.w),
          _buildOverviewCard(
            icon: Icons.edit_note,
            iconColor: const Color(0xFFFFB7B2),
            title: 'Handbooks',
            value: controller.stats.value.totalHandbooks.toString(),
            subtitle: 'creative works',
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, size: 20.w, color: iconColor),
            ),
            SizedBox(height: 12.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: BlushNoteColors.textMain,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: BlushNoteColors.textSub,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.sp,
                color: BlushNoteColors.textSub.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiarySection() {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.book, size: 20.w, color: BlushNoteColors.primary),
                SizedBox(width: 8.w),
                Text(
                  'Diary Insights',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: BlushNoteColors.textMain,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildStatRow(
              'Total Entries',
              '${controller.stats.value.totalDiaries}',
            ),
            _buildStatRow(
              'Total Words',
              '${controller.stats.value.totalWords}',
            ),
            _buildStatRow(
              'Avg Words/Entry',
              controller.stats.value.totalDiaries > 0
                  ? '${(controller.stats.value.totalWords / controller.stats.value.totalDiaries).toStringAsFixed(0)}'
                  : '0',
            ),
            _buildStatRow(
              'Most Active Hour',
              controller.stats.value.mostActiveHour,
            ),
            if (controller.stats.value.commonWeather.isNotEmpty)
              _buildStatRow(
                'Common Weather',
                controller.stats.value.commonWeather,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountingSection() {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 20.w,
                  color: BlushNoteColors.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Financial Summary',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: BlushNoteColors.textMain,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildFinancialCard(
                    'Income',
                    '\$${controller.stats.value.totalIncome.toStringAsFixed(2)}',
                    const Color(0xFF4CAF50),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildFinancialCard(
                    'Expense',
                    '\$${controller.stats.value.totalExpense.toStringAsFixed(2)}',
                    const Color(0xFFFF9AA2),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Net Balance',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: BlushNoteColors.textMain,
                    ),
                  ),
                  Text(
                    '\$${(controller.stats.value.totalIncome - controller.stats.value.totalExpense).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color:
                          (controller.stats.value.totalIncome -
                                  controller.stats.value.totalExpense) >=
                              0
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF5252),
                    ),
                  ),
                ],
              ),
            ),
            if (controller.stats.value.expenseRecords > 0) ...[
              SizedBox(height: 12.h),
              _buildStatRow(
                'Total Records',
                '${controller.stats.value.expenseRecords}',
              ),
              _buildStatRow(
                'Avg Expense',
                '\$${(controller.stats.value.totalExpense / controller.stats.value.expenseRecords).toStringAsFixed(2)}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard(String label, String amount, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: BlushNoteColors.textSub),
          ),
          SizedBox(height: 4.h),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 20.w,
                  color: BlushNoteColors.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Schedule Performance',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: BlushNoteColors.textMain,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (controller.stats.value.totalSchedules > 0) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildScheduleCard(
                      'Total',
                      '${controller.stats.value.totalSchedules}',
                      Colors.grey.shade400,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildScheduleCard(
                      'Completed',
                      '${controller.stats.value.completedSchedules}',
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildScheduleCard(
                      'Pending',
                      '${controller.stats.value.totalSchedules - controller.stats.value.completedSchedules}',
                      const Color(0xFFFF9AA2),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Completion Rate',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: BlushNoteColors.textMain,
                      ),
                    ),
                    Text(
                      '${((controller.stats.value.completedSchedules / controller.stats.value.totalSchedules) * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Text(
                    'No schedules yet',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: BlushNoteColors.textSub,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: BlushNoteColors.textSub),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: BlushNoteColors.textSub),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: BlushNoteColors.textMain,
            ),
          ),
        ],
      ),
    );
  }
}
