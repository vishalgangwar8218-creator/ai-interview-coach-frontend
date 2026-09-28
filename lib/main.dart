import 'package:ai_interview_coach/views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'views/home_screen.dart';

void main() {
  runApp(const AiInterviewCoachApp());
}

class AiInterviewCoachApp extends StatelessWidget {
  const AiInterviewCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Interview Coach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
