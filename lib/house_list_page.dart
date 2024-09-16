import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HouseListPage extends StatefulWidget {
  final SupabaseClient supabaseClient;

  // ignore: use_super_parameters
  const HouseListPage(
      {Key? key, required this.supabaseClient, required List houseListings})
      : super(key: key);

  @override
  _HouseListPageState createState() => _HouseListPageState();
}

class _HouseListPageState extends State<HouseListPage> {
  List<dynamic> filteredListings = [];
  List<dynamic> houseListings = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true; // To show a loading spinner while data is fetching

  @override
  void initState() {
    super.initState();
    fetchHouseListings(); // Fetch data when the state is initialized
  }

  Future<void> fetchHouseListings() async {
    final response = await widget.supabaseClient
        .from('HouseListing')
        .select('*')
        // ignore: deprecated_member_use
        .execute();

    // Checking if the widget is still mounted before calling setState
    if (mounted) {
      if (response.status == 200 && response.data != null) {
        setState(() {
          houseListings =
              response.data as List<dynamic>; // Casting to List<dynamic>
          filteredListings = response.data as List<dynamic>;
          isLoading = false;
        });
      } else {
        // Handling the error message based on the updated API
        // ignore: avoid_print
        print(
            'Error fetching houses: Status code: ${response.status}'); // Adjusted error handling
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredListings = houseListings;
      });
      return;
    }

    List<dynamic> dummySearchList = houseListings.where((house) {
      return house['name']
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredListings = dummySearchList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('House Listings'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      filterSearchResults(value);
                    },
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: "Search",
                      hintText: "Search for houses",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                    ),
                  ),
                ),
                // ignore: sized_box_for_whitespace
                Container(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) => Chip(
                      label: Text("Filter ${index + 1}"),
                      onDeleted: () {},
                    ),
                  ),
                ),
                Expanded(
                  child: filteredListings.isEmpty
                      ? const Center(child: Text('No listings available'))
                      : ListView.builder(
                          itemCount: filteredListings.length,
                          itemBuilder: (context, index) {
                            final house = filteredListings[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DetailPage(house: house)));
                              },
                              child: Card(
                                elevation: 2.0,
                                margin: const EdgeInsets.all(8.0),
                                child: Hero(
                                  tag: 'hero${house['id']}',
                                  child: Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            house['image_url'] ?? ''),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Container(
                                      alignment: Alignment.bottomLeft,
                                      padding: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7)
                                          ],
                                        ),
                                      ),
                                      child: Text(
                                        house['name'] ?? 'Unknown Property',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final dynamic house;

  // ignore: use_super_parameters
  const DetailPage({Key? key, required this.house}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(house['name']),
      ),
      body: Center(
        child: Text(house['description'] ?? 'No description available'),
      ),
    );
  }
}
