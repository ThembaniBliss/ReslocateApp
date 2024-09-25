// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use, unused_import, duplicate_ignore
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'house_detail_page.dart';
import 'house_list_page.dart';
// ignore: unused_import
import 'binterest_form_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
        .select('name, location, amenities, security, furnish, price, image_url, description')
        .execute();

    // ignore: unnecessary_null_comparison
    if (response.status != null && response.status >= 400) {
      print("Error fetching data: Status Code ${response.status}");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Status Code ${response.status}')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No accommodations found')),
      );
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
                    return buildHouseCard(house); // Call the card building function here
                  },
                ),
    );
  }

  // Widget function to build a card with image slider
  Widget buildHouseCard(dynamic house) {
    List<String> imageUrls = house['image_url'] != null
        ? List<String>.from(house['image_url']) // Fetch image URLs as a list
        : []; // Empty list if no images are available

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
            imageUrls.isNotEmpty
                ? CarouselSlider(
                    options: CarouselOptions(
                      height: 200,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      autoPlay: false,
                    ),
                    items: imageUrls.map((url) {
                      return GestureDetector(
                        onTap: () {
                          // Open full-screen gallery when an image is clicked
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenGallery(
                                imageUrls: imageUrls,
                                initialIndex: imageUrls.indexOf(url),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) =>
                                const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : const Icon(Icons.home, size: 100), // Default icon if no images
            const SizedBox(height: 10),
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
                    // Navigation or action code here
                  },
                  child: const Text('Are you Interested?'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Fullscreen gallery view using PhotoView and PhotoViewGallery
class FullScreenGallery extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  // ignore: use_key_in_widget_constructors
  const FullScreenGallery({required this.imageUrls, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PhotoViewGallery.builder(
        itemCount: imageUrls.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrls[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}
