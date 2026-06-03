import 'package:club_matcher/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async'; // <--- Make sure this is at the top of your file! 
import 'dart:io'; // Needed for File visual checking on mobile 
import 'package:flutter/foundation.dart'; // Needed for kIsWeb check 
import 'dart:typed_data'; // Needed for Uint8List 


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

await Supabase.initialize(
url: 'https://amjjeuyusqbodndujmph.supabase.co',
anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFtampldXl1c3Fib2RuZHVqbXBoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1Mzg2OTksImV4cCI6MjA5NDExNDY5OX0.wNuLnJ0G6srRyIm2lF4wfZNMIUFr5_rHz8rclawVXL8',
);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: HomePage()
    );
  }
}
