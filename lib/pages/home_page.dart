import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habbit_tracker/components/drawer.dart';
import 'package:habbit_tracker/components/habit_tile.dart';
import 'package:habbit_tracker/components/heat_map.dart';
import 'package:habbit_tracker/database/habit_database.dart';
import 'package:habbit_tracker/model/habit.dart';
import 'package:habbit_tracker/themes/theme_provider.dart';
import 'package:provider/provider.dart';

import '../util/habit_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  final TextEditingController _habitController = TextEditingController();

  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            controller: _habitController,
          ),
          title: const Text('New Habit'),
          actions: [
            MaterialButton(
              onPressed: () {
                String habitName = _habitController.text;
                context.read<HabitDatabase>().addHabit(habitName);

                Navigator.of(context).pop();

                _habitController.clear();
              },
              child: const Text('Create'),
            ),
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void checkHabitOnOff(bool? value, Habit habit) {
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  void editHabit(Habit habit) {
    _habitController.text = habit.name;

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextField(
              controller: _habitController,
            ),
            title: const Text('Edit Habit'),
            actions: [
              MaterialButton(
                onPressed: () {
                  String habitName = _habitController.text;
                  context
                      .read<HabitDatabase>()
                      .updateHabitName(habit.id, habitName);

                  Navigator.of(context).pop();

                  _habitController.clear();
                },
                child: const Text('Save'),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        });
  }

  void deleteHabit(Habit habit) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete Habit'),
            actions: [
              MaterialButton(
                onPressed: () {
                  context.read<HabitDatabase>().deleteHabit(habit);

                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        drawer: MyDrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewHabit,
          child: const Icon(Icons.add),
        ),
        body: ListView(children: [_buildHeatMap(), _buildHabitList()]));
  }

  Widget _buildHabitList() {
    final habitDatabase = context.watch<HabitDatabase>();

    List<Habit> habits = habitDatabase.currentHabits;

    return ListView.builder(
        itemCount: habits.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          Habit habit = habits[index];
          bool isHabitCompleted = isCompletedToday(habit.dates);
          return HabitTile(
            text: habit.name,
            isCompleted: isHabitCompleted,
            onChanged: (value) => checkHabitOnOff(value, habit),
            editHabit: (context) => editHabit(habit),
            deleteHabit: (context) => deleteHabit(habit),
          );
        });
  }

  Widget _buildHeatMap() {
    final habitDatabase = context.watch<HabitDatabase>();

    List<Habit> habits = habitDatabase.currentHabits;

    return FutureBuilder<DateTime?>(
        future: habitDatabase.getFirstLaunchDate(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MyHeatMap(startDate: snapshot.data!, datasets: prepHeatMapDataset(habits));
          } else {
            return const SizedBox();
          }
        });
  }
}
