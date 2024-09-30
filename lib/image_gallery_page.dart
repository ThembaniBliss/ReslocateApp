import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageGalleryPage extends StatefulWidget {
  final int houseId;

  // ignore: use_super_parameters
  const ImageGalleryPage({Key? key, required this.houseId}) : super(key: key);

  @override
  _ImageGalleryPageState createState() => _ImageGalleryPageState();
}

class _ImageGalleryPageState extends State<ImageGalleryPage> {
  final SupabaseClient client = SupabaseClient(
      'https://xwmqsrjexxstflprjzub.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh3bXFzcmpleHhzdGZscHJqenViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjYwNDQxOTMsImV4cCI6MjA0MTYyMDE5M30.R5NjxZcI91aTwLlIlU7EiJnyjQvKpKNm_zYn5A4V6ms');
  List<String> imageUrls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchImageUrls();
  }

Future<void> fetchImageUrls() async {
  try {
    // Perform the query
    final response = await client
        .from('HouseListing')
        .select('image_url')
        .eq('id', widget.houseId)
        .single(); // Adjust if necessary based on the returned type

    // Safely access the response data
    final data = response.data;

    if (data != null && data['image_url'] != null && data['image_url'].isNotEmpty) {
      // Check if it's a valid JSON before decoding
      try {
        imageUrls = List<String>.from(json.decode(data['image_url']));
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        developer.log('Error decoding image URLs: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      // Handle the case where no image URLs are found or image_url is null/empty
      developer.log('No images found or invalid image_url format.');
      setState(() => isLoading = false);
    }

  } on PostgrestException catch (e) {
    // Catch specific Supabase-related exceptions
    developer.log('Error fetching images: ${e.message}');
    setState(() => isLoading = false);
  } catch (e) {
    // Catch general exceptions
    developer.log('Unexpected error: $e');
    setState(() => isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('House Images Gallery'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : imageUrls.isEmpty
              ? const Center(child: Text('No images available'))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      imageUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text('Unable to load image');
                      },
                    );
                  },
                ),
    );
  }
}