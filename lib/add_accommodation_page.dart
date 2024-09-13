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
      _locationController.text =
          widget.existingAccommodation!['location'] ?? '';
      _priceController.text =
          widget.existingAccommodation!['price']?.toString() ?? '';
      _descriptionController.text =
          widget.existingAccommodation!['description'] ?? '';
      _imageUrlController.text =
          widget.existingAccommodation!['image_url'] ?? '';
      _amenitiesController.text =
          widget.existingAccommodation!['amenities'] ?? '';
      _securityController.text =
          widget.existingAccommodation!['security'] ?? '';
      _furnishController.text = widget.existingAccommodation!['furnish'] ?? '';
    }
  }

  Future<void> addOrUpdateAccommodation() async {
    setState(() {
      isLoading = true;
    });

    final Map<String, dynamic> data = {
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
            SnackBar(content: Text('Error: ${response.error.message}')));
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location')),
            TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number),
            TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description')),
            TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL')),
            TextField(
                controller: _amenitiesController,
                decoration: const InputDecoration(labelText: 'Amenities')),
            TextField(
                controller: _securityController,
                decoration: const InputDecoration(labelText: 'Security')),
            TextField(
                controller: _furnishController,
                decoration: const InputDecoration(labelText: 'Furnish')),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: addOrUpdateAccommodation,
                    child: Text(widget.existingAccommodation != null
                        ? 'Update HouseListing'
                        : 'Add HouseListing')),
          ],
        ),
      ),
    );
  }
}
