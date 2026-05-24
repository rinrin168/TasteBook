import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/theme.dart';
import 'screens/auth/auth_gateway.dart';
import 'screens/auth/screens/login.dart';
import 'screens/auth/screens/get_started.dart';
import 'screens/auth/screens/signup.dart';
import 'screens/auth/screens/forgot_password.dart';
import 'screens/auth/screens/verify_email.dart';
import 'screens/auth/screens/reset_password.dart';
import 'screens/auth/screens/success.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/library_screen.dart';
import 'screens/home/new_recipe_screen.dart';
import 'screens/home/profile_screen.dart';
import 'screens/home/search_screen.dart';
import 'services/auth_service.dart';
import 'services/recipe_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AuthService.instance.init();
  
  // Seed default recipes if the database is empty
  await RecipeService.instance.seedDefaultRecipes();

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
        '/auth/verify-signup': (context) => const VerifyEmailScreen(),
        '/auth/reset-password': (context) => const ResetPasswordScreen(),
        '/auth/success': (context) => const AuthSuccessScreen(),
        '/home': (context) => const HomeScreen(),
        '/library': (context) => const LibraryScreen(),
        '/new-recipe': (context) => const NewRecipeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/search': (context) => const SearchScreen(),
      },
    );
  }
}
