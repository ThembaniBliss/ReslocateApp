import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'dart:convert';

class AccommodationPage extends StatefulWidget {
  final SupabaseClient supabaseClient;

  const AccommodationPage({super.key, required this.supabaseClient});

  @override
  _AccommodationPageState createState() => _AccommodationPageState();
}

class _AccommodationPageState extends State<AccommodationPage> {
  List<dynamic> houseListings = [];
  bool isLoading = true;
  bool showAll = false;

  @override
  void initState() {
    super.initState();
    fetchAccommodations();
  }

  Future<void> fetchAccommodations() async {
    // ignore: avoid_print
    print('Fetching accommodations from Supabase...');
    final response = await widget.supabaseClient
        .from('HouseListing')
        .select('name, location, amenities, security, furnish, price, image_url, description')
        // ignore: deprecated_member_use
        .execute();

    // ignore: unnecessary_null_comparison
    if (response.status != null && response.status >= 400) {
      // ignore: avoid_print
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No accommodations found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayList = showAll ? houseListings : houseListings.take(4).toList();

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
              : Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, // 4 items per row
                            crossAxisSpacing: 10.0, // Space between columns
                            mainAxisSpacing: 10.0, // Space between rows
                            childAspectRatio: 0.65, // Adjust the aspect ratio to create more space
                          ),
                          itemCount: displayList.length,
                          itemBuilder: (context, index) {
                            final house = displayList[index];
                            return buildHouseCard(house);
                          },
                        ),
                      ),
                    ),
                    if (showAll)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showAll = false; // Go back to showing only 4 items
                            });
                          },
                          child: const Text('View Less'),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showAll = true; // Show all items
                            });
                          },
                          child: const Text('View All'),
                        ),
                      ),
                  ],
                ),
    );
  }

  // Widget function to build a card with a CarouselSlider for images
  Widget buildHouseCard(dynamic house) {
    List<String> imageUrls = house['image_url'] != null
        ? List<String>.from(json.decode(house['image_url']))
        : [];

    return Card(
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
                      height: 100, // Reduced height for more space
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
            Flexible(
              child: Text(
                house['location'] ?? 'Unknown Location',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // Handle text overflow
              ),
            ),
            Flexible(
              child: Text(
                'R ${house['price'] ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // Handle text overflow
              ),
            ),
            Flexible(
              child: Text(
                '${house['furnish'] ?? ''} Bedroom',
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // Handle text overflow
              ),
            ),
            Flexible(
              child: Text(
                house['description'] ?? 'No description available',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis, // Limit to 2 lines
              ),
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

  const FullScreenGallery({super.key, required this.imageUrls, required this.initialIndex});

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
