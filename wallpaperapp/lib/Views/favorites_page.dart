import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wallpaperapp/Utils/app_colors.dart';

import '../Models/wallpaper_model.dart';
import '../Utils/favorites_database.dart';
import '../Widgets/PlaceHolderImage.dart';
import 'ImageScreen.dart';


class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool isLoading = false;
  List<PixabayImage> favoriteImages = [];
  final FavoritesManager _databaseHelper = FavoritesManager();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    fetchFavoriteImages();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    isLoading;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LiquidPullToRefresh(
            backgroundColor: sliderColor,
            color: Colors.deepPurple,
            height: 100,
            animSpeedFactor: 2,
            showChildOpacityTransition: false,
            onRefresh: fetchFavoriteImages,
            child: favoriteImages.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: StaggeredGridView.countBuilder(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                itemCount: favoriteImages.length,
                itemBuilder: (context, index) {
                  PixabayImage currentImage = favoriteImages[index];
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ImageScreen(image: currentImage),
                            ),
                          );
                        },
                        onLongPress: () =>
                            _showLargerImage(currentImage.largeImageURL),
                        onLongPressUp: _hideLargerImage,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            currentImage.largeImageURL,
                            fit: BoxFit.cover,
                            height: randomHeight(),
                            errorBuilder: (context, error, stackTrace) {
                              return const PlaceholderImageWidget();
                            },
                            loadingBuilder: (BuildContext context,
                                Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    color: Colors.white,
                                    height: 260,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
                staggeredTileBuilder: (index) => const StaggeredTile.fit(1),
              ),
            )
                : isLoading ? const Center(child: CircularProgressIndicator()) :  const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "No Favorites Yet!",
                    style: TextStyle(
                        fontSize: 28, fontFamily: 'Roboto-Condensed', color: whiteColor),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "Pictures you add to favorites\n  will appear here",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Roboto-Condensed-Light',
                          color: Colors.grey),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Future<void> fetchFavoriteImages() async {
    setState(() {
      isLoading = true;
    });
    List<PixabayImage> favorites = _databaseHelper.getFavorites();
    favorites.sort((a, b) {
      try {
        final aTimestamp =
            DateTime.tryParse(a.favoriteTimestamp) ?? DateTime(0);
        final bTimestamp =
            DateTime.tryParse(b.favoriteTimestamp) ?? DateTime(0);
        return bTimestamp.compareTo(aTimestamp);
      } catch (e) {
        return 0;
      }
    });
    setState(() {
      favoriteImages = favorites;
      isLoading = false;
    });
  }

  void _showLargerImage(String imageUrl) {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        double opacity = 0.0;
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            opacity = value;
            return Opacity(
              opacity: opacity,
              child: Container(
                color: Colors.black.withOpacity(0.8),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(imageUrl, fit: BoxFit.contain)),
                ),
              ),
            );
          },
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideLargerImage() {
    _overlayEntry?.remove();
  }

  double randomHeight() {
    double minHeight = 280.0;
    double maxHeight = 350.0;
    double randomHeight =
        minHeight + Random().nextDouble() * (maxHeight - minHeight);
    return randomHeight;
  }
}
