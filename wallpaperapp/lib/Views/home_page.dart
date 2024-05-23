import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallpaperapp/Views/profile_page.dart';
import 'package:wallpaperapp/Views/search_page.dart';
import 'package:wallpaperapp/Views/wallpapers_page.dart';

import '../Widgets/CustomBottomNavigation.dart';
import 'collections_page.dart';
import 'favorites_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  var currentIndex = 0;

  List<IconData> listOfIcons = [
    Icons.home_rounded,
    Icons.search_rounded,
    Icons.favorite_rounded,
    Icons.collections,
  ];

  List<String> listOfStrings = [
    'Home',
    'Search',
    'Favorites',
    'Collection',
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildCurrentPage(currentIndex),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavigation(
              icons: listOfIcons,
              labels: listOfStrings,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                  HapticFeedback.lightImpact();
                });
              },
              currentIndex: currentIndex,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage(int index) {
    switch (index) {
      case 0:
        return const WallpaperPage();
      case 1:
        return const SearchPage();
      case 2:
        return const FavoritesPage();
      case 3:
        return const CollectionPage();
      default:
        return Container();
    }
  }

}