import 'package:flutter/material.dart';
import 'package:sticky_list/screens/home.dart';
import 'package:sticky_list/services/injection_service.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      InjectionService.setupInjection(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        extendBody: true,
        body: SafeArea(
          child: Home(),
        ),
      ),
    );
  }
}
