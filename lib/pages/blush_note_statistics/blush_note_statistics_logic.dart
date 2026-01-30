import 'package:get/get.dart';
import 'package:blush_note/db_blush_note/data.dart';

class StatisticsData {
  final int totalDiaries;
  final int totalWords;
  final int totalHandbooks;
  final double totalIncome;
  final double totalExpense;
  final int expenseRecords;
  final int totalSchedules;
  final int completedSchedules;
  final String mostActiveHour;
  final String commonWeather;

  StatisticsData({
    this.totalDiaries = 0,
    this.totalWords = 0,
    this.totalHandbooks = 0,
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.expenseRecords = 0,
    this.totalSchedules = 0,
    this.completedSchedules = 0,
    this.mostActiveHour = 'N/A',
    this.commonWeather = '',
  });

  StatisticsData copyWith({
    int? totalDiaries,
    int? totalWords,
    int? totalHandbooks,
    double? totalIncome,
    double? totalExpense,
    int? expenseRecords,
    int? totalSchedules,
    int? completedSchedules,
    String? mostActiveHour,
    String? commonWeather,
  }) {
    return StatisticsData(
      totalDiaries: totalDiaries ?? this.totalDiaries,
      totalWords: totalWords ?? this.totalWords,
      totalHandbooks: totalHandbooks ?? this.totalHandbooks,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      expenseRecords: expenseRecords ?? this.expenseRecords,
      totalSchedules: totalSchedules ?? this.totalSchedules,
      completedSchedules: completedSchedules ?? this.completedSchedules,
      mostActiveHour: mostActiveHour ?? this.mostActiveHour,
      commonWeather: commonWeather ?? this.commonWeather,
    );
  }
}

class BlushNoteStatisticsLogic extends GetxController {
  final _db = BlushNoteDatabase();
  
  final isLoading = true.obs;
  final stats = StatisticsData().obs;
  final selectedPeriod = 'month'.obs;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    try {
      isLoading.value = true;

      final dateRange = _getDateRange(selectedPeriod.value);
      final startDate = dateRange['start']!;
      final endDate = dateRange['end']!;

      final results = await Future.wait([
        _loadDiaryStats(startDate, endDate),
        _loadHandbookStats(startDate, endDate),
        _loadAccountingStats(startDate, endDate),
        _loadScheduleStats(startDate, endDate),
      ]);

      stats.value = StatisticsData(
        totalDiaries: results[0]['totalDiaries'] as int,
        totalWords: results[0]['totalWords'] as int,
        mostActiveHour: results[0]['mostActiveHour'] as String,
        commonWeather: results[0]['commonWeather'] as String,
        totalHandbooks: results[1]['totalHandbooks'] as int,
        totalIncome: results[2]['totalIncome'] as double,
        totalExpense: results[2]['totalExpense'] as double,
        expenseRecords: results[2]['expenseRecords'] as int,
        totalSchedules: results[3]['totalSchedules'] as int,
        completedSchedules: results[3]['completedSchedules'] as int,
      );
    } catch (e) {
      print('Error loading statistics: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, String> _getDateRange(String period) {
    final now = DateTime.now();
    String startDate;
    String endDate = now.toIso8601String();

    switch (period) {
      case 'month':
        startDate = DateTime(now.year, now.month, 1).toIso8601String();
        break;
      case '3months':
        startDate = DateTime(now.year, now.month - 2, 1).toIso8601String();
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1).toIso8601String();
        break;
      case 'all':
      default:
        startDate = '2000-01-01T00:00:00.000';
        break;
    }

    return {'start': startDate, 'end': endDate};
  }

