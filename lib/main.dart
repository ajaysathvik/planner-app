import 'package:flutter/material.dart';
import 'package:habbit_tracker/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'database/habit_database.dart';
import 'pages/home_page.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await HabitDatabase.init();
  await HabitDatabase().saveFirstLaunchDate();

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => HabitDatabase()),
      ChangeNotifierProvider(create: (context) => ThemeProvider()),
    ], child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
