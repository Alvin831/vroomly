import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './screens/login_screen.dart';
import './screens/home_screen.dart';
import './screens/register_screen.dart';
import './screens/main_screen.dart';
import './screens/history_screen.dart';
import './screens/profile_screen.dart';
import './screens/add_vehicle_screen.dart';

void main() {
  runApp(AplikasiPengingatServis());
}

class AplikasiPengingatServis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vroomly',
      theme: ThemeData(
        primaryColor: Color(0xFF2F3032),
        scaffoldBackgroundColor: Color(0xFFEDE68A),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey,
        ).copyWith(
          secondary: Color(0xFF383A56),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.poppins(
            fontSize: 28.0,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2F3032),
          ),
          headlineMedium: GoogleFonts.poppins(
            fontSize: 22.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F3032),
          ),
          bodyLarge: GoogleFonts.poppins(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2F3032),
          ),
          bodyMedium: GoogleFonts.robotoMono(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            color: Color(0xFF383A56),
          ),
          labelLarge: GoogleFonts.poppins(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F3032),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFB0A565),
            foregroundColor: Color(0xFF2F3032),
            textStyle: GoogleFonts.poppins(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIconColor: Color(0xFF383A56),
          hintStyle: GoogleFonts.robotoMono(
            color: Color(0xFF383A56),
            fontSize: 14.0,
          ),
          labelStyle: GoogleFonts.poppins(
            color: Color(0xFF2F3032),
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 22.0,
            fontWeight: FontWeight.w700,
            color: Color(0xFFEDE68A),
          ),
        ),
      ),
      home: LayarLogin(),
    );
  }
}