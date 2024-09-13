import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HouseListPage extends StatelessWidget {
  final SupabaseClient supabaseClient;
  final List<dynamic> houseListings;

  // ignore: use_super_parameters
  const HouseListPage(
      {Key? key, required this.supabaseClient, required this.houseListings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('House Listings'),
      ),
      body: houseListings.isEmpty
          ? const Center(child: Text('No listings available'))
          : ListView.builder(
              itemCount: houseListings.length,
              itemBuilder: (context, index) {
                final house = houseListings[index];
                return Card(
                  // Using Card for better UI presentation
                  elevation: 2.0,
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: house['image_url'] != null
                        ? Image.network(house['image_url'],
                            width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.house, size: 50),
                    title: Text(house['name'] ?? 'Unknown Property',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Location: ${house['location'] ?? 'Unknown Location'}'),
                        Text('Price: ${house['price'] ?? 'Not Available'}'),
                        if (house['amenities'] != null)
                          Text('Amenities: ${house['amenities']}'),
                        if (house['security'] != null)
                          Text('Security: ${house['security']}'),
                        if (house['furnish'] != null)
                          Text('Furnish: ${house['furnish']}'),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(house['name'] ?? 'Property Details'),
                            content: Text(
                                'This is more detailed information about ${house['name'] ?? 'the property'}.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
