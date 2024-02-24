import "package:activ8/view/entry_point.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Activ8",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData(brightness: Brightness.dark).textTheme).copyWith(
          bodyMedium: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
          ),
          headlineLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        useMaterial3: true,
      ),
      home: const EntryPoint(),
    );
  }
}
