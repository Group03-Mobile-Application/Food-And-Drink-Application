import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../Provider/favorite_provider.dart';
import '../Utils/constants.dart';
import 'recipe_detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  String searchQuery = "";
  String category = "All"; // Default category
  List<Map<String, dynamic>> favoriteData = [];
  bool isLoading = true;

  final CollectionReference categoriesItems =
      FirebaseFirestore.instance.collection("App-Category");

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchFavoriteData();
  }

  Future<void> _fetchFavoriteData() async {
    final provider = Provider.of<FavoriteProvider>(context, listen: false);
    final favoriteItems = provider.favorites;

    List<Map<String, dynamic>> fetchedData = [];
    for (String favoriteId in favoriteItems) {
      var doc = await FirebaseFirestore.instance
          .collection("Food-And-Drink-Application")
          .doc(favoriteId)
          .get();
      if (doc.exists) {
        fetchedData.add({
          "id": favoriteId,
          "name": doc['name'] ?? 'Unknown',
          "image": doc['image'] ?? '',
          "cal": doc['cal'] ?? 0,
          "time": doc['time'] ?? 0,
          "category": doc['category'] ?? 'Other', // Category field
        });
      }
    }

    setState(() {
      favoriteData = fetchedData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter favorites based on search query and selected category
    final filteredFavorites = favoriteData.where((item) {
      final matchesSearch = item['name']
          .toLowerCase()
          .contains(searchQuery.toLowerCase()); // Matches search query
      final matchesCategory = category == "All" ||
          item['category'] == category; // Matches selected category
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        centerTitle: true,
        title: const Text(
          "Favorites",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110.0),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search favorites...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: selectedCategory(), // Category selection widget
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : filteredFavorites.isEmpty
              ? const Center(
                  child: Text(
                    "No Favorites found",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredFavorites.length,
                  itemBuilder: (context, index) {
                    var favoriteItem = filteredFavorites[index];
                    return GestureDetector(
                      onTap: () async {
                        // Fetch the document snapshot for the selected favorite item
                        DocumentSnapshot doc = await FirebaseFirestore.instance
                            .collection("Food-And-Drink-Application")
                            .doc(favoriteItem['id'])
                            .get();

                        // Navigate to RecipeDetailScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailScreen(
                              documentSnapshot: doc,
                            ),
                          ),
                        );
                      },
                      child: Dismissible(
                        key: Key(favoriteItem['id']),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) async {
                          // Remove the item from Firestore and local list
                          DocumentSnapshot snapshot = await FirebaseFirestore.instance
                              .collection("Food-And-Drink-Application")
                              .doc(favoriteItem['id'])
                              .get();

                          if (!mounted) return;

                          final provider =
                              Provider.of<FavoriteProvider>(context, listen: false);
                          provider.toggleFavorite(snapshot);

                          setState(() {
                            favoriteData.remove(favoriteItem);
                          });

                          // Show confirmation SnackBar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "${favoriteItem['name']} removed from favorites.",
                              ),
                            ),
                          );
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                // Recipe Image
                                Container(
                                  width: 100,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                        favoriteItem['image'],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Recipe Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        favoriteItem['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          const Icon(
                                            Iconsax.flash_1,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          Text(
                                            "${favoriteItem['cal']} Cal",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const Text(
                                            " · ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const Icon(
                                            Iconsax.clock,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            "${favoriteItem['time']} Min",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Delete Button
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    // Remove the item from Firestore and local list
                                    DocumentSnapshot snapshot =
                                        await FirebaseFirestore.instance
                                            .collection(
                                                "Food-And-Drink-Application")
                                            .doc(favoriteItem['id'])
                                            .get();

                                    if (!mounted) return;

                                    final provider = Provider.of<FavoriteProvider>(
                                        context,
                                        listen: false);
                                    provider.toggleFavorite(snapshot);

                                    setState(() {
                                      favoriteData.remove(favoriteItem);
                                    });

                                    // Show confirmation SnackBar
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "${favoriteItem['name']} removed from favorites.",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // Category selection widget
  Widget selectedCategory() {
    return StreamBuilder(
      stream: categoriesItems.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        if (streamSnapshot.hasData) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                streamSnapshot.data!.docs.length,
                (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      category = streamSnapshot.data!.docs[index]['name'];
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color:
                          category == streamSnapshot.data!.docs[index]['name']
                              ? kprimaryColor
                              : Colors.white,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.only(right: 10),
                    child: Text(
                      streamSnapshot.data!.docs[index]['name'],
                      style: TextStyle(
                        color:
                            category == streamSnapshot.data!.docs[index]['name']
                                ? Colors.white
                                : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
