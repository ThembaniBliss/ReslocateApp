import 'package:flutter/material.dart';
import 'package:reslocate_house_listing/house_list_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'accommodation_page.dart';
import 'add_accommodation_page.dart';
import 'auth_service.dart';
import 'login_page.dart';

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

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    // Check if the user is logged in
    final user = authService.currentUser;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Accommodation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: user == null
          ? LoginPage()
          : DefaultTabController(
              length: 3,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Accommodation App'),
                  bottom: const TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.home), text: 'Accommodations'),
                      Tab(icon: Icon(Icons.list), text: 'Listings'),
                      Tab(icon: Icon(Icons.add), text: 'Add New'),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    AccommodationPage(
                        supabaseClient:
                            Supabase.instance.client), // Accommodations Page
                    HouseListPage(
                        supabaseClient: Supabase.instance.client,
                        houseListings: const []), // House Listings Page
                    const AddAccommodationPage(), // Add New Accommodation Page
                  ],
                ),
              ),
            ),
    );
  }
}
