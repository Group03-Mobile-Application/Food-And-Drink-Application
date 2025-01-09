import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../Provider/favorite_provider.dart';
import '../Provider/quantity.dart';
import '../Provider/theme_provider.dart';
import '../Utils/constants.dart';
import '../Widget/my_icon_button.dart';
import '../Widget/quantity_increment_decrement.dart';


class RecipeDetailScreen extends StatefulWidget {
  final DocumentSnapshot<Object?> documentSnapshot;
  const RecipeDetailScreen({super.key, required this.documentSnapshot});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  YoutubePlayerController? _youtubeController;
  bool isInitialized = false;


  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }


  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Initialize base ingredient amounts in the provider
        List<double> baseAmounts = (widget
            .documentSnapshot['ingredientsAmount'] ?? [])
            .map<double>((amount) => double.tryParse(amount.toString()) ?? 0.0)
            .toList();
        Provider.of<QuantityProvider>(context, listen: false)
            .setBaseIngredientAmounts(baseAmounts);
      });
      isInitialized = true;
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.documentSnapshot.id)
          .collection('comments')
          .add({
        'content': _commentController.text,
        'user': 'Anonymous User',
        'timestamp': FieldValue.serverTimestamp(),
      });

      _commentController.clear();
    }


    final videoLink = widget.documentSnapshot['videoLink'];
    if (videoLink != null && videoLink.isNotEmpty) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(videoLink)!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    }
  }
  void _showVideoDialog() {
    if (_youtubeController == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No video link available')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            content: AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(
                controller: _youtubeController!,
                showVideoProgressIndicator: true,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _editComment(DocumentSnapshot comment) {
    final TextEditingController _editController = TextEditingController(
      text: comment['content'],
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Comment'),
        content: TextField(
          controller: _editController,
          decoration: InputDecoration(
            hintText: 'Edit your comment...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_editController.text.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance
                      .collection('recipes')
                      .doc(widget.documentSnapshot.id)
                      .collection('comments')
                      .doc(comment.id)
                      .update({
                    'content': _editController.text,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error updating comment: $e');
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final provider = FavoriteProvider.of(context);
    final quantityProvider = Provider.of<QuantityProvider>(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: startCookingAndFavoriteButton(provider),
      backgroundColor: themeProvider.isDarkMode ?
      Colors.grey[850] : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 2.1,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        widget.documentSnapshot['image'],
                      ),
                    ),
                  ),
                ),
                // for back button
                Positioned(
                  top: 40,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: [
                      MyIconButton(
                        icon: Icons.arrow_back_ios_new,
                        pressed: () {
                          Navigator.pop(context);
                        },
                        iconColor: themeProvider.isDarkMode ?
                        Colors.white : Colors.black,
                      ),
                      const Spacer(),
                      MyIconButton(
                        icon: Iconsax.notification,
                        iconColor: themeProvider.isDarkMode ?
                        Colors.white : Colors.black,
                        pressed: () {},
                      )
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.width,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode ?
                      Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: Container(
                width: 40,
                height: 8,
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ?
                  Colors.grey[700] : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.documentSnapshot['name'],
                    style:  TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ?
                      Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Iconsax.flash_1,
                        size: 20,
                        color: themeProvider.isDarkMode ?
                        Colors.white : Colors.grey,
                      ),
                      Text(
                        "${widget.documentSnapshot['cal']} Cal",
                        style:  TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color:  themeProvider.isDarkMode ?
                          Colors.white : Colors.grey,
                        ),
                      ),
                      const Text(
                        " · ",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                        ),
                      ),
                      Icon(
                        Iconsax.clock,
                        size: 20,
                        color: themeProvider.isDarkMode ?
                        Colors.white : Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${widget.documentSnapshot['time']} Min",
                        style:  TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: themeProvider.isDarkMode ?
                          Colors.white : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // for rating
                  Row(
                    children: [
                      const Icon(
                        Iconsax.star1,
                        color: Colors.amberAccent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.documentSnapshot['rate'],
                        style:  TextStyle(
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isDarkMode ?
                          Colors.white : Colors.black,
                        ),
                      ),
                      const Text("/5"),
                      const SizedBox(width: 5),
                      Text(
                        "${widget.documentSnapshot[
                        'reviews'.toString()]} Reviews",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Infredients",
                            style:  TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDarkMode ?
                              Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "How many servings?",
                            style: TextStyle(
                              fontSize: 14,
                              color:  themeProvider.isDarkMode ?
                              Colors.white : Colors.grey,
                            ),
                          )
                        ],
                      ),
                      const Spacer(),
                      QuantityIncrementDecrement(
                        currentNumber: quantityProvider.currentNumber,
                        onAdd: () => quantityProvider.increaseQuantity(),
                        onRemov: () => quantityProvider.decreaseQuanity(),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  // list of ingredients
                  Column(
                    children: [
                      Row(
                        children: [
                          // ingredients images
                          Column(
                            children: widget
                                .documentSnapshot['ingredientsImage']
                                .map<Widget>(
                                  (imageUrl) => Container(
                                height: 60,
                                width: 60,
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      imageUrl,
                                    ),
                                  ),
                                ),
                              ),
                            )
                                .toList(),
                          ),
                          const SizedBox(width: 20),
                          // ingredients name
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.documentSnapshot['ingredientsName']
                                .map<Widget>((ingredient) => SizedBox(
                              height: 60,
                              child: Center(
                                child: Text(
                                  ingredient,
                                  style:  TextStyle(
                                    fontSize: 16,
                                    color: themeProvider.isDarkMode ?
                                    Colors.white : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ))
                                .toList(),
                          ),
                          // ingredient amount
                          const Spacer(),
                          Column(
                            children: quantityProvider.updateIngredientAmounts
                                .map<Widget>((amount) => SizedBox(
                              height: 60,
                              child: Center(
                                child: Text(
                                  "${amount}gm",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: themeProvider.isDarkMode ?
                                    Colors.white : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ))
                                .toList(),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          thickness: 1,
                          color: themeProvider.isDarkMode ?
                          Colors.grey[600]! : Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Comments",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ?
                            Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _commentController,
                          style:  TextStyle(color: themeProvider.isDarkMode ?
                          Colors.white : Colors.black),
                          decoration: InputDecoration(
                            hintText: "Add a comment...",
                            hintStyle:  TextStyle(
                                color: themeProvider.isDarkMode ?
                                Colors.white : Colors.grey),
                            suffixIcon: IconButton(
                              icon:  Icon(Icons.send,
                                color: themeProvider.isDarkMode ?
                                Colors.white : Colors.black,),
                              onPressed: _addComment,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 0),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('recipes')
                              .doc(widget.documentSnapshot.id)
                              .collection('comments')
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final comments = snapshot.data!.docs;
                            if (comments.isEmpty) {
                              return Text(
                                "No comments yet. Be the first!",
                                style: TextStyle(
                                    color: themeProvider.isDarkMode ?
                                    Colors.white : Colors.black),
                              );
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                return ListTile(
                                  title: Text(
                                    comment['content'],
                                    style: TextStyle(
                                        color: themeProvider.isDarkMode ?
                                        Colors.white : Colors.black),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comment['user'],
                                        style: TextStyle(
                                          color: themeProvider.isDarkMode ?
                                          Colors.white : Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        (comment['timestamp'] as Timestamp?)
                                            ?.toDate()
                                            .toString()
                                            .substring(0, 16) ??
                                            "Just now",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: themeProvider.isDarkMode ?
                                          Colors.white : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),

                                  trailing: Column(
                                    children: [
                                      IconButton(
                                        icon: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Icon(Icons.edit),
                                        ),
                                        onPressed: () => _editComment(comment),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 150),
                      ],
                    ),
                  ),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  FloatingActionButton startCookingAndFavoriteButton(
      FavoriteProvider provider) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return FloatingActionButton.extended(
      backgroundColor: Colors.transparent,
      elevation: 0,
      onPressed: null,
      label: Row(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kprimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 13),
              foregroundColor: Colors.white,
            ),
            onPressed: _showVideoDialog, // Trigger the video dialog
            child: const Text(
              "Start Cooking",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            style: IconButton.styleFrom(
              shape: CircleBorder(
                side: BorderSide(
                  color:themeProvider.isDarkMode ?
                  Colors.grey.shade600 : Colors.grey.shade300,
                  width: 2,
                ),
              ),
            ),
            onPressed: () {
              provider.toggleFavorite(widget.documentSnapshot);
            },
            icon: Icon(
              provider.isExist(widget.documentSnapshot)
                  ? Iconsax.heart5
                  : Iconsax.heart,
              color: provider.isExist(widget.documentSnapshot)
                  ? Colors.red
                  : Colors.black,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}