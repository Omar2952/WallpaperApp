import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:wallpaperapp/Models/wallpaper_model.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaperapp/Utils/firebase_service.dart';
import '../Utils/app_colors.dart';
import '../Utils/favorites_database.dart';
import '../Widgets/CreateCollectionDialogue.dart';

class ImageScreen extends StatefulWidget {
  final PixabayImage image;
  const ImageScreen({super.key, required this.image});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {


  bool isDownloading = false;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<PixabayImage> sameAuthorImages = [];
  List<PixabayImage> pixaBayImages = [];
  final FireStoreService fireStoreService = FireStoreService();
  OverlayEntry? _overlayEntry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: whiteColor,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent.withOpacity(0.3),
              ),
              child: IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: _showBottomSheet),
            ),
          )
        ],
      ),
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              InteractiveViewer(
                maxScale: 4.0,
                minScale: 1.0,
                child: Image.network(
                  widget.image.largeImageURL,
                  isAntiAlias: true,
                  fit: BoxFit.fitHeight,
                  height: MediaQuery.of(context).size.height,
                  filterQuality: FilterQuality.high,
                ),
              ),

            ],
          ),
          Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent.withOpacity(0.3),
                ),
                child: isDownloading
                    ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : IconButton(
                    icon: const Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: _downloadImage),
              )),
        ],
      ),
    );
  }

  Future<void> _downloadImage() async {
    setState(() {
      isDownloading = true;
    });
    String url = widget.image.largeImageURL;
    var status = await Permission.storage.request();
    if(status.isGranted){
      await GallerySaver.saveImage(url, albumName: 'WallpaperHub')
          .then((value) => {
        setState(() {
          isDownloading = false;
          Get.snackbar('Download Successful', 'The Wallpaper was successfully downloaded', snackPosition: SnackPosition.BOTTOM, colorText: whiteColor,);
        })
      });
    }else{
      Get.snackbar('Permission Required', 'Storage permission is required to download the image', snackPosition: SnackPosition.BOTTOM, colorText: whiteColor,backgroundColor: Colors.redAccent);

    }

  }

  void _showBottomSheet() async {
    final FavoritesManager favoritesManager = FavoritesManager();

    final bool alreadyFavorite = favoritesManager.isFavorite(widget.image);
     final bool hasCollection = await fireStoreService.hasCollections();

    showModalBottomSheet<void>(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () {
                Share.share(widget.image.pageURL);
              },
            ),
            ListTile(
              leading: const Icon(Icons.wallpaper),
              title: const Text('Set Wallpaper'),
              onTap: _showSetWallpaperDialog,
            ),
            ListTile(
              leading: Icon(
                alreadyFavorite
                    ? Icons.favorite
                    : Icons.favorite_border_outlined,
                color: alreadyFavorite ? Colors.grey : null,
              ),
              title: Text(
                alreadyFavorite ? 'Remove from Favorites' : 'Add to Favorites',
              ),
              onTap: () {
                if (alreadyFavorite) {
                  favoritesManager.removeFromFavorites(widget.image);
                } else {
                  favoritesManager.addToFavorites(widget.image);
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.collections_outlined),
              title: const Text('Add to Collection'),
              onTap: () {
                if (hasCollection) {
                  _showAddToCollectionSheet();
                } else {
                  _showCreateCollectionDialog();
                }
              },
            ),

          ],
        );
      },
    );
  }

  Future<void> _showSetWallpaperDialog() async {
      await showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Set as Home Screen Wallpaper'),
                leading: const Icon(Icons.home_outlined),
                onTap: () {
                  Navigator.pop(context);
                  _setWallpaper(WallpaperManager.HOME_SCREEN);
                },
              ),
              ListTile(
                title: const Text('Set as Lock Screen Wallpaper'),
                leading: const Icon(Icons.lock_outline),
                onTap: () {
                  Navigator.pop(context);
                  _setWallpaper(WallpaperManager.LOCK_SCREEN);
                },
              ),
              ListTile(
                title: const Text('Set as Both'),
                leading: const Icon(Icons.home_work_outlined),
                onTap: () {
                  Navigator.pop(context);
                  _setWallpaper(WallpaperManager.BOTH_SCREEN);
                },
              ),
            ],
          );
        },
      );
    }
    Future<void> _setWallpaper(int screen) async {
      try {
        http.Response response =
        await http.get(Uri.parse(widget.image.largeImageURL));
        if (response.statusCode == 200) {
          Directory documentsDirectory = await getApplicationDocumentsDirectory();
          String imagePath = '${documentsDirectory.path}/wallpaper.jpg';

          await File(imagePath).writeAsBytes(response.bodyBytes);

          final result = await WallpaperManager.setWallpaperFromFile(
            imagePath,
            screen,
          );
          if (result) {
            print("Wallpaper Set Successfully");
          } else {
            print("Wallpaper Set Successfully");
          }
        } else {
          // Handle response error
        }
      } catch (e) {
        print("Error setting wallpaper: $e");
      }
    }
  Future<void> _showCreateCollectionDialog() async {
    String collectionName = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Give a Unique Name to Your Awesome Collection',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Roboto-Condensed',
            ),
          ),
          content: TextField(
            onChanged: (value) {
              collectionName = value;
            },
            decoration:
            const InputDecoration(labelText: 'My Awesome Collection'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: sliderColor),
              onPressed: () async {
                if (collectionName.isNotEmpty) {
                  try {
                    Navigator.pop(context);
                    await FireStoreService().addToCollection(collectionName: collectionName, image: widget.image);
                    Get.snackbar('Success', 'Image added to collection', snackPosition: SnackPosition.BOTTOM, colorText: whiteColor);
                  } catch (e) {
                    if (e.toString().contains('Image already exists in the collection')) {
                      Get.snackbar('Error', 'Image already exists in the collection', snackPosition: SnackPosition.BOTTOM, colorText: whiteColor, backgroundColor: Colors.orange);
                    } else {
                      Get.snackbar('Error', 'Failed to add image to collection', snackPosition: SnackPosition.BOTTOM, colorText: whiteColor, backgroundColor: Colors.redAccent);
                      log('Error adding image to collection: $e');
                    }
                  }
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddToCollectionSheet() {
    showModalBottomSheet<void>(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        return CollectionListSheet(image: widget.image);
      },
    );
  }



}
