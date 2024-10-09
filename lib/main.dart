import 'package:flutter/material.dart';
import 'package:reslocate_house_listing/house_list_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'accommodation_page.dart';
import 'add_accommodation_page.dart';
import 'auth_service.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://sjqlnrztidffvuapbijf.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqcWxucnp0aWRmZnZ1YXBiaWpmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjc0MjY1ODEsImV4cCI6MjA0MzAwMjU4MX0.VPRwCLYdj3H3axMwLVsjFLaKOGzaJJftpDH-Ae-KLKI',
    );

    // ignore: avoid_print
    print('Supabase Initialized');
  } catch (e) {
    // ignore: avoid_print
    print('Supabase Initialization Error: $e');
  }

  runApp(MyApp());
}

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
      home: FutureBuilder(
        future: checkUserAuthentication(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          } else {
            return snapshot.data == true ? MainPage() : LoginPage();
          }
        },
      ),
    );
  }

  Future<bool> checkUserAuthentication() async {
    final AuthService authService = AuthService();
    final user = authService.currentUser;

    return user != null;
  }
}

// ignore: use_key_in_widget_constructors
class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
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
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                final currentUser = Supabase.instance.client.auth.currentUser;
                if (currentUser != null) {
                  // ignore: avoid_print
                  print('User is authenticated: ${currentUser.email}');
                  // ignore: avoid_print
                  print('User ID: ${currentUser.id}');
                } else {
                  // ignore: avoid_print
                  print('No authenticated user found');
                }
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            AccommodationPage(supabaseClient: Supabase.instance.client), // Accommodations Page
            HouseListPage(
                supabaseClient: Supabase.instance.client, houseListings: const []), // House Listings Page
            const AddAccommodationPage(), // Add New Accommodation Page
          ],
        ),
      ),
    );
  }
}
