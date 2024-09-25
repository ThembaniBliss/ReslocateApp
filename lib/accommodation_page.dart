// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ignore: unused_import
import 'house_detail_page.dart';
// ignore: unused_import
import 'house_list_page.dart';
import 'binterest_form_page.dart';

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
            ' name, location, amenities, security, furnish, price, image_url, description')
        // ignore: deprecated_member_use
        .execute();

    // ignore: unnecessary_null_comparison
    if (response.status != null && response.status >= 400) {
      print("Error fetching data: Status Code ${response.status}");
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: Status Code ${response.status}'),
      ));
      return;
    }

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
        content: Text('No accommodations found'),
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
                    return Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image section
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: house['image_url'] != null
                                  ? Image.network(
                                      house['image_url'],
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.home, size: 100),
                            ),
                            const SizedBox(height: 10),

                            // Details section
                            Text(
                              house['name'] ?? 'Unknown Name',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Location: ${house['location'] ?? 'Unknown Location'}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Price: ${house['price'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                               ElevatedButton(
                              onPressed: () {
                             Navigator.push(
                             context,
                           MaterialPageRoute(
                          builder: (context) => InterestFormPage(
                           house: house,
                                       ),
                                      ),
                                      );
                                     },
                        child: const Text('Are you Interested?'),
                            ),
                            ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
