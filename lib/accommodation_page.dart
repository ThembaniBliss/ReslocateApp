import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'house_list_page.dart';

class AccommodationPage extends StatefulWidget {
  final SupabaseClient supabaseClient;

  const AccommodationPage({super.key, required this.supabaseClient});

  @override
  _AccommodationPageState createState() => _AccommodationPageState();
}

class _AccommodationPageState extends State<AccommodationPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> houseListings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAccommodations();
    });
  }

  Future<void> fetchAccommodations() async {
    final response = await supabase.from('HouseListing').select();

    if (response != null && response.error == null) {
      setState(() {
        houseListings = response.data ?? [];
        isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HouseListPage(
            supabaseClient: widget.supabaseClient,
            houseListings: houseListings,
          ),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
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
          ? const Center(child: CircularProgressIndicator())
          : Container(), // Empty container, as the page will navigate away
    );
  }
}
