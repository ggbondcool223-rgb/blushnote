import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:blush_note/db_blush_note/index.dart';
import 'package:blush_note/db_blush_note/db_blush_note_entity.dart';
import 'package:blush_note/utils/index.dart';
import 'package:blush_note/utils/colors.dart';

class BlushNoteAccountingLogic extends GetxController {
  final currentYearMonth = ''.obs;

  final budget = Rxn<Budget>();
  final hasBudget = false.obs;
  final budgetRemaining = 0.0.obs;
  final budgetProgress = 0.0.obs;

  final records = <AccountingRecord>[].obs;
  final groupedRecords = <String, List<AccountingRecord>>{}.obs;

  final monthlyIncome = 0.0.obs;
  final monthlyExpense = 0.0.obs;
  final balanceDiff = 0.0.obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    currentYearMonth.value = getYearMonth(DateTime.now());
    loadMonthData();
  }

  Future<void> loadMonthData() async {
    try {
      isLoading.value = true;

      await _loadBudget();

      await _loadRecords();

      await _loadStatistics();

      _calculateBudgetProgress();

      _groupRecordsByDate();
    } catch (e) {
      errorToast('Failed to load data');
      print('Error loading month data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadBudget() async {
    try {
      final result = await db.getBudgetByYearMonth(currentYearMonth.value);
      budget.value = result;
      hasBudget.value = result != null;
    } catch (e) {
      print('Error loading budget: $e');
      rethrow;
    }
  }

  Future<void> _loadRecords() async {
    try {
      final result = await db.getAccountingRecords(
        yearMonth: currentYearMonth.value,
      );
      records.value = result;
    } catch (e) {
      print('Error loading records: $e');
      rethrow;
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final income = await db.getMonthlyIncome(currentYearMonth.value);
      final expense = await db.getMonthlyExpense(currentYearMonth.value);

      monthlyIncome.value = income;
      monthlyExpense.value = expense;
      balanceDiff.value = income - expense;
    } catch (e) {
      print('Error loading statistics: $e');
      rethrow;
    }
  }

  void _calculateBudgetProgress() {
    if (budget.value != null) {
      final budgetAmount = budget.value!.budgetAmount;
      budgetRemaining.value = budgetAmount - monthlyExpense.value;
      budgetProgress.value = budgetAmount > 0
          ? (monthlyExpense.value / budgetAmount).clamp(0.0, 1.5)
          : 0.0;
    } else {
      budgetRemaining.value = 0.0;
      budgetProgress.value = 0.0;
    }
  }

  void _groupRecordsByDate() {
    groupedRecords.value = groupByDate(
      records,
      (record) => extractDateFromDateTime(record.recordTime),
    );
  }

  Future<void> showMonthPicker() async {
    final currentDate = parseYearMonth(currentYearMonth.value);
    int selectedYear = currentDate.year;
    int selectedMonth = currentDate.month;

    final result = await Get.dialog<DateTime>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(24.w),
              width: 320.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select Month',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: BlushNoteColors.textMain,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            selectedYear--;
                          });
                        },
                        icon: const Icon(Icons.chevron_left),
                        color: BlushNoteColors.accent,
                      ),
                      SizedBox(
                        width: 80.w,
                        child: Text(
                          '$selectedYear',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: BlushNoteColors.textMain,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            selectedYear++;
                          });
                        },
                        icon: const Icon(Icons.chevron_right),
                        color: BlushNoteColors.accent,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 2.0,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final month = index + 1;
                      final isSelected = month == selectedMonth;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedMonth = month;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? BlushNoteColors.accent
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _getMonthName(month),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : BlushNoteColors.textMain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: BlushNoteColors.textSub,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.back(
                            result: DateTime(selectedYear, selectedMonth, 1),
                          ),
                          child: Container(
                            height: 48.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  BlushNoteColors.accent,
                                  BlushNoteColors.accent.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: BlushNoteColors.accent.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Confirm',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    if (result != null) {
      changeMonth(getYearMonth(result));
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Future<void> changeMonth(String yearMonth) async {
    if (yearMonth == currentYearMonth.value) return;

    currentYearMonth.value = yearMonth;
    await loadMonthData();
  }

  Future<void> showBudgetDialog() async {
    final budgetAmount =
        (budget.value?.budgetAmount.toStringAsFixed(0) ?? '').obs;

    final result = await Get.dialog<double>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: Colors.blue.shade400,
                      size: 24.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Set Monthly Budget',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: BlushNoteColors.textMain,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16.w, right: 8.w),
                      child: Text(
                        '\$',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: BlushNoteColors.textMain,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Obx(
                        () => TextField(
                          controller:
                              TextEditingController(text: budgetAmount.value)
                                ..selection = TextSelection.fromPosition(
                                  TextPosition(
                                    offset: budgetAmount.value.length,
                                  ),
                                ),
                          onChanged: (value) => budgetAmount.value = value,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: BlushNoteColors.textMain,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter budget amount',
                            hintStyle: TextStyle(
                              fontSize: 16.sp,
                              color: BlushNoteColors.textSub,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 14.h,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: BlushNoteColors.textSub,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final amount = double.tryParse(budgetAmount.value);
                        if (amount != null && amount > 0) {
                          Get.back(result: amount);
                        } else {
                          errorToast('Please enter valid amount');
                        }
                      },
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade500,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade200,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      await saveBudget(result);
    }
  }

  Future<void> saveBudget(double amount) async {
    try {
      final now = DateTime.now().toIso8601String();

      if (budget.value != null) {
        final updated = Budget(
          id: budget.value!.id,
          yearMonth: currentYearMonth.value,
          budgetAmount: amount,
          createdAt: budget.value!.createdAt,
          updatedAt: now,
        );
        await db.updateBudget(updated);
      } else {
        final newBudget = Budget(
          yearMonth: currentYearMonth.value,
          budgetAmount: amount,
          createdAt: now,
          updatedAt: now,
        );
        await db.insertBudget(newBudget);
      }

      successToast('Budget saved');
      await loadMonthData();
    } catch (e) {
      errorToast('Failed to save budget');
      print('Error saving budget: $e');
    }
  }

  Future<void> deleteRecord(int id) async {
    try {
      final confirmed = await Get.dialog<bool>(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: Colors.red.shade400,
                    size: 32.w,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Delete Record',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: BlushNoteColors.textMain,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Are you sure you want to delete this record?\nThis action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: BlushNoteColors.textSub,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.back(result: false),
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: BlushNoteColors.textSub,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.back(result: true),
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade400,
                                Colors.red.shade500,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.shade200,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (confirmed == true) {
        await db.deleteAccountingRecord(id);
        successToast('Record deleted');
        await loadMonthData();
      }
    } catch (e) {
      errorToast('Failed to delete record');
      print('Error deleting record: $e');
    }
  }

  Future<void> goToAddPage({int? recordId}) async {
    final type = await Get.dialog<String>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Record',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: BlushNoteColors.textMain,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Choose record type',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: BlushNoteColors.textSub,
                ),
              ),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: () => Get.back(result: 'income'),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.green.shade100, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.add_circle_outline,
                          color: Colors.green.shade600,
                          size: 28.w,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Income',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Add income record',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.green.shade400,
                        size: 16.w,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () => Get.back(result: 'expense'),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.red.shade100, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red.shade600,
                          size: 28.w,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expense',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Add expense record',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.red.shade400,
                        size: 16.w,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: double.infinity,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: BlushNoteColors.textSub,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (type != null) {
      await Get.toNamed(
        type == 'income'
            ? '/accounting/add/income'
            : '/accounting/add/expense',
        arguments: {'recordId': recordId, 'yearMonth': currentYearMonth.value},
      );
      await refreshData();
    }
  }

  Future<void> refreshData() async {
    await loadMonthData();
  }
}
