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
  // Perform the query
  final response = await client
      .from('HouseListing')
      .select('image_url')
      .eq('id', widget.houseId)
      .single(); // Adjust if necessary based on the returned type

  // Check if the response has an error
  if (response is PostgrestResponse && response.error != null) {
    // Log the error message if there's one
    developer.log('Error fetching images: ${response.error!.message}');
    setState(() => isLoading = false);
    return; // Exit early if there's an error
  }

  // Safely access the response data if it's a PostgrestResponse
  if (response is PostgrestResponse) {
    final data = response.data;
    if (data != null && data['image_url'] != null) {
      // Decode the image URLs and update the state
      setState(() {
        imageUrls = List<String>.from(json.decode(data['image_url']));
        isLoading = false;
      });
    } else {
      // Handle the case where no image URLs are found
      developer.log('No images found for this house.');
      setState(() => isLoading = false);
    }
  } else {
    // Handle unexpected response types
    developer.log('Unexpected response type received.');
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