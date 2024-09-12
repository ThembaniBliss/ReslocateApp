import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'accommodation_page.dart';
import 'auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://xwmqsrjexxstflprjzub.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh3bXFzcmpleHhzdGZscHJqenViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjYwNDQxOTMsImV4cCI6MjA0MTYyMDE5M30.R5NjxZcI91aTwLlIlU7EiJnyjQvKpKNm_zYn5A4V6ms',
  );

  runApp(MyApp());
}

final AuthService authService = AuthService();

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Accommodation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AccommodationPage(),
    );
  }
}