  Future<Map<String, dynamic>> _loadDiaryStats(
      String startDate, String endDate) async {
    try {
      final db = await _db.database;
      
      final diaryResult = await db.rawQuery('''
        SELECT COUNT(*) as count, SUM(word_count) as total_words
        FROM diary
        WHERE created_at >= ? AND created_at <= ?
      ''', [startDate, endDate]);

      final totalDiaries = diaryResult.first['count'] as int;
      final totalWords = (diaryResult.first['total_words'] as int?) ?? 0;

      String mostActiveHour = 'N/A';
      if (totalDiaries > 0) {
        final hourResult = await db.rawQuery('''
          SELECT substr(created_at, 12, 2) as hour, COUNT(*) as count
          FROM diary
          WHERE created_at >= ? AND created_at <= ?
          GROUP BY hour
          ORDER BY count DESC
          LIMIT 1
        ''', [startDate, endDate]);

        if (hourResult.isNotEmpty) {
          final hour = hourResult.first['hour'] as String;
          final hourInt = int.tryParse(hour) ?? 0;
          if (hourInt >= 0 && hourInt < 24) {
            if (hourInt < 12) {
              mostActiveHour = '$hourInt AM';
            } else if (hourInt == 12) {
              mostActiveHour = '12 PM';
            } else {
              mostActiveHour = '${hourInt - 12} PM';
            }
          }
        }
      }

      String commonWeather = '';
      final weatherResult = await db.rawQuery('''
        SELECT weather, COUNT(*) as count
        FROM diary
        WHERE created_at >= ? AND created_at <= ? AND weather IS NOT NULL
        GROUP BY weather
        ORDER BY count DESC
        LIMIT 1
      ''', [startDate, endDate]);

      if (weatherResult.isNotEmpty) {
        commonWeather = weatherResult.first['weather'] as String? ?? '';
      }

      return {
        'totalDiaries': totalDiaries,
        'totalWords': totalWords,
        'mostActiveHour': mostActiveHour,
        'commonWeather': commonWeather,
      };
    } catch (e) {
      print('Error loading diary stats: $e');
      return {
        'totalDiaries': 0,
        'totalWords': 0,
        'mostActiveHour': 'N/A',
        'commonWeather': '',
      };
    }
  }

  Future<Map<String, dynamic>> _loadHandbookStats(
      String startDate, String endDate) async {
    try {
      final db = await _db.database;
      
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM handbook
        WHERE created_at >= ? AND created_at <= ?
      ''', [startDate, endDate]);

      return {
        'totalHandbooks': result.first['count'] as int,
      };
    } catch (e) {
      print('Error loading handbook stats: $e');
      return {
        'totalHandbooks': 0,
      };
    }
  }

  Future<Map<String, dynamic>> _loadAccountingStats(
      String startDate, String endDate) async {
    try {
      final db = await _db.database;
      
      final incomeResult = await db.rawQuery('''
        SELECT SUM(total_amount) as total
        FROM accounting_record
        WHERE type = 'income' AND record_time >= ? AND record_time <= ?
      ''', [startDate, endDate]);

      final totalIncome = (incomeResult.first['total'] as double?) ?? 0.0;

      final expenseResult = await db.rawQuery('''
        SELECT SUM(total_amount) as total, COUNT(*) as count
        FROM accounting_record
        WHERE type = 'expense' AND record_time >= ? AND record_time <= ?
      ''', [startDate, endDate]);

      final totalExpense = (expenseResult.first['total'] as double?) ?? 0.0;
      final expenseRecords = (expenseResult.first['count'] as int?) ?? 0;

      return {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'expenseRecords': expenseRecords,
      };
    } catch (e) {
      print('Error loading accounting stats: $e');
      return {
        'totalIncome': 0.0,
        'totalExpense': 0.0,
        'expenseRecords': 0,
      };
    }
  }

  Future<Map<String, dynamic>> _loadScheduleStats(
      String startDate, String endDate) async {
    try {
      final db = await _db.database;
      
      final result = await db.rawQuery('''
        SELECT 
          COUNT(*) as total,
          SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completed
        FROM schedule
        WHERE date_time >= ? AND date_time <= ?
      ''', [startDate, endDate]);

      return {
        'totalSchedules': result.first['total'] as int,
        'completedSchedules': result.first['completed'] as int,
      };
    } catch (e) {
      print('Error loading schedule stats: $e');
      return {
        'totalSchedules': 0,
        'completedSchedules': 0,
      };
    }
  }
}
