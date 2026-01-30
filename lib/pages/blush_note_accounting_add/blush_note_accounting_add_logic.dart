import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:blush_note/db_blush_note/index.dart';
import 'package:blush_note/db_blush_note/db_blush_note_entity.dart';
import 'package:blush_note/utils/index.dart';

class BlushNoteAccountingAddLogic extends GetxController {
  int? recordId;
  
  final type = 'expense'.obs;
  
  final unitPrice = ''.obs;
  final quantity = '1.00'.obs;
  final selectedCategory = Rxn<AccountingCategory>();
  final remark = ''.obs;
  final selectedImages = <String>[].obs;
  final recordDateTime = DateTime.now().obs;
  
  final inputMode = 'price'.obs;
  
  final categories = <AccountingCategory>[].obs;
  
  late TextEditingController unitPriceController;
  late TextEditingController quantityController;
  late TextEditingController remarkController;
  
  final _picker = ImagePicker();
  
  final isLoading = false.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    unitPriceController = TextEditingController();
    quantityController = TextEditingController(text: '1.00');
    remarkController = TextEditingController();
    
    unitPriceController.addListener(() {
      unitPrice.value = unitPriceController.text;
    });
    quantityController.addListener(() {
      quantity.value = quantityController.text;
    });
    remarkController.addListener(() {
      remark.value = remarkController.text;
    });
    
    final args = Get.arguments as Map<String, dynamic>?;
    recordId = args?['recordId'];
    
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      
      await loadCategories();
      
