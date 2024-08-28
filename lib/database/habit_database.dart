import 'package:flutter/material.dart';
import 'package:habbit_tracker/model/app_settings.dart';
import 'package:habbit_tracker/model/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar =
        await Isar.open([HabitSchema, AppSettingsSchema], directory: dir.path);
  }

  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstlaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstlaunchDate;
  }

  final List<Habit> currentHabits = [];

  Future<void> addHabit(String name) async {
    final habit = Habit()..name = name;
    await isar.writeTxn(() => isar.habits.put(habit));
    readHabits();
  }

  Future<void> readHabits() async {
    final fetchedHabits = await isar.habits.where().findAll();

    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);
    notifyListeners();
  }

  Future<void> updateHabitCompletion(int id, bool isComplete) async {
    final habit = await isar.habits.get(id);

    if (habit != null) {
      await isar.writeTxn(() async {
        if (isComplete && !habit.dates.contains(DateTime.now())) {
          habit.dates.add(DateTime.now());
        } else {
          habit.dates.removeWhere((date) =>
              date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day);
        }
        isar.habits.put(habit);
      });
    }
    readHabits();
  }

  Future<void> updateHabitName(int id, String name) async {
    final habit = await isar.habits.get(id);

    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = name;
        await isar.habits.put(habit);
      });
    }
    readHabits();
  }

  Future<void> deleteHabit(Habit habit) async {
    await isar.writeTxn(() => isar.habits.delete(habit.id));
    readHabits();
  }
}
