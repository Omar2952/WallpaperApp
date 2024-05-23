import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallpaperapp/Utils/firebase_service.dart';
import '../Models/wallpaper_model.dart';
import '../Utils/app_colors.dart';

class CollectionListSheet extends StatefulWidget {
  final PixabayImage image;

  const CollectionListSheet({super.key, required this.image});

  @override
  _CollectionListSheetState createState() => _CollectionListSheetState();
}

class _CollectionListSheetState extends State<CollectionListSheet> {
  List<String> collections = [];
  bool isLoading = true;

  Future<void> _loadCollections() async {
    setState(() {
      isLoading = true;
    });

    List<String> collectionNames = await FireStoreService().getCollectionNames();

    setState(() {
      isLoading = false;
      collections = collectionNames;
    });
  }
  @override
  void initState() {
    super.initState();
    _loadCollections().then((value) => {
          setState(() {
            isLoading = false;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: collections.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              var collection = collections[index];
              return isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
                    child: Card(
                color: Colors.grey.shade400,
                      child: ListTile(
                          title: Text(collection),
                          onTap: () async {
                            try {
                              Navigator.pop(context);
                              await FireStoreService().addToCollection(collectionName: collection, image: widget.image);
                              Get.snackbar('Success', 'Image added to collection', snackPosition: SnackPosition.BOTTOM, colorText: whiteColor);
                            } catch (e) {
                              if (e.toString().contains('Image already exists in the collection')) {
                                Get.snackbar('Error', 'Image already exists in the collection', snackPosition: SnackPosition.BOTTOM, colorText: whiteColor, backgroundColor: Colors.orange);
                              } else {
                                Get.snackbar('Error', 'Failed to add image to collection', snackPosition: SnackPosition.BOTTOM, colorText: whiteColor, backgroundColor: Colors.redAccent);
                                log('Error adding image to collection: $e');
                              }
                            }
                          },
                        ),
                    ),
                  );
            },
          ),
        ),
        ListTile(
          title: const Text('Create New Collection'),
          trailing: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.add),
          ),
          onTap: () {
            Navigator.pop(context);
            _showCreateCollectionDialog();
          },
        ),
      ],
    );
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

}
