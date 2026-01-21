import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// 🔐 GOOGLE LOGIN (LOGIN-ONLY)
  static Future<UserCredential?> signInWithGoogleLoginOnly() async {
    try {
      /// Clear previous session
      await _googleSignIn.signOut();

      /// 1️⃣ Pick Google account
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // user cancelled
      }

      /// 2️⃣ Get auth tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      /// 3️⃣ Create Firebase credential
      final OAuthCredential credential =
          GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      /// 4️⃣ TEMP SIGN-IN
      final UserCredential userCredential =
          await FirebaseAuth.instance
              .signInWithCredential(credential);

      final User user = userCredential.user!;

      /// 5️⃣ CHECK IF USER EXISTS IN FIRESTORE
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        /// 🚫 USER DOES NOT EXIST → BLOCK LOGIN
        await signOut();
        throw FirebaseAuthException(
          code: 'user-not-registered',
          message:
              'Account not found. Please sign up using email & password.',
        );
      }

      /// ✅ USER EXISTS → ALLOW LOGIN
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  /// 🚪 FULL LOGOUT
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }
}
