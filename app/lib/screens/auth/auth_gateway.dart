import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import 'screens/get_started.dart';

class AuthGateway extends StatelessWidget {
  const AuthGateway({super.key});

  @override
  Widget build(BuildContext context) {
    if (AuthService.instance.isSignedIn) {
      return const HomeScreen();
    } else {
      return const GetStartedScreen();
    }
  }
}
