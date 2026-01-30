
class Handbook {
  final int? id;
  final String title;
  final String? backgroundImage;
  final String elementsJson;
  final String? imagePath;
  final String createdAt;
  final String updatedAt;

  const Handbook({
    this.id,
    required this.title,
    this.backgroundImage,
    required this.elementsJson,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Handbook.fromMap(Map<String, dynamic> map) {
    return Handbook(
      id: map['id'] as int?,
      title: map['title'] as String,
      backgroundImage: map['background_image'] as String?,
      elementsJson: map['elements_json'] as String,
      imagePath: map['image_path'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'background_image': backgroundImage,
      'elements_json': elementsJson,
      'image_path': imagePath,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}


class Notebook {
  final int? id;
  final String name;
  final String cover;
  final String createdAt;

  const Notebook({
    this.id,
    required this.name,
    required this.cover,
    required this.createdAt,
  });

  factory Notebook.fromMap(Map<String, dynamic> map) {
    return Notebook(
      id: map['id'] as int?,
      name: map['name'] as String,
      cover: map['cover'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'cover': cover,
      'created_at': createdAt,
    };
  }
}

class Diary {
  final int? id;
  final int notebookId;
  final String title;
  final String content;
  final String date;
  final String? weather;
  final String imagesJson;
  final String? audioPath;
  final String? videoPath;
  final String? paperBackground;
  final int wordCount;
  final String createdAt;
  final String updatedAt;

  const Diary({
    this.id,
    required this.notebookId,
    required this.title,
    required this.content,
    required this.date,
    this.weather,
    required this.imagesJson,
    this.audioPath,
    this.videoPath,
    this.paperBackground,
    required this.wordCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Diary.fromMap(Map<String, dynamic> map) {
    return Diary(
      id: map['id'] as int?,
      notebookId: map['notebook_id'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
      date: map['date'] as String,
      weather: map['weather'] as String?,
      imagesJson: map['images_json'] as String,
      audioPath: map['audio_path'] as String?,
      videoPath: map['video_path'] as String?,
      paperBackground: map['paper_background'] as String?,
      wordCount: map['word_count'] as int,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'notebook_id': notebookId,
      'title': title,
      'content': content,
      'date': date,
      'weather': weather,
      'images_json': imagesJson,
      'audio_path': audioPath,
      'video_path': videoPath,
      'paper_background': paperBackground,
      'word_count': wordCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}


class AccountingCategory {
  final int? id;
  final String name;
  final String type;
  final String icon;
  final String color;
  final int sortOrder;
  final int usageCount;
  final String createdAt;

  const AccountingCategory({
    this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.sortOrder,
    required this.usageCount,
    required this.createdAt,
  });

  factory AccountingCategory.fromMap(Map<String, dynamic> map) {
    return AccountingCategory(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      icon: map['icon'] as String,
      color: map['color'] as String,
      sortOrder: map['sort_order'] as int,
      usageCount: map['usage_count'] as int,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'sort_order': sortOrder,
      'usage_count': usageCount,
      'created_at': createdAt,
    };
  }
}

class AccountingRecord {
  final int? id;
  final String type;
  final double unitPrice;
  final double quantity;
  final double totalAmount;
  final int categoryId;
  final String? remark;
  final String imagesJson;
  final String recordTime;
  final String createdAt;

  const AccountingRecord({
    this.id,
    required this.type,
    required this.unitPrice,
    required this.quantity,
    required this.totalAmount,
    required this.categoryId,
    this.remark,
    required this.imagesJson,
    required this.recordTime,
    required this.createdAt,
  });

  factory AccountingRecord.fromMap(Map<String, dynamic> map) {
    return AccountingRecord(
      id: map['id'] as int?,
      type: map['type'] as String,
      unitPrice: map['unit_price'] as double,
      quantity: map['quantity'] as double,
      totalAmount: map['total_amount'] as double,
      categoryId: map['category_id'] as int,
      remark: map['remark'] as String?,
      imagesJson: map['images_json'] as String,
      recordTime: map['record_time'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'unit_price': unitPrice,
      'quantity': quantity,
      'total_amount': totalAmount,
      'category_id': categoryId,
      'remark': remark,
      'images_json': imagesJson,
      'record_time': recordTime,
      'created_at': createdAt,
    };
  }
}

class Budget {
  final int? id;
  final String yearMonth;
  final double budgetAmount;
  final String createdAt;
  final String updatedAt;

  const Budget({
    this.id,
    required this.yearMonth,
    required this.budgetAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      yearMonth: map['year_month'] as String,
      budgetAmount: map['budget_amount'] as double,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'year_month': yearMonth,
      'budget_amount': budgetAmount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}


class Schedule {
  final int? id;
  final String content;
  final String eventColor;
  final String dateTime;
  final String repeatType;
  final String? repeatEndDate;
  final String reminderType;
  final int isCompleted;
  final String? parentId;
  final String createdAt;
  final String updatedAt;

  const Schedule({
    this.id,
    required this.content,
    required this.eventColor,
    required this.dateTime,
    required this.repeatType,
    this.repeatEndDate,
    required this.reminderType,
    required this.isCompleted,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] as int?,
      content: map['content'] as String,
      eventColor: map['event_color'] as String,
      dateTime: map['date_time'] as String,
      repeatType: map['repeat_type'] as String,
      repeatEndDate: map['repeat_end_date'] as String?,
      reminderType: map['reminder_type'] as String,
      isCompleted: map['is_completed'] as int,
      parentId: map['parent_id'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'content': content,
      'event_color': eventColor,
      'date_time': dateTime,
      'repeat_type': repeatType,
      'repeat_end_date': repeatEndDate,
      'reminder_type': reminderType,
      'is_completed': isCompleted,
      'parent_id': parentId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
