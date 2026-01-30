import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

export 'file_helper.dart';

void successToast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.green,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

void errorToast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

String getDateString(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String extractDateFromDateTime(String dateTimeString) {
  if (dateTimeString.contains(' ')) {
    return dateTimeString.split(' ')[0];
  }
  return dateTimeString;
}

String formatAmount(double amount) {
  return amount.toStringAsFixed(2);
}

String getYearMonth(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}';
}

DateTime parseYearMonth(String yearMonth) {
  final parts = yearMonth.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
}

Map<String, List<T>> groupByDate<T>(
  List<T> items,
  String Function(T) getDate,
) {
  final Map<String, List<T>> grouped = {};
  for (var item in items) {
    final date = getDate(item);
    if (!grouped.containsKey(date)) {
      grouped[date] = [];
    }
    grouped[date]!.add(item);
  }
  return grouped;
}

String formatDateDisplay(DateTime date) {
  return DateFormat('MMMM d').format(date);
}

String formatDateWithWeekday(DateTime date) {
  return DateFormat('MMMM d, EEEE').format(date);
}

String formatYearMonthDisplay(String yearMonth) {
  final date = parseYearMonth(yearMonth);
  return DateFormat('MMMM').format(date);
}
