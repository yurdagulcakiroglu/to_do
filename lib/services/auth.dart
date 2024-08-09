import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Email ve Parola ile Kayıt Olma Metodu
  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        await user.sendEmailVerification();
        return user;
      } else {
        return null;
      }
    } on FirebaseAuthException catch (e) {
      print("Hata: ${e.message}");
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage =
            'Parola çok zayıf. Lütfen daha güçlü bir parola kullanın.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Bu e-posta adresi zaten kullanımda.';
      } else {
        errorMessage = 'Kayıt işlemi sırasında bir hata oluştu: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      print("Bilinmeyen Hata: $e");
      throw Exception('Kayıt işlemi sırasında bir hata oluştu.');
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

      if (user != null) {
        if (user.emailVerified) {
          return user;
        } else {
          await user.sendEmailVerification();
          throw FirebaseAuthException(
            code: 'email-not-verified',
            message: 'Email adresinizi doğrulamanız gerekiyor.',
          );
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print("Hata: ${e.message}");
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'Bu e-posta adresine sahip bir kullanıcı bulunamadı.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Yanlış parola.';
      } else {
        errorMessage = 'Giriş işlemi sırasında bir hata oluştu: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      print("Bilinmeyen Hata: $e");
      throw Exception('Giriş işlemi sırasında bir hata oluştu.');
    }
  }

  // Oturum Kapatma Metodu
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Google ile Giriş Yapma Metodu
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Kullanıcı giriş işlemini iptal etti
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken:
            googleAuth.accessToken, // Google API'lerine erişim sağlamak için
        idToken: googleAuth
            .idToken, // Google tarafından verilen ve kullanıcının kimliğini doğrulayan belirteçtir. Jwt
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Google ile giriş işlemi sırasında hata oluştu: $e");
      throw Exception('Google ile giriş işlemi sırasında bir hata oluştu.');
    }
  }
}
