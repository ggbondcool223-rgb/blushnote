import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:blush_note/utils/colors.dart';
import 'package:blush_note/utils/index.dart';
import 'package:blush_note/db_blush_note/index.dart';
import 'blush_note_accounting_logic.dart';

class BlushNoteAccountingView extends GetView<BlushNoteAccountingLogic> {
  const BlushNoteAccountingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlushNoteColors.bgMain,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            _buildHeaderCard(),
            Expanded(child: _buildTransactionList()),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'accounting_fab',
        onPressed: () => controller.goToAddPage(),
        backgroundColor: BlushNoteColors.accent,
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
        boxShadow: [
          BoxShadow(
            color: BlushNoteColors.primary.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              Text(
                'Accounting',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: BlushNoteColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => controller.showMonthPicker(),
                      child: Obx(
                        () => Row(
                          children: [
                            Text(
                              formatYearMonthDisplay(
                                controller.currentYearMonth.value,
                              ),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: BlushNoteColors.textMain,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 20.w,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              _buildBudgetSection(),
              SizedBox(height: 16.h),
              _buildSummaryRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetSection() {
    return Obx(() {
      if (!controller.hasBudget.value) {
        return GestureDetector(
          onTap: () => controller.showBudgetDialog(),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              border: Border.all(color: BlushNoteColors.accent),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                'Set Budget',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: BlushNoteColors.accent,
                ),
              ),
            ),
          ),
        );
      }

      final budget = controller.budget.value!;
      final remaining = controller.budgetRemaining.value;
      final progress = controller.budgetProgress.value;
      final spent = controller.monthlyExpense.value;

      return GestureDetector(
        onTap: () => controller.showBudgetDialog(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Budget',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: BlushNoteColors.textSub,
                  ),
                ),
                Text(
                  'Remaining \$${formatAmount(remaining)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: remaining >= 0
                        ? BlushNoteColors.accent
                        : BlushNoteColors.expense,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8.h,
                backgroundColor: const Color(0xFFF0F0F0),
                valueColor: AlwaysStoppedAnimation(
                  progress > 1.0
                      ? BlushNoteColors.expense
                      : BlushNoteColors.accent,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Spent \$${formatAmount(spent)} / Total \$${formatAmount(budget.budgetAmount)}',
              style: TextStyle(fontSize: 10.sp, color: BlushNoteColors.textSub),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryRow() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Income',
              '+\$${formatAmount(controller.monthlyIncome.value)}',
              BlushNoteColors.income,
            ),
          ),
          Expanded(
            child: _buildSummaryItem(
              'Expense',
              '-\$${formatAmount(controller.monthlyExpense.value)}',
              BlushNoteColors.expense,
            ),
          ),
          Expanded(
            child: _buildSummaryItem(
              'Balance',
              '${controller.balanceDiff.value >= 0 ? '+' : ''}\$${formatAmount(controller.balanceDiff.value)}',
              BlushNoteColors.textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: BlushNoteColors.textSub),
        ),
        SizedBox(height: 4.h),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    return Obx(() {
      if (controller.records.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 80.sp,
                color: Colors.grey.shade300,
              ),
              SizedBox(height: 16.h),
              Text(
                'No records yet',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade400),
              ),
              SizedBox(height: 8.h),
              Text(
                'Tap + to add your first record',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
              ),
            ],
          ),
        );
      }

      final grouped = controller.groupedRecords;
      final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

      return ListView.builder(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final records = grouped[date]!;
          return _buildDayGroup(date, records);
        },
      );
    });
  }

  Widget _buildDayGroup(String date, List records) {
    final dateTime = DateTime.parse(date);
    final dateDisplay = formatDateWithWeekday(dateTime);

    double dayIncome = 0;
    double dayExpense = 0;
    for (var record in records) {
      if (record.type == 'income') {
        dayIncome += record.totalAmount;
      } else {
        dayExpense += record.totalAmount;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.pink.shade50.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateDisplay,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: BlushNoteColors.textMain,
                ),
              ),
              Text(
                'Expense: \$${formatAmount(dayExpense)}  Income: \$${formatAmount(dayIncome)}',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: BlushNoteColors.textSub,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        ...records.map((record) => _buildTransactionItem(record)).toList(),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildTransactionItem(record) {
    final isExpense = record.type == 'expense';
    final categoryIcon = _getCategoryIcon(record.categoryId);
    final categoryColor = _getCategoryColor(record.categoryId);

    return GestureDetector(
      onTap: () => controller.goToAddPage(recordId: record.id),
      onLongPress: () => controller.deleteRecord(record.id),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: const Color(0xFFF9F9F9), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(categoryIcon, size: 20.w, color: categoryColor),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<AccountingCategory?>(
                    future: db.getAccountingCategoryById(record.categoryId),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data?.name ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: BlushNoteColors.textMain,
                        ),
                      );
                    },
                  ),
                  if (record.remark != null && record.remark!.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      record.remark!,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: BlushNoteColors.textSub,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Text(
              '${isExpense ? '-' : '+'}\$${formatAmount(record.totalAmount)}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isExpense
                    ? BlushNoteColors.expense
                    : BlushNoteColors.income,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(int categoryId) {
    const icons = [
      Icons.star,
      Icons.restaurant,
      Icons.directions_bus,
      Icons.shopping_bag,
      Icons.movie,
      Icons.local_hospital,
      Icons.school,
      Icons.home,
      Icons.more_horiz,
      Icons.attach_money,
      Icons.card_giftcard,
      Icons.trending_up,
      Icons.work,
    ];
    return categoryId > 0 && categoryId <= icons.length
        ? icons[categoryId - 1]
        : Icons.more_horiz;
  }

  Color _getCategoryColor(int categoryId) {
    const colors = [
      Colors.orange,
      Colors.red,
      Colors.blue,
      Colors.pink,
      Colors.purple,
      Colors.green,
      Colors.indigo,
      Colors.brown,
      Colors.grey,
      Colors.teal,
      Colors.lime,
      Colors.amber,
      Colors.cyan,
    ];
    return categoryId > 0 && categoryId <= colors.length
        ? colors[categoryId - 1]
        : Colors.grey;
  }
}
