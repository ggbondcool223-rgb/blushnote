import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:blush_note/utils/colors.dart';
import 'blush_note_accounting_add_logic.dart';

class BlushNoteAccountingAddView extends GetView<BlushNoteAccountingAddLogic> {
  final bool isIncome;

  const BlushNoteAccountingAddView({super.key, this.isIncome = false});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.type.value = isIncome ? 'income' : 'expense';
    });

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: BlushNoteColors.bgMain,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: Colors.grey.shade400,
          onPressed: () => Get.back(),
        ),
        title: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTypeTab('Expense', false),
              _buildTypeTab('Income', true),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.grey.shade400),
            onPressed: controller.selectDateTime,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  _buildAmountCard(),
                  SizedBox(height: 20.h),
                  _buildNoteCard(),
                  SizedBox(height: 20.h),
                  _buildPhotoAndTime(),
                ],
              ),
            ),
          ),
          if (!isKeyboardVisible) _buildKeyboard(),
        ],
      ),
    );
  }

  Widget _buildTypeTab(String label, bool isIncomeTab) {
    return Obx(() {
      final isSelected = (controller.type.value == 'income') == isIncomeTab;
      return GestureDetector(
        onTap: () => controller.switchType(isIncomeTab ? 'income' : 'expense'),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isSelected ? BlushNoteColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? BlushNoteColors.accent
                  : BlushNoteColors.textSub,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAmountCard() {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: BlushNoteColors.primary.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(Get.context!).unfocus();
                      controller.switchInputMode('price');
                    },
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: controller.inputMode.value == 'price'
                            ? BlushNoteColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: controller.inputMode.value == 'price'
                              ? BlushNoteColors.accent.withOpacity(0.3)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Unit Price',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: BlushNoteColors.textSub,
                                ),
                              ),
                              if (controller.inputMode.value == 'price')
                                Container(
                                  width: 4.w,
                                  height: 4.w,
                                  margin: EdgeInsets.only(left: 6.w),
                                  decoration: BoxDecoration(
                                    color: BlushNoteColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            controller.unitPrice.value.isEmpty
                                ? '\$0.00'
                                : '\$${double.tryParse(controller.unitPrice.value)?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: controller.type.value == 'expense'
                                  ? BlushNoteColors.expense
                                  : BlushNoteColors.income,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(Get.context!).unfocus();
                      controller.switchInputMode('quantity');
                    },
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: controller.inputMode.value == 'quantity'
                            ? BlushNoteColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: controller.inputMode.value == 'quantity'
                              ? BlushNoteColors.accent.withOpacity(0.3)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (controller.inputMode.value == 'quantity')
                                Container(
                                  width: 4.w,
                                  height: 4.w,
                                  margin: EdgeInsets.only(right: 6.w),
                                  decoration: BoxDecoration(
                                    color: BlushNoteColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              Text(
                                'Quantity',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: BlushNoteColors.textSub,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            controller.quantity.value.isEmpty
                                ? '1.00'
                                : (double.tryParse(
                                        controller.quantity.value,
                                      )?.toStringAsFixed(2) ??
                                      '1.00'),
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: BlushNoteColors.textMain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey.shade50),
            GestureDetector(
              onTap: controller.selectCategory,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Category',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: BlushNoteColors.textMain,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(8.w).copyWith(left: 12.w),
                    decoration: BoxDecoration(
                      color: controller.selectedCategory.value != null
                          ? Color(
                              int.parse(
                                '0xFF${controller.selectedCategory.value!.color.replaceAll('#', '')}',
                              ),
                            ).withOpacity(0.2)
                          : Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: controller.selectedCategory.value != null
                          ? Text(
                              controller.selectedCategory.value!.icon,
                              style: TextStyle(fontSize: 20.sp),
                            )
                          : Icon(
                              Icons.restaurant,
                              size: 20.w,
                              color: Colors.pink.shade400,
                            ),
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

  Widget _buildNoteCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: BlushNoteColors.primary.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Note',
            style: TextStyle(fontSize: 12.sp, color: BlushNoteColors.textSub),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: controller.remarkController,
            decoration: InputDecoration(
              hintText: 'Add note...',
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade300,
              ),
              border: InputBorder.none,
            ),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: BlushNoteColors.textMain,
            ),
            maxLines: 3,
            minLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoAndTime() {
    return Obx(
      () => Column(
        children: [
          if (controller.selectedImages.isNotEmpty) ...[
            SizedBox(
              height: 80.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.selectedImages.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final imagePath = controller.selectedImages[index];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(
                          File(imagePath),
                          width: 80.w,
                          height: 80.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4.w,
                        right: 4.w,
                        child: GestureDetector(
                          onTap: () => controller.removeImage(index),
                          child: Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 14.w,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 12.h),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: controller.pickImages,
                child: Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: BlushNoteColors.primary,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 24.w,
                    color: BlushNoteColors.primary,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat(
                      'yyyy-MM-dd HH:mm',
                    ).format(controller.recordDateTime.value),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: BlushNoteColors.textSub,
                    ),
                  ),
                  Text(
                    DateFormat('EEEE').format(controller.recordDateTime.value),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: BlushNoteColors.textSub,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                final price = double.tryParse(controller.unitPrice.value) ?? 0;
                final qty = double.tryParse(controller.quantity.value) ?? 1;
                final total = price * qty;
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                    color: controller.type.value == 'expense'
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: BlushNoteColors.textSub,
                        ),
                      ),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: controller.type.value == 'expense'
                              ? BlushNoteColors.expense
                              : BlushNoteColors.income,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              Column(
                children: [
                  _buildKeyboardRow(['7', '8', '9']),
                  SizedBox(height: 8.h),
                  _buildKeyboardRow(['4', '5', '6']),
                  SizedBox(height: 8.h),
                  _buildKeyboardRow(['1', '2', '3']),
                  SizedBox(height: 8.h),
                  _buildKeyboardRow(['.', '0', 'del']),
                  SizedBox(height: 8.h),
                  _buildConfirmButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: _buildKeyButton(key),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeyButton(String key) {
    final isDelete = key == 'del';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.onKeyboardInput(key),
        borderRadius: BorderRadius.circular(12.r),
        child: Ink(
          height: 56.h,
          decoration: BoxDecoration(
            color: isDelete ? Colors.grey.shade100 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Center(
            child: isDelete
                ? Icon(
                    Icons.backspace_outlined,
                    size: 24.w,
                    color: BlushNoteColors.textSub,
                  )
                : Text(
                    key,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                      color: BlushNoteColors.textMain,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Obx(
      () => GestureDetector(
        onTap: controller.isSaving.value ? null : controller.saveRecord,
        child: Container(
          height: 56.h,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: controller.isSaving.value
                  ? [Colors.grey.shade300, Colors.grey.shade400]
                  : controller.type.value == 'expense'
                  ? [Colors.red.shade400, Colors.red.shade500]
                  : [Colors.green.shade400, Colors.green.shade500],
            ),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: controller.isSaving.value
                ? []
                : [
                    BoxShadow(
                      color: controller.type.value == 'expense'
                          ? Colors.red.shade200
                          : Colors.green.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: controller.isSaving.value
              ? SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
