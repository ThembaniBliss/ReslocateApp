import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final TextEditingController _amenitiesController = TextEditingController();
  final TextEditingController _securityController = TextEditingController();
  final TextEditingController _furnishController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingAccommodation != null) {
       _nameController.text = widget.existingAccommodation!['name'] ?? '';
      _locationController.text = widget.existingAccommodation!['location'] ?? '';
      _priceController.text =
          widget.existingAccommodation!['price']?.toString() ?? '';
      _descriptionController.text =
          widget.existingAccommodation!['description'] ?? '';
      _imageUrlController.text = widget.existingAccommodation!['image_url'] ?? '';
      _amenitiesController.text = widget.existingAccommodation!['amenities'] ?? '';
      _securityController.text = widget.existingAccommodation!['security'] ?? '';
      _furnishController.text = widget.existingAccommodation!['furnish'] ?? '';
    }
  }

  Future<void> addOrUpdateAccommodation() async {
    setState(() {
      isLoading = true;
    });

    final Map<String, dynamic> data = {
      'name':_nameController.text,
      'location': _locationController.text,
      'price': int.parse(_priceController.text),
      'description': _descriptionController.text,
      'image_url': _imageUrlController.text,
      'amenities': _amenitiesController.text,
      'security': _securityController.text,
      'furnish': _furnishController.text,
    };

    try {
      final response = widget.existingAccommodation != null
          ? await Supabase.instance.client
              .from('HouseListing')
              .update(data)
              .eq('id', widget.existingAccommodation!['id'])
          : await Supabase.instance.client.from('HouseListing').insert(data);

      if (response.error != null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.error!.message}')));
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
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
                  buildTextField(_locationController, 'name'),
                  buildTextField(_locationController, 'Location'),
                  buildTextField(_priceController, 'Price', keyboardType: TextInputType.number),
                  buildTextField(_descriptionController, 'Description'),
                  buildTextField(_imageUrlController, 'Image URL'),
                  buildTextField(_amenitiesController, 'Amenities'),
                  buildTextField(_securityController, 'Security'),
                  buildTextField(_furnishController, 'Furnish'),
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
