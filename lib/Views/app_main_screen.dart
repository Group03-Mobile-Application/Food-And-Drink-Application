import 'package:flutter/material.dart';
import 'package:food_and_drink/Views/meal_plan_screen.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../Provider/theme_provider.dart';
import '../Utils/constants.dart';
import 'favorite_screen.dart';
import 'my_app_home_screen.dart';

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({super.key});

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  int selectedIndex = 0;
  late List<Widget> page;
  late ThemeProvider themeProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    themeProvider = Provider.of<ThemeProvider>(context);

    page = [
      const MyAppHomeScreen(),
      const FavoriteScreen(),
      const MealPlanScreen(),
      navBarPage(Iconsax.calendar5),
      Container(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white, // Change here
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:themeProvider.isDarkMode ? Colors.grey[800] : Colors.white, // Change here
        elevation: 0,
        iconSize: 28,
        currentIndex: selectedIndex,
        selectedItemColor: kprimaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          color: kprimaryColor,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        onTap: (value) {
          if (value == 3) {
            themeProvider.toggleTheme();
          } else {
            setState(() {
              selectedIndex = value;
            });
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 0 ? Iconsax.home5 : Iconsax.home_1,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 1 ? Iconsax.heart5 : Iconsax.heart,
            ),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 2 ? Iconsax.calendar5 : Iconsax.calendar,
            ),
            label: "Meal Plan",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            label: "Theme",
          ),
        ],
      ),
      body: page[selectedIndex],
    );
  }

  Widget navBarPage(iconName) {
    return Center(
      child: Icon(
        iconName,
        size: 100,
        color: themeProvider.isDarkMode ? Colors.white : kprimaryColor,
      ),
    );
  }
}
