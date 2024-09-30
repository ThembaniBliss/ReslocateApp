import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';  // Important for decoding JSON

class HouseListPage extends StatefulWidget {
  final SupabaseClient supabaseClient;

  // ignore: use_super_parameters
  const HouseListPage({Key? key, required this.supabaseClient}) : super(key: key);

  @override
  _HouseListPageState createState() => _HouseListPageState();
}

class _HouseListPageState extends State<HouseListPage> {
  List<dynamic> houseListings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHouseListings();
  }

  Future<void> fetchHouseListings() async {
    final response = await widget.supabaseClient
        .from('HouseListing')
        .select('id, name, description, image_url, location, price')
        // ignore: deprecated_member_use
        .execute();

    if (mounted) {
      if (response.status == 200 && response.data != null) {
        setState(() {
          houseListings = response.data as List<dynamic>;
          isLoading = false;
        });
      } else {
        // ignore: avoid_print
        print('Error fetching houses: Status code: ${response.status}');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('House Listings'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : houseListings.isEmpty
              ? const Center(child: Text('No listings available'))
              : ListView.builder(
                  itemCount: houseListings.length,
                  itemBuilder: (context, index) {
                    final house = houseListings[index];
                    return buildHouseCard(house);
                  },
                ),
    );
  }

  Widget buildHouseCard(dynamic house) {
    // Parse the image URLs stored as a JSON array in the database
    List<String> imageUrls = house['image_url'] != null
        ? List<String>.from(json.decode(house['image_url']))  // Decoding JSON array
        : [];

    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Column(
        children: [
          imageUrls.isNotEmpty
              ? Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageUrls.first),  // Displaying the first image
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Text('No Image Available'),
                  ),
                ),
          ListTile(
            title: Text(house['name'] ?? 'Unknown Property'),
            subtitle: Text(
              'Location: ${house['location'] ?? 'Unknown'}, Price: ${house['price'] ?? 'N/A'}',
            ),
            trailing: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
