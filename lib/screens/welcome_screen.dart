import 'package:flutter/material.dart';
import 'package:to_do/screens/signin_screen.dart' as signin;
import 'package:to_do/screens/signup_screen.dart' as signup;
import 'package:to_do/theme/theme.dart';
import 'package:to_do/widgets/custom_scaffold.dart';
import 'package:to_do/widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/note.png',
                      width:
                          100, // Genişlik ve yükseklik değerlerini ihtiyacınıza göre ayarlayın
                      height: 100,
                    ),
                    const SizedBox(
                        height:
                            20), // Resim ve yazı arasında boşluk bırakmak için
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                              text: 'TO-DO',
                              style: TextStyle(
                                fontSize: 45.0,
                                fontWeight: FontWeight.w600,
                              )),
                          TextSpan(
                              text: '\nHoş Geldiniz!',
                              style: TextStyle(
                                fontSize: 20,
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Giriş',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const signin.SignInScreen(),
                        ),
                      ),
                      color: Colors.transparent,
                      textColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Kaydol',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const signup.SignUpScreen(),
                        ),
                      ),
                      color: Colors.white,
                      textColor: Color.fromARGB(255, 111, 148, 243),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
