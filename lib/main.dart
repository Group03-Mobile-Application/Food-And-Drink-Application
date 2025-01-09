import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food_and_drink/views/app_main_screen.dart';
import 'package:provider/provider.dart';
import '../Provider/favorite_provider.dart';
import 'Provider/quantity.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // for favorite providers
        ChangeNotifierProvider(create: (_)=>FavoriteProvider()),
        // for quantity providers
        ChangeNotifierProvider(create: (_) => QuantityProvider()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AppMainScreen(),
      ),
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: const AppMainScreen(),
    );
  }
}
