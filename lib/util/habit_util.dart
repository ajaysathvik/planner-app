import '../model/habit.dart';

bool isCompletedToday(List<DateTime> completedDates) {
  DateTime now = DateTime.now();
  return completedDates.any((date) {
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  });
}

Map<DateTime, int> prepHeatMapDataset(List<Habit> habits) {
  Map<DateTime, int> data = {};

  for (var habit in habits) {
    for (var date in habit.dates) {
      final key = DateTime(date.year, date.month, date.day);

      if (data.containsKey(key)) {
        data[key] = data[key]! + 1;
      } else {
        data[key] = 1;
      }
    }
  }

  return data;
}
