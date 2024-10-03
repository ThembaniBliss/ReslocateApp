// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert'; // For encoding/decoding JSON

import 'main.dart'; // Import the main.dart file to access MyApp

class AddAccommodationPage extends StatefulWidget {
  final Map<String, dynamic>? existingAccommodation; // For updating

  // ignore: use_super_parameters
  const AddAccommodationPage({Key? key, this.existingAccommodation})
      : super(key: key);

  @override
  _AddAccommodationPageState createState() => _AddAccommodationPageState();
}

class _AddAccommodationPageState extends State<AddAccommodationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  bool isLoading = false;

  // List of amenities
  final List<String> _amenities = [
    'Gym',
    'Swimming Pool',
    'Free WiFi',
    'Security',
    'Backup Water',
    '24/hr Security',
    'Student Life Support',
    'Computer Labs',
    'Laundry Facilities',
    'Games Room',
    'Access Control',
    'Study Hubs',
    'CCTV',
    'Braai Facilities',
    'Laundry',
    'Study Rooms',
    'Societies',
    'Maintenance App',
    'Events',
    'TV Rooms',
    'Biometric Access',
    'Free Transport to Uni',
    'Smart Access (Card or Smartphone)',
    'Facial Recognition',
    'Room Access (Smart Access)',
    'Room Access (Padlock)',
    'Rooftop Recreational Area'
  ];

  // Selected amenities
  List<String> _selectedAmenities = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingAccommodation != null) {
      _nameController.text = widget.existingAccommodation!['name'] ?? '';
      _locationController.text = widget.existingAccommodation!['location'] ?? '';
      _priceController.text = widget.existingAccommodation!['price']?.toString() ?? '';
      _descriptionController.text = widget.existingAccommodation!['description'] ?? '';
      _imageUrlController.text = widget.existingAccommodation!['image_url'] ?? '';

      // Decode the JSON string into a list for selected amenities
      _selectedAmenities = widget.existingAccommodation!['amenities'] != null
          ? List<String>.from(json.decode(widget.existingAccommodation!['amenities']))
          : [];
    }
  }

  Future<void> addOrUpdateAccommodation() async {
    setState(() {
      isLoading = true;
    });

    // Validate fields before submission
    if (_nameController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields!')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Prepare data for insertion/update
    final Map<String, dynamic> data = {
      'name': _nameController.text,
      'location': _locationController.text,
      'price': int.tryParse(_priceController.text) ?? 0,
      'description': _descriptionController.text,
      'image_url': _imageUrlController.text,
      'amenities': json.encode(_selectedAmenities), // Encode the selected amenities as JSON
    };

    try {
      final response = widget.existingAccommodation != null
          ? await Supabase.instance.client
              .from('HouseListing')
              .update(data)
              .eq('id', widget.existingAccommodation!['id'])
              .select()
          : await Supabase.instance.client
              .from('HouseListing')
              .insert(data)
              .select();

      if (response.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unexpected response format.')),
        );
      } else {
        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingAccommodation != null
                ? 'Accommodation updated successfully!'
                : 'Accommodation added successfully!'),
          ),
        );

        // Delay for 1 second to allow the message to show
        await Future.delayed(const Duration(seconds: 1));

        // Navigate back to the main page (MyApp)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyApp()), // Navigate to the main MyApp page
        );
      }
    } on PostgrestException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingAccommodation != null
            ? 'Update HouseListing'
            : 'Add HouseListing'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 5,
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildTextField(_nameController, 'Name'),
                  buildTextField(_locationController, 'Location'),
                  buildTextField(_priceController, 'Price', keyboardType: TextInputType.number),
                  buildTextField(_descriptionController, 'Description'),
                  buildTextField(_imageUrlController, 'Image URL'),
                  const SizedBox(height: 20),

                  // Amenity Picker
                  const SizedBox(height: 20),
                  const Text('Select Amenities'),
                  Wrap(
                    children: _amenities.map((amenity) {
                      return FilterChip(
                        label: Text(amenity),
                        selected: _selectedAmenities.contains(amenity),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedAmenities.add(amenity);
                            } else {
                              _selectedAmenities.remove(amenity);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 20),
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: addOrUpdateAccommodation,
                          child: Text(widget.existingAccommodation != null
                              ? 'Update HouseListing'
                              : 'Add HouseListing'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String labelText,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }
}
