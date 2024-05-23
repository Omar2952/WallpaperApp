import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wallpaperapp/Utils/app_colors.dart';
import 'package:wallpaperapp/Utils/firebase_service.dart';

import '../Models/wallpaper_model.dart';
import '../Widgets/PlaceHolderImage.dart';
import 'ImageScreen.dart';

class CollectionDetailsPage extends StatefulWidget {
  final String collection;
  const CollectionDetailsPage({super.key, required this.collection});

  @override
  State<CollectionDetailsPage> createState() => _CollectionDetailsPageState();
}

class _CollectionDetailsPageState extends State<CollectionDetailsPage> {

  List<PixabayImage> collectionImages = [];
  OverlayEntry? _overlayEntry;

  Future<void> getImagesInCollection() async {
    List<PixabayImage> images =  await FireStoreService().getImagesFromCollection(widget.collection);
    setState(() {
      collectionImages =images;
    });

  }

  Future<void> _showDeleteCollectionDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Are you sure you want to delete ' ${widget.collection} ' ",
            style: const TextStyle(
              fontSize: 18,
              fontFamily: 'Roboto-Condensed',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                await FireStoreService().deleteCollection(widget.collection)
                    .then((value) => {
                  Navigator.pop(context, true),
                  Navigator.pop(context, true),
                });
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }


  double randomHeight() {
    double minHeight = 280.0;
    double maxHeight = 350.0;
    double randomHeight = minHeight + Random().nextDouble() * (maxHeight - minHeight);
    return randomHeight;
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getImagesInCollection();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.collection,
          style: const TextStyle(fontFamily: 'Roboto-Condensed', fontSize: 24, color: whiteColor),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: whiteColor,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          GestureDetector(
            onTap: () => _showDeleteCollectionDialog(),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child:
              Icon(Icons.delete_forever, color: Colors.redAccent, size: 28),
            ),
          )
        ],
      ),

      body: StaggeredGridView.countBuilder(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        itemCount: collectionImages.length,
        itemBuilder: (context, index) {
          PixabayImage currentImage = collectionImages[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 2,
            child: ScaleAnimation(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImageScreen(image: currentImage),
                    ),
                  );
                },
                onLongPress: () => _showLargerImage(currentImage.largeImageURL),
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
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
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
    );
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
                  child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(imageUrl, fit: BoxFit.contain)),
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



}
