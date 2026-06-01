import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'controllers/auth_controller.dart';
import 'views/login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ApniLabApp());
}

class ApniLabApp extends StatelessWidget {
  const ApniLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SHAH-RUKH-ALAM LAB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        useMaterial3: true,
      ),
      home: ListenableBuilder(
        listenable: authController,
        builder: (context, _) {
          if (authController.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Colors.teal,
                ),
              ),
            );
          }
          return authController.isLoggedIn 
              ? const MainLayoutScreen() 
              : const LoginView();
        },
      ),
    );
  }
}

