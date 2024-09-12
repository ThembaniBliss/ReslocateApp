// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'house_list_page.dart'; // Import your house list page

class AccommodationPage extends StatefulWidget {
  final SupabaseClient
      supabaseClient; // Supabase client to pass into the constructor

  const AccommodationPage({super.key, required this.supabaseClient});

  @override
  _AccommodationPageState createState() => _AccommodationPageState();
}

class _AccommodationPageState extends State<AccommodationPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> houseListings =
      []; // changed to camelCase to follow Dart conventions
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch data when the page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAccommodations();
    });
  }

  Future<void> fetchAccommodations() async {
    final response = await supabase.from('HouseListing').select();

    if (response != null && response.error == null) {
      setState(() {
        houseListings =
            response.data ?? []; // Ensure the data is assigned properly
        isLoading = false; // Stop showing the loader
      });
      // Navigate to the HouseListPage with the loaded data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HouseListPage(
            supabaseClient: widget.supabaseClient, // Pass the Supabase client
            houseListings: houseListings, // Pass the fetched house listings
          ),
        ),
      );
    } else {
      // Handle error or no data available
      setState(() {
        isLoading = false; // Stop loading in case of an error
      });
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error fetching data or no data available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accommodation Providers'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(), // Show loading spinner
            )
          : Container(), // Empty container, as the page will navigate away on load
    );
  }
}
