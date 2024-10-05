import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vaccination/components/admin_navbar.dart';
import 'package:vaccination/pages/admin_home.dart';
import 'package:vaccination/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import 'database.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return  auth.currentUser;
  }

  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication? googleSignInAuthentication = await googleSignInAccount?.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken);

    UserCredential result = await firebaseAuth.signInWithCredential(credential);
    User? userDetails = result.user;

    if (userDetails != null) {
      // Fetch the user's role from Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("User")
          .doc(userDetails.uid)
          .get();

      // Check if the user already exists in Firestore
      if (!userSnapshot.exists) {
        // If user doesn't exist, add as a regular user
        Map<String, dynamic> userInfoMap = {
          "email": userDetails.email,
          "name": userDetails.displayName,
          "imgUrl": userDetails.photoURL,
          "id": userDetails.uid,
          "role": "user"  // Default to user
        };

        await DatabaseMethods().addUser(userDetails.uid, userInfoMap);

        // Redirect to user home page by default
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      } else {
        // If user exists, retrieve their role
        String role = userSnapshot.get('role');

        // Print or log role for debugging
        print("User role: $role");

        // Navigate based on role
        if (role == 'admin') {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => AdminHomePage()));
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Home()));
        }
      }
    } else {
      // Handle sign-in failure (add appropriate error handling)
      print("Google sign-in failed.");
    }
  }




  Future<User> signInWithApple({List<Scope> scopes = const []}) async {
    final result = await TheAppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final AppleIdCredential = result.credential!;
        final oAuthCredential = OAuthProvider('apple.com');
        final credential = oAuthCredential.credential(
            idToken: String.fromCharCodes(AppleIdCredential.identityToken!));
        final UserCredential = await auth.signInWithCredential(credential);
        final firebaseUser = UserCredential.user!;
        if (scopes.contains(Scope.fullName)) {
          final fullName = AppleIdCredential.fullName;
          if (fullName != null &&
              fullName.givenName != null &&
              fullName.familyName != null) {
            final displayName = '${fullName.givenName}${fullName.familyName}';
            await firebaseUser.updateDisplayName(displayName);
          }
        }
        return firebaseUser;
      case AuthorizationStatus.error:
        throw PlatformException(
            code: 'ERROR_AUTHORIZATION_DENIED',
            message: result.error.toString());

      case AuthorizationStatus.cancelled:
        throw PlatformException(
            code: 'ERROR_ABORTED_BY_USER', message: 'Sign in aborted by user');
      default:
        throw UnimplementedError();
    }
  }
}