import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Email ve Parola ile Kayıt Olma Metodu
  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return user;
    } on FirebaseAuthException catch (e) {
      print("Hata: ${e.message}");
      return null;
    } catch (e) {
      print("Bilinmeyen Hata: $e");
      return null;
    }
  }

  // Email ve Parola ile Giriş Yapma Metodu
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return user;
    } on FirebaseAuthException catch (e) {
      print("Hata: ${e.message}");
      return null;
    } catch (e) {
      print("Bilinmeyen Hata: $e");
      return null;
    }
  }

  // Oturum Kapatma Metodu
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
