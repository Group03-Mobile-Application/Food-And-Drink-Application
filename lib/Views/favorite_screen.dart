import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../Provider/favorite_provider.dart';
import '../Provider/theme_provider.dart';
import '../Utils/constants.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final provider = FavoriteProvider.of(context);
    final favoriteItems = provider.favorites;
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.grey[850] : kbackgroundColor, // Change here
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Colors.grey[850] : kbackgroundColor, // Change here
        centerTitle: true,
        title:  Text(
          "Favorites",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color:  themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: favoriteItems.isEmpty
          ?  Center(
        child: Text(
          "No Favorites yet",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      )
          : ListView.builder(
        itemCount: favoriteItems.length,
        itemBuilder: (context, index) {
          String favorite = favoriteItems[index];
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("Food-And-Drink-Application")
                .doc(favorite)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(
                  child: Text("Error loading favorites"),
                );
              }
              var favoriteItem = snapshot.data!;
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
                      ),
                      child: Row(
                        children: [
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                favoriteItem['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
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
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    right: 35,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          provider.toggleFavorite(favoriteItem);
                        });
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}