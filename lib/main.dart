import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:to_do/screens/signin_screen.dart';
import 'package:to_do/screens/welcome_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      // Rota tanımlamaları burada yapılır
      routes: {
        '/signin': (context) => const SignInScreen(),
        // Diğer rotalarınızı burada tanımlayın
      },
      // Varsayılan olarak gösterilecek ekran
      home: const WelcomeScreen(),
    );
  }
}