      if (recordId != null) {
        await loadRecord(recordId!);
      } else {
        if (categories.isNotEmpty) {
          selectedCategory.value = categories.first;
        }
      }
    } catch (e) {
      errorToast('Failed to load data');
      print('Error loading data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCategories() async {
    try {
      final result = await db.getAccountingCategories(type: type.value);
      categories.value = result;
      
      if (selectedCategory.value != null) {
        final found = result.firstWhereOrNull(
          (c) => c.id == selectedCategory.value!.id,
        );
        if (found == null && result.isNotEmpty) {
          selectedCategory.value = result.first;
        }
      } else if (result.isNotEmpty) {
        selectedCategory.value = result.first;
      }
    } catch (e) {
      print('Error loading categories: $e');
      rethrow;
    }
  }

  Future<void> loadRecord(int id) async {
    try {
      final record = await db.getAccountingRecordById(id);
      if (record == null) {
        errorToast('Record not found');
        Get.back();
        return;
      }
      
      type.value = record.type;
      
      await loadCategories();
      
      unitPriceController.text = record.unitPrice.toStringAsFixed(2);
      quantityController.text = record.quantity.toStringAsFixed(2);
      remarkController.text = record.remark ?? '';
      recordDateTime.value = DateTime.parse(record.recordTime);
      
      selectedCategory.value = categories.firstWhereOrNull(
        (c) => c.id == record.categoryId,
      );
      
      try {
        final imagesList = jsonDecode(record.imagesJson) as List;
        selectedImages.value = imagesList.map((e) => e.toString()).toList();
      } catch (e) {
        print('Error parsing images: $e');
      }
    } catch (e) {
      errorToast('Failed to load record');
      print('Error loading record: $e');
    }
  }

  Future<void> switchType(String newType) async {
    if (type.value == newType) return;
    
    type.value = newType;
    await loadCategories();
  }

  Future<void> selectCategory() async {
    if (categories.isEmpty) {
      errorToast('No categories available');
      return;
    }
    
    final selected = await Get.dialog<AccountingCategory>(
      AlertDialog(
        title: const Text('Select Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategory.value?.id == category.id;
              
              return ListTile(
                leading: Icon(
                  Icons.circle,
                  color: Color(int.parse('0xFF${category.color.replaceAll('#', '')}')),
                  size: 16,
                ),
                title: Text(category.name),
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () => Get.back(result: category),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    
    if (selected != null) {
      selectedCategory.value = selected;
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
      }
    } catch (e) {
      errorToast('Failed to pick images');
      print('Error picking images: $e');
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  Future<void> selectDateTime() async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: recordDateTime.value,
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
    
    if (date != null) {
      final time = await showTimePicker(
        context: Get.context!,
        initialTime: TimeOfDay.fromDateTime(recordDateTime.value),
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
      
      if (time != null) {
        recordDateTime.value = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      }
    }
  }

  double calculateTotal() {
    final price = double.tryParse(unitPrice.value) ?? 0.0;
    final qty = double.tryParse(quantity.value) ?? 1.0;
    return price * qty;
  }

  void onKeypadInput(String key) {
    if (inputMode.value == 'price') {
      _inputToField(unitPrice, key);
    } else {
      _inputToField(quantity, key);
    }
  }

  void _inputToField(RxString field, String key) {
    String current = field.value;
    
    if (key == '.') {
      if (current.contains('.')) return;
      if (current.isEmpty) {
        field.value = '0.';
      } else {
        field.value = current + '.';
      }
    } else {
      if (current == '0' || current.isEmpty) {
        field.value = key;
      } else {
        if (current.contains('.')) {
          final parts = current.split('.');
          if (parts[1].length >= 2) return;
        }
        field.value = current + key;
      }
    }
  }

  void onKeypadDelete() {
    if (inputMode.value == 'price') {
      if (unitPrice.value.isNotEmpty) {
        unitPrice.value = unitPrice.value.substring(0, unitPrice.value.length - 1);
      }
    } else {
      if (quantity.value.isNotEmpty) {
        quantity.value = quantity.value.substring(0, quantity.value.length - 1);
      }
    }
  }

  void switchInputMode(String mode) {
    inputMode.value = mode;
  }

  void onKeyboardInput(String key) {
    if (key == 'del') {
      if (inputMode.value == 'price') {
        if (unitPrice.value.isNotEmpty) {
          unitPrice.value = unitPrice.value.substring(0, unitPrice.value.length - 1);
          unitPriceController.text = unitPrice.value;
        }
      } else {
        if (quantity.value.isNotEmpty) {
          quantity.value = quantity.value.substring(0, quantity.value.length - 1);
          quantityController.text = quantity.value;
        }
      }
    } else if (key == '.') {
      if (inputMode.value == 'price') {
        if (!unitPrice.value.contains('.')) {
          unitPrice.value = unitPrice.value.isEmpty ? '0.' : '${unitPrice.value}.';
          unitPriceController.text = unitPrice.value;
        }
      } else {
        if (!quantity.value.contains('.')) {
          quantity.value = quantity.value.isEmpty ? '0.' : '${quantity.value}.';
          quantityController.text = quantity.value;
        }
      }
    } else {
      if (inputMode.value == 'price') {
        if (unitPrice.value.contains('.')) {
          final parts = unitPrice.value.split('.');
          if (parts[1].length >= 2) return;
        }
        if (unitPrice.value.length >= 10) return;
        
        unitPrice.value = unitPrice.value + key;
        unitPriceController.text = unitPrice.value;
      } else {
        if (quantity.value.contains('.')) {
          final parts = quantity.value.split('.');
          if (parts[1].length >= 2) return;
        }
        if (quantity.value.length >= 10) return;
        
        quantity.value = quantity.value + key;
        quantityController.text = quantity.value;
      }
    }
  }

  Future<void> saveRecord() async {
    await save();
  }

  bool validate() {
    if (unitPrice.value.isEmpty || double.tryParse(unitPrice.value) == null) {
      errorToast('Please enter unit price');
      return false;
    }
    
    final price = double.parse(unitPrice.value);
    if (price <= 0) {
      errorToast('Unit price must be greater than 0');
      return false;
    }
    
    if (quantity.value.isEmpty || double.tryParse(quantity.value) == null) {
      errorToast('Please enter quantity');
      return false;
    }
    
    final qty = double.parse(quantity.value);
    if (qty <= 0) {
      errorToast('Quantity must be greater than 0');
      return false;
    }
    
    if (selectedCategory.value == null) {
      errorToast('Please select a category');
      return false;
    }
    
    return true;
  }

  Future<void> save() async {
    if (!validate()) return;
    
    try {
      isSaving.value = true;
      
      final price = double.parse(unitPrice.value);
      final qty = double.parse(quantity.value);
      final total = price * qty;
      
      final now = DateTime.now().toIso8601String();
      final imagesJson = jsonEncode(selectedImages);
      
      if (recordId == null) {
        final record = AccountingRecord(
          type: type.value,
          unitPrice: price,
          quantity: qty,
          totalAmount: total,
          categoryId: selectedCategory.value!.id!,
          remark: remark.value.isEmpty ? null : remark.value,
          imagesJson: imagesJson,
          recordTime: recordDateTime.value.toIso8601String(),
          createdAt: now,
        );
        
        await db.insertAccountingRecord(record);
        
        await db.incrementCategoryUsageCount(selectedCategory.value!.id!);
        
        successToast('Record added');
      } else {
        final original = await db.getAccountingRecordById(recordId!);
        if (original == null) {
          errorToast('Record not found');
          return;
        }
        
        final record = AccountingRecord(
          id: recordId,
          type: type.value,
          unitPrice: price,
          quantity: qty,
          totalAmount: total,
          categoryId: selectedCategory.value!.id!,
          remark: remark.value.isEmpty ? null : remark.value,
          imagesJson: imagesJson,
          recordTime: recordDateTime.value.toIso8601String(),
          createdAt: original.createdAt,
        );
        
        await db.updateAccountingRecord(record);
        
        if (original.categoryId != selectedCategory.value!.id!) {
          await db.incrementCategoryUsageCount(selectedCategory.value!.id!);
        }
        
        successToast('Record updated');
      }
      
      Get.back(result: true);
    } catch (e) {
      errorToast('Failed to save record');
      print('Error saving record: $e');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    unitPriceController.dispose();
    quantityController.dispose();
    remarkController.dispose();
    super.onClose();
  }
}
