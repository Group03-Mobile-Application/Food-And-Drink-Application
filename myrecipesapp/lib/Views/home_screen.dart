import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myrecipesapp/Views/view_all_items.dart';
import '../Utils/constant.dart';
import '../Widget/banner.dart';
import '../Widget/icon_button.dart';
import '../Widget/items_display.dart';

class MyAppHomeScreen extends StatefulWidget {
  const MyAppHomeScreen({super.key});

  @override
  State<MyAppHomeScreen> createState() => _MyAppHomeScreenState();
}

class _MyAppHomeScreenState extends State<MyAppHomeScreen> {
  String category = "All";

  final CollectionReference categoriesItems =
  FirebaseFirestore.instance.collection("App-Category");

  Query get filteredRecipes => FirebaseFirestore.instance
      .collection("Complete-Flutter-App")
      .where('category', isEqualTo: category);

  Query get allRecipes =>
      FirebaseFirestore.instance.collection("Complete-Flutter-App");

  Query get selectedRecipes =>
      category == "All" ? allRecipes : filteredRecipes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerSection(),
                const SizedBox(height: 20),
                searchBar(),
                const SizedBox(height: 20),
                const BannerToExplore(),
                const SizedBox(height: 20),
                sectionTitle("Categories"),
                const SizedBox(height: 10),
                categorySelection(),
                const SizedBox(height: 20),
                sectionHeader(
                  title: "Quick & Easy",
                  actionText: "View all",
                  action: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ViewAllItems(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                recipeList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget headerSection() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "What are you\ncooking today?",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
        ),
        AppIconButton(
          icon: Iconsax.notification,
          pressed: () {},
          backgroundColor: Colors.white,
          iconColor: Colors.black87,
        ),
      ],
    );
  }

  Widget searchBar() {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        prefixIcon: const Icon(
          Iconsax.search_normal,
          color: Colors.black54,
        ),
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintText: "Search any recipes...",
        hintStyle: const TextStyle(color: Colors.black54, fontSize: 16),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget sectionHeader({
    required String title,
    required String actionText,
    required VoidCallback action,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: action,
          child: Text(
            actionText,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget categorySelection() {
    return StreamBuilder<QuerySnapshot>(
      stream: categoriesItems.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                snapshot.data!.docs.length,
                    (index) {
                  String categoryName = snapshot.data!.docs[index]['name'];
                  bool isSelected = category == categoryName;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        category = categoryName;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color:
                        isSelected ? Colors.orange : Colors.grey.shade200,
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                            : [],
                      ),
                      child: Text(
                        categoryName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
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

  Widget recipeList() {
    return StreamBuilder<QuerySnapshot>(
      stream: selectedRecipes.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<DocumentSnapshot> recipes = snapshot.data?.docs ?? [];
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: recipes
                  .map((e) => FoodItemsDisplay(documentSnapshot: e))
                  .toList(),
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
