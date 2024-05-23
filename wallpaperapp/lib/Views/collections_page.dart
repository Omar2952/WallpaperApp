import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wallpaperapp/Utils/app_colors.dart';
import 'package:wallpaperapp/Utils/firebase_service.dart';
import 'package:wallpaperapp/Utils/text_style.dart';

import 'collection_details_page.dart';


class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  List<String> collections = [];
  FireStoreService fireStoreService = FireStoreService();

  Future<void> fetchCollections() async {
    final fetchedCollections =
    await fireStoreService.getCollectionNames();
    setState(() {
      collections = fetchedCollections;
    });
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
                  await fireStoreService.createCollection(collectionName)
                      .then((value) => {Navigator.pop(context)});
                  setState(() {
                    fetchCollections();
                  });
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

  @override
  void initState() {
    super.initState();
    fetchCollections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (collections.isNotEmpty)
            TextButton(onPressed: ()=> _showCreateCollectionDialog(), child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text("Add Collection", style: textStyle(size: 18),),
                const SizedBox(width: 4,),
                const Icon(Icons.add, color: sliderColor,  size: 28)
              ],),
            ))
        ],
      ),
      body: collections.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'You Have No Collections Yet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontFamily: 'Roboto-Condensed', color: whiteColor),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showCreateCollectionDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Create Collection'),

            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(4.0),
        child: ListView.builder(
          itemCount: (collections.length + 1) ~/ 2,
          itemBuilder: (context, rowIndex) {
            final startIndex = rowIndex * 2;
            final endIndex = startIndex + 2;
            final currentRowCollections = collections.sublist(
                startIndex, endIndex.clamp(0, collections.length));

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: currentRowCollections.map((collection) {
                int randomColorCode =
                    0xFF000000 + Random().nextInt(0xFFFFFF);

                return Expanded(
                  child: SizedBox(
                    height: 250,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CollectionDetailsPage(
                                collection: collection),
                          ),
                        ).then((value) => {
                          if(value == true){
                            fetchCollections()
                          }
                        });
                      },
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: Color(randomColorCode),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(18.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                collection,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto-Condensed',
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
