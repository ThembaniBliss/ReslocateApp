import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HouseListPage extends StatelessWidget {
  final SupabaseClient supabaseClient;
  final List<dynamic> houseListings;

  const HouseListPage(
      {required this.supabaseClient, required this.houseListings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('House Listings'),
      ),
      body: ListView.builder(
        itemCount: houseListings.length,
        itemBuilder: (context, index) {
          final house = houseListings[index];
          return ListTile(
            title: Text(house['location'] ?? 'No location'),
            subtitle: Text('Price: ${house['price'] ?? 'N/A'}'),
          );
        },
      ),
    );
  }
}
