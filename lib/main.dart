import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'category_page.dart';
import 'profile.dart';
import 'settings.dart';
import 'register.dart';
import 'package:to_do/screens/welcome_screen.dart';
import 'package:to_do/theme/theme.dart';

void main() {
  runApp(const Deneme());
}

class Deneme extends StatelessWidget {
  const Deneme({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uygulama',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomeScreen(),
    );
  }
}
