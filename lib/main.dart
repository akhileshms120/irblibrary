import 'package:flutter/material.dart';
import 'package:lovable_library/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase with environment variables for production
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL', 
      defaultValue: 'https://eiposhexdebpdkfmdrxd.supabase.co'), // Your Supabase URL
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', 
      defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVpcG9zaGV4ZGVicGRrZm1kcnhkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTExMTM0MDcsImV4cCI6MjA2NjY4OTQwN30.l6AXl3MJDyP8vqTopJcxqyejlBWbTWKuat8rSv1rypw'), // Your Supabase anon key
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lovable Library',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BorrowFormScreen(),
    );
  }
}




