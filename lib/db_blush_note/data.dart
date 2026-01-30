import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'db_blush_note_entity.dart';

class BlushNoteDatabase extends GetxService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'blush_note.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE handbook ADD COLUMN image_path TEXT');
      print('数据库已升级：添加 handbook.image_path 字段');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE handbook (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        background_image TEXT,
        elements_json TEXT NOT NULL,
        image_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_handbook_created_at ON handbook(created_at DESC)
    ''');

    await db.execute('''
      CREATE TABLE notebook (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cover TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_notebook_created_at ON notebook(created_at DESC)
    ''');

    await db.execute('''
      CREATE TABLE diary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        notebook_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        weather TEXT,
        images_json TEXT NOT NULL,
        audio_path TEXT,
        video_path TEXT,
        paper_background TEXT,
        word_count INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (notebook_id) REFERENCES notebook (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_diary_notebook_id ON diary(notebook_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_diary_date ON diary(date DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_diary_created_at ON diary(created_at DESC)
    ''');

    await db.execute('''
      CREATE TABLE accounting_category (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        usage_count INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_accounting_category_type ON accounting_category(type)
    ''');

    await db.execute('''
      CREATE INDEX idx_accounting_category_sort ON accounting_category(sort_order)
    ''');

    await _insertDefaultAccountingCategories(db);

    await db.execute('''
      CREATE TABLE accounting_record (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        unit_price REAL NOT NULL,
        quantity REAL NOT NULL,
        total_amount REAL NOT NULL,
        category_id INTEGER NOT NULL,
        remark TEXT,
        images_json TEXT NOT NULL,
        record_time TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES accounting_category (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_accounting_record_type ON accounting_record(type)
    ''');

    await db.execute('''
      CREATE INDEX idx_accounting_record_time ON accounting_record(record_time DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_accounting_record_category ON accounting_record(category_id)
    ''');

    await db.execute('''
      CREATE TABLE budget (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        year_month TEXT NOT NULL UNIQUE,
        budget_amount REAL NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_budget_year_month ON budget(year_month DESC)
    ''');

    await db.execute('''
      CREATE TABLE schedule (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        event_color TEXT NOT NULL,
        date_time TEXT NOT NULL,
        repeat_type TEXT NOT NULL,
        repeat_end_date TEXT,
        reminder_type TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        parent_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_schedule_date_time ON schedule(date_time)
    ''');

    await db.execute('''
      CREATE INDEX idx_schedule_is_completed ON schedule(is_completed)
    ''');
  }

  Future<void> _insertDefaultAccountingCategories(Database db) async {
    final now = DateTime.now().toIso8601String();

    final expenseCategories = [
      {'name': 'General', 'icon': 'general', 'color': '#FF9800', 'sort': 1},
      {'name': 'Food', 'icon': 'food', 'color': '#FF5722', 'sort': 2},
      {'name': 'Transport', 'icon': 'transport', 'color': '#2196F3', 'sort': 3},
      {'name': 'Shopping', 'icon': 'shopping', 'color': '#E91E63', 'sort': 4},
      {
        'name': 'Entertainment',
        'icon': 'entertainment',
        'color': '#9C27B0',
        'sort': 5,
      },
      {'name': 'Medical', 'icon': 'medical', 'color': '#4CAF50', 'sort': 6},
      {'name': 'Education', 'icon': 'education', 'color': '#3F51B5', 'sort': 7},
      {'name': 'Housing', 'icon': 'housing', 'color': '#795548', 'sort': 8},
      {'name': 'Other', 'icon': 'other', 'color': '#607D8B', 'sort': 9},
    ];

    for (var category in expenseCategories) {
      await db.insert('accounting_category', {
        'name': category['name'],
        'type': 'expense',
        'icon': category['icon'],
        'color': category['color'],
        'sort_order': category['sort'],
        'usage_count': 0,
        'created_at': now,
      });
    }

    final incomeCategories = [
      {'name': 'Salary', 'icon': 'salary', 'color': '#4CAF50', 'sort': 1},
      {'name': 'Bonus', 'icon': 'bonus', 'color': '#8BC34A', 'sort': 2},
      {
        'name': 'Investment',
        'icon': 'investment',
        'color': '#CDDC39',
        'sort': 3,
      },
      {'name': 'Part-time', 'icon': 'parttime', 'color': '#00BCD4', 'sort': 4},
      {'name': 'Other', 'icon': 'other', 'color': '#607D8B', 'sort': 5},
    ];

    for (var category in incomeCategories) {
      await db.insert('accounting_category', {
        'name': category['name'],
        'type': 'income',
        'icon': category['icon'],
        'color': category['color'],
        'sort_order': category['sort'],
        'usage_count': 0,
        'created_at': now,
      });
    }
  }


  Future<int> insertHandbook(Handbook handbook) async {
    try {
      final db = await database;
      return await db.insert('handbook', handbook.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Handbook>> getHandbooks() async {
    try {
      final db = await database;
      final maps = await db.query(
        'handbook',
        orderBy: 'created_at DESC, id DESC',
      );
      return maps.map((map) => Handbook.fromMap(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Handbook>> getHandbooksByDate(String date) async {
    try {
      final db = await database;
      final maps = await db.query(
        'handbook',
        where: 'created_at LIKE ?',
        whereArgs: ['$date%'],
        orderBy: 'created_at DESC, id DESC',
      );
      return maps.map((map) => Handbook.fromMap(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Handbook?> getHandbookById(int id) async {
    try {
      final db = await database;
      final maps = await db.query('handbook', where: 'id = ?', whereArgs: [id]);
      if (maps.isEmpty) return null;
      return Handbook.fromMap(maps.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateHandbook(Handbook handbook) async {
    try {
      final db = await database;
      return await db.update(
        'handbook',
        handbook.toMap(),
        where: 'id = ?',
        whereArgs: [handbook.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteHandbook(int id) async {
    try {
      final db = await database;
      return await db.delete('handbook', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }


  Future<int> insertNotebook(Notebook notebook) async {
    try {
      final db = await database;
      return await db.insert('notebook', notebook.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Notebook>> getNotebooks() async {
    try {
      final db = await database;
      final maps = await db.query(
        'notebook',
        orderBy: 'created_at DESC, id DESC',
      );
      return maps.map((map) => Notebook.fromMap(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Notebook?> getNotebookById(int id) async {
    try {
      final db = await database;
      final maps = await db.query('notebook', where: 'id = ?', whereArgs: [id]);
      if (maps.isEmpty) return null;
      return Notebook.fromMap(maps.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateNotebook(Notebook notebook) async {
    try {
      final db = await database;
      return await db.update(
        'notebook',
        notebook.toMap(),
        where: 'id = ?',
        whereArgs: [notebook.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteNotebook(int id) async {
    try {
      final db = await database;
      return await db.delete('notebook', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getNotebookDiaryCount(int notebookId) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM diary WHERE notebook_id = ?',
        [notebookId],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      rethrow;
    }
  }


  Future<int> insertDiary(Diary diary) async {
    try {
      final db = await database;
      return await db.insert('diary', diary.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Diary>> getDiaries({int? notebookId}) async {
    try {
      final db = await database;
      final maps = await db.query(
        'diary',
        where: notebookId != null ? 'notebook_id = ?' : null,
        whereArgs: notebookId != null ? [notebookId] : null,
        orderBy: 'date DESC, created_at DESC, id DESC',
      );
      return maps.map((map) => Diary.fromMap(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Diary>> getDiariesByDate(String date) async {
    try {
      final db = await database;
      final maps = await db.query(
        'diary',
        where: 'date = ?',
        whereArgs: [date],
        orderBy: 'created_at DESC, id DESC',
      );
      return maps.map((map) => Diary.fromMap(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Diary?> getDiaryById(int id) async {
    try {
      final db = await database;
      final maps = await db.query('diary', where: 'id = ?', whereArgs: [id]);
      if (maps.isEmpty) return null;
      return Diary.fromMap(maps.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateDiary(Diary diary) async {
    try {
      final db = await database;
      return await db.update(
        'diary',
        diary.toMap(),
        where: 'id = ?',
        whereArgs: [diary.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteDiary(int id) async {
    try {
      final db = await database;
      return await db.delete('diary', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }


  Future<int> insertAccountingCategory(AccountingCategory category) async {
    try {
      final db = await database;
      return await db.insert('accounting_category', category.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AccountingCategory>> getAccountingCategories({
    String? type,
  }) async {
    try {
      final db = await database;
      final maps = await db.query(
        'accounting_category',
        where: type != null ? 'type = ?' : null,
        whereArgs: type != null ? [type] : null,
        orderBy: 'sort_order ASC, id ASC',
      );
      return maps.map((map) => AccountingCategory.fromMap(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<AccountingCategory?> getAccountingCategoryById(int id) async {
    try {
      final db = await database;
      final maps = await db.query(
        'accounting_category',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) return null;
      return AccountingCategory.fromMap(maps.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateAccountingCategory(AccountingCategory category) async {
    try {
      final db = await database;
      return await db.update(
        'accounting_category',
        category.toMap(),
        where: 'id = ?',
        whereArgs: [category.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteAccountingCategory(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'accounting_category',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> incrementCategoryUsageCount(int categoryId) async {
    try {
      final db = await database;
      return await db.rawUpdate(
        'UPDATE accounting_category SET usage_count = usage_count + 1 WHERE id = ?',
        [categoryId],
      );
    } catch (e) {
      rethrow;
    }
  }


  Future<int> insertAccountingRecord(AccountingRecord record) async {
    try {
      final db = await database;
      final id = await db.insert('accounting_record', record.toMap());
      await incrementCategoryUsageCount(record.categoryId);
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AccountingRecord>> getAccountingRecords({
    String? type,
    String? yearMonth,
  }) async {
    try {
      final db = await database;
      String? where;
      List<dynamic>? whereArgs;

      if (type != null && yearMonth != null) {
        where = 'type = ? AND record_time LIKE ?';
        whereArgs = [type, '$yearMonth%'];
      } else if (type != null) {
        where = 'type = ?';
        whereArgs = [type];
      } else if (yearMonth != null) {
        where = 'record_time LIKE ?';
        whereArgs = ['$yearMonth%'];
      }

      final maps = await db.query(
        'accounting_record',
        where: where,
        whereArgs: whereArgs,
        orderBy: 'record_time DESC, id DESC',
      );
      return maps.map((map) => AccountingRecord.fromMap(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<AccountingRecord?> getAccountingRecordById(int id) async {
    try {
      final db = await database;
      final maps = await db.query(
        'accounting_record',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) return null;
      return AccountingRecord.fromMap(maps.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateAccountingRecord(AccountingRecord record) async {
    try {
      final db = await database;
      return await db.update(
        'accounting_record',
        record.toMap(),
        where: 'id = ?',
        whereArgs: [record.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteAccountingRecord(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'accounting_record',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<double> getMonthlyIncome(String yearMonth) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT SUM(total_amount) as total FROM accounting_record WHERE type = ? AND record_time LIKE ?',
        ['income', '$yearMonth%'],
      );
      return (result.first['total'] as double?) ?? 0.0;
    } catch (e) {
      rethrow;
    }
  }

  Future<double> getMonthlyExpense(String yearMonth) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT SUM(total_amount) as total FROM accounting_record WHERE type = ? AND record_time LIKE ?',
        ['expense', '$yearMonth%'],
      );
      return (result.first['total'] as double?) ?? 0.0;
    } catch (e) {
      rethrow;
    }
  }


  Future<int> insertBudget(Budget budget) async {
    try {
      final db = await database;
      return await db.insert(
        'budget',
        budget.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Budget?> getBudgetByYearMonth(String yearMonth) async {
    try {
      final db = await database;
      final maps = await db.query(
        'budget',
        where: 'year_month = ?',
        whereArgs: [yearMonth],
      );
      if (maps.isEmpty) return null;
      return Budget.fromMap(maps.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateBudget(Budget budget) async {
    try {
      final db = await database;
      return await db.update(
        'budget',
        budget.toMap(),
        where: 'id = ?',
        whereArgs: [budget.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteBudget(int id) async {
    try {
      final db = await database;
      return await db.delete('budget', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }


  Future<int> insertSchedule(Schedule schedule) async {
    try {
      final db = await database;
      return await db.insert('schedule', schedule.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Schedule>> getSchedules({
    String? startDate,
    String? endDate,
    int? isCompleted,
  }) async {
    try {
      final db = await database;
      String? where;
      List<dynamic>? whereArgs = [];

      if (startDate != null && endDate != null && isCompleted != null) {
        where = 'date_time >= ? AND date_time <= ? AND is_completed = ?';
        whereArgs = [startDate, endDate, isCompleted];
      } else if (startDate != null && endDate != null) {
        where = 'date_time >= ? AND date_time <= ?';
        whereArgs = [startDate, endDate];
      } else if (isCompleted != null) {
        where = 'is_completed = ?';
        whereArgs = [isCompleted];
      }

      final maps = await db.query(
        'schedule',
        where: where,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'date_time ASC, id ASC',
      );
      return maps.map((map) => Schedule.fromMap(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Schedule?> getScheduleById(int id) async {
    try {
      final db = await database;
      final maps = await db.query('schedule', where: 'id = ?', whereArgs: [id]);
      if (maps.isEmpty) return null;
      return Schedule.fromMap(maps.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateSchedule(Schedule schedule) async {
    try {
      final db = await database;
      return await db.update(
        'schedule',
        schedule.toMap(),
        where: 'id = ?',
        whereArgs: [schedule.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteSchedule(int id) async {
    try {
      final db = await database;
      return await db.delete('schedule', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> toggleScheduleComplete(int id, int isCompleted) async {
    try {
      final db = await database;
      return await db.update(
        'schedule',
        {'is_completed': isCompleted},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      rethrow;
    }
  }


  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete('handbook');
      await db.delete('notebook');
      await db.delete('diary');
      await db.delete('accounting_record');
      await db.delete('budget');
      await db.delete('schedule');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
