import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert'; // For encoding/decoding JSON
import 'dart:io'; // For handling file operations
import 'package:image_picker/image_picker.dart'; // Image picker for file selection
import 'package:flutter/foundation.dart' show kIsWeb;
import 'main.dart'; // Import the main.dart file to access MyApp

class AddAccommodationPage extends StatefulWidget {
  final Map<String, dynamic>? existingAccommodation;

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
  bool useImageUrl = true; // To toggle between image URL and file upload
  List<XFile>? _selectedImages; // To store selected images

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

      _selectedAmenities = widget.existingAccommodation!['amenities'] != null
          ? List<String>.from(json.decode(widget.existingAccommodation!['amenities']))
          : [];
    }
  }

  // Updated method to allow max of 7 images
  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    // ignore: unnecessary_nullable_for_final_variable_declarations
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null && images.length > 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only select up to 7 images.')),
      );
      return;
    }

    setState(() {
      _selectedImages = images;
    });
  }

  Future<void> addOrUpdateAccommodation() async {
    setState(() {
      isLoading = true;
    });

    if (_nameController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        (useImageUrl && _imageUrlController.text.isEmpty) ||
        (!useImageUrl && (_selectedImages == null || _selectedImages!.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields!')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final Map<String, dynamic> data = {
      'name': _nameController.text,
      'location': _locationController.text,
      'price': int.tryParse(_priceController.text) ?? 0,
      'description': _descriptionController.text,
      'image_url': useImageUrl
          ? _imageUrlController.text
          : _selectedImages?.map((image) => image.path).toList(),
      'amenities': json.encode(_selectedAmenities),
    };

    try {
      // ignore: unused_local_variable
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingAccommodation != null
              ? 'Accommodation updated successfully!'
              : 'Accommodation added successfully!'),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    } on PostgrestException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.message}')),
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
        backgroundColor: Colors.blue, // Blue AppBar
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
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Use Image URL', style: TextStyle(color: Colors.black)),
                      Switch(
                        value: useImageUrl,
                        activeColor: Colors.green, // Green when active
                        onChanged: (bool value) {
                          setState(() {
                            useImageUrl = value;
                          });
                        },
                      ),
                      const Text('Upload Images', style: TextStyle(color: Colors.black)),
                    ],
                  ),

                  useImageUrl
                      ? buildTextField(_imageUrlController, 'Image URL')
                      : Column(
                          children: [
                            ElevatedButton(
                              onPressed: pickImages,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text('Pick Images'),
                            ),
                            _selectedImages != null
                                ? Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: [
                                      ..._selectedImages!.asMap().entries.map((entry) {
                                        final int index = entry.key;
                                        final XFile image = entry.value;
                                        return Stack(
                                          children: [
                                            kIsWeb
                                                ? Image.network(
                                                    image.path,
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.file(
                                                    File(image.path),
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                  ),
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedImages!.removeAt(index);
                                                  });
                                                },
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.green, 
                                                  ),
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: const Icon(
                                                    Icons.close,
                                                    size: 18,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      // ignore: unnecessary_to_list_in_spreads
                                      }).toList(),
                                      GestureDetector(
                                        onTap: pickImages,
                                        child: Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Colors.green, width: 2),
                                            color: Colors.white,
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.add,
                                              size: 30,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text('No images selected'),
                          ],
                        ),

                  const SizedBox(height: 20),

                  const Text('Select Amenities', style: TextStyle(color: Colors.black)),
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
                          onPressed: addOrUpdateAccommodation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: Text(
                            widget.existingAccommodation != null
                                ? 'Update HouseListing'
                                : 'Add HouseListing',
                          ),
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
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
