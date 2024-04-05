import 'package:flutter/material.dart';
import 'package:hsindongyang/home_page.dart';
import 'package:hsindongyang/image_selection.dart';
import 'package:hsindongyang/photo_api.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => PhotoApi()),
    ChangeNotifierProvider(create: (_) => ImageSelection())
  ], child: const App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Namer App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const HomePage(),
    );
  }
}
