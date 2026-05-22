import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/theme.dart';
import 'screens/auth/main.dart';
import 'screens/auth/screens/login.dart';
import 'screens/auth/screens/get_started.dart';
import 'screens/auth/screens/signup.dart';
import 'screens/auth/screens/forgot_password.dart';
import 'screens/auth/screens/verify_code.dart';
import 'screens/auth/screens/reset_password.dart';
import 'screens/auth/screens/success.dart';
import 'screens/home/home_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AuthService.instance.init();
  final initialRoute = AuthService.instance.isSignedIn
      ? '/home'
      : '/auth/get-started';
  runApp(TasteBookApp(initialRoute: initialRoute));
}

class TasteBookApp extends StatelessWidget {
  const TasteBookApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TasteBook',
      theme: appTheme(),
      initialRoute: initialRoute,
      routes: {
        '/auth': (context) => const AuthGateway(),
        '/auth/login': (context) => const LoginScreen(),
        '/auth/get-started': (context) => const GetStartedScreen(),
        '/auth/signup': (context) => const SignUpScreen(),
        '/auth/forgot-password': (context) => const ForgotPasswordScreen(),
        '/auth/verify-signup': (context) => const VerifyCodeScreen(
          title: 'Get Verification Code',
          description:
              'We\'ve sent a verification code to your email address. Enter the code below to verify your identity and continue.',
          confirmLabel: 'Confirm',
          onConfirmedRoute: '/auth/success',
        ),
        '/auth/verify-reset': (context) => const VerifyCodeScreen(
          title: 'Get Verification Code',
          description:
              'We\'ve sent a reset code to your email address. Enter the code below to verify your identity and continue.',
          confirmLabel: 'Confirm',
          onConfirmedRoute: '/auth/reset-password',
        ),
        '/auth/reset-password': (context) => const ResetPasswordScreen(),
        '/auth/success': (context) => const AuthSuccessScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
