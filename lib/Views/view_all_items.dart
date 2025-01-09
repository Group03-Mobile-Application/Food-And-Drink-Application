import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../Provider/theme_provider.dart';
import '../Utils/constants.dart';
import '../Widget/food_items_display.dart';
import '../Widget/my_icon_button.dart';

class ViewAllItems extends StatefulWidget {
  const ViewAllItems({super.key});

  @override
  State<ViewAllItems> createState() => _ViewAllItemsState();
}

class _ViewAllItemsState extends State<ViewAllItems> {
  final CollectionReference completeApp =
  FirebaseFirestore.instance.collection("Food-And-Drink-Application");



  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ?
      Colors.grey[850] : kbackgroundColor, // Change here
      appBar: AppBar(
        backgroundColor:  themeProvider.isDarkMode ?
        Colors.grey[850] : kbackgroundColor, // Change here
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          const SizedBox(width: 15),
          MyIconButton(
            icon: Icons.arrow_back_ios_new,
            pressed: () {
              Navigator.pop(context);
            },
            iconColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
          const Spacer(),
          Text(
            "Quick & Easy",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const Spacer(),
          MyIconButton(
            icon: Iconsax.notification,
            pressed: () {},
            iconColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 15, right: 5),
        child: Column(
          children: [
            const SizedBox(height: 10),
            StreamBuilder(
              stream: completeApp.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasData) {
                  return GridView.builder(

                    itemCount: streamSnapshot.data!.docs.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                    ),
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];

                      return Column(
                        children: [
                          FoodItemsDisplay(documentSnapshot: documentSnapshot),
                          Row(
                            children: [
                              const Icon(
                                Iconsax.star1,
                                color: Colors.amberAccent,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                documentSnapshot['rate'],
                                style:  TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.isDarkMode ?
                                  Colors.white : Colors.black,
                                ),
                              ),
                              Text("/5", style:  TextStyle(color:
                              themeProvider.isDarkMode ?
                              Colors.white : Colors.black,)),
                              const SizedBox(width: 5),
                              Text(
                                "${documentSnapshot[
                                'reviews'.toString()]} Reviews",
                                style:  TextStyle(
                                  color:  themeProvider.isDarkMode ?
                                  Colors.white : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}