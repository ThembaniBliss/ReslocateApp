// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'house_detail_page.dart';
// ignore: unused_import
import 'house_list_page.dart';

class AccommodationPage extends StatefulWidget {
  final SupabaseClient supabaseClient;

  const AccommodationPage({super.key, required this.supabaseClient});

  @override
  _AccommodationPageState createState() => _AccommodationPageState();
}

class _AccommodationPageState extends State<AccommodationPage> {
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
    print('Fetching accommodations from Supabase...');
    final response = await widget.supabaseClient
        .from('HouseListing')
        .select(
            ' name, location, amenities, security, furnish, price, image_url, description'
            // ignore: deprecated_member_use
            )
        // ignore: deprecated_member_use
        .execute();

    // Check the status code to determine if there was an error
    // ignore: unnecessary_null_comparison
    if (response.status != null && response.status >= 400) {
      // Handle the error based on the status code
      print("Error fetching data: Status Code ${response.status}");
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: Status Code ${response.status}'),
      ));
      return; // Exit if there's an error
    }

    // Check if the data is not empty
    if (response.data != null && response.data.isNotEmpty) {
      setState(() {
        houseListings = response.data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        // ignore: unnecessary_const
        content: const Text('No accommodations found'),
      ));
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
          : houseListings.isEmpty
              ? const Center(child: Text('No accommodations found'))
              : ListView.builder(
                  itemCount: houseListings.length,
                  itemBuilder: (context, index) {
                    final house = houseListings[index];
                    return ListTile(
                      leading: house['image_url'] != null
                          ? Image.network(house['image_url'])
                          : const Icon(Icons.home),
                      title: Text(house['name'] ?? 'Unknown Name'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Location: ${house['location'] ?? 'Unknown Location'}'),
                          Text('Price: ${house['price'] ?? 'N/A'}'),
                          Text(
                              'Amenities: ${house['amenities'] ?? 'Not specified'}'),
                          Text(
                              'Security: ${house['security'] ?? 'Not specified'}'),
                          Text(
                              'Furnish: ${house['furnish'] ?? 'Not specified'}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HouseDetailPage(
                                house: house,
                              ),
                            ),
                          );
                        },
                      ),
                      isThreeLine: true,
                    );
                  },
                ),
    );
  }
}
