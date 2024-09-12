// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ignore: use_key_in_widget_constructors
class AddAccommodationPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _AddAccommodationPageState createState() => _AddAccommodationPageState();
}

class _AddAccommodationPageState extends State<AddAccommodationPage> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  Future<void> addAccommodation() async {
    final response =
        await Supabase.instance.client.from('accommodations').insert({
      'location': _locationController.text,
      'price': int.parse(_priceController.text),
      'description': _descriptionController.text,
      'image_url': _imageUrlController.text,
    })
            // ignore: deprecated_member_use
            .execute();

    if (response != null) {
      Navigator.pop(context); // Return to the accommodation list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Accommodation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: addAccommodation,
                child: const Text('Add Accommodation')),
          ],
        ),
      ),
    );
  }
}
