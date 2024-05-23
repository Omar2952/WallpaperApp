import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wallpaperapp/Models/user_model.dart';
import 'package:wallpaperapp/Utils/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaperapp/Utils/firebase_service.dart';
import 'package:wallpaperapp/Views/profile_page.dart';
import 'package:wallpaperapp/Widgets/CustomAppbar.dart';
import '../Models/wallpaper_model.dart';
import '../Widgets/PlaceHolderImage.dart';
import 'ImageScreen.dart';

class WallpaperPage extends StatefulWidget {
  const WallpaperPage({super.key});

  @override
  State<WallpaperPage> createState() => _WallpaperPageState();
}

class _WallpaperPageState extends State<WallpaperPage>  with AutomaticKeepAliveClientMixin  {

  List<PixabayImage> pixaBayImages = [];
  List<PixabayImage> preloadedImages = [];
  int currentPage = 1;
  bool isLoading = false;
  bool isLoadingMore = false;
  OverlayEntry? _overlayEntry;
  UserModel? userData;
  final ScrollController _scrollController = ScrollController();


  double randomHeight() {
    double minHeight = 280.0;
    double maxHeight = 350.0;
    double randomHeight = minHeight + Random().nextDouble() * (maxHeight - minHeight);
    return randomHeight;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!isLoadingMore) {
          setState(() {
            pixaBayImages.addAll(preloadedImages);
            preloadedImages.clear();
          });
          loadMoreImages();
        }
      }
    });

    preloadNextImages();
    fetchImagesFromPixaBay();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pixaBayImages = [];
    preloadedImages = [];
    currentPage = 1;
    isLoading = false;
    isLoadingMore = false;
    _overlayEntry;
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        appBar: userData != null ? CustomAppBar(name: userData!.name, imageUrl: userData!.profileImageUrl,
        actions: [
          IconButton(onPressed: () async {
            bool? result = await Get.to(() => ProfilePage());
            if (result == true) {
              userData = (await FireStoreService().getUserDataFromFirebase())!;
              setState(() {});
            }
          }, icon: const Icon(Icons.arrow_forward_ios, color: whiteColor,))
        ],
        ) : AppBar(),
        body: LiquidPullToRefresh(
          backgroundColor: sliderColor,
          color: Colors.deepPurple,
          height: 100,
          animSpeedFactor: 2,
          showChildOpacityTransition: false,
          onRefresh: refreshImages,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: StaggeredGridView.countBuilder(
              controller: _scrollController,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              itemCount: pixaBayImages.length,
              itemBuilder: (context, index) {
                PixabayImage currentImage = pixaBayImages[index];
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
          ),
        ),
      ),
    );
  }

  Future<void> fetchImagesFromPixaBay() async {
    setState(() {
      isLoading = true;
      isLoadingMore = true;

    });

    String pixabayApiUrl =
        'https://pixabay.com/api/?key=38601396-1b0f193056b8aa73f4bc87cf3&page=$currentPage&per_page=20&order=popular&safesearch=true';

    http.Response pixaBayResponse = await http.get(Uri.parse(pixabayApiUrl));
    Map<String, dynamic> pixaBayData = json.decode(pixaBayResponse.body);
    List<PixabayImage> fetchedImages = List<PixabayImage>.from(
      pixaBayData['hits'].map((imageJson) => PixabayImage.fromJson(imageJson)),
    );
    userData = (await FireStoreService().getUserDataFromFirebase())!;
    setState(() {
      pixaBayImages.addAll(fetchedImages);
      isLoading = false;
      currentPage++;
      isLoadingMore = false;
    });
  }

  Future<void> loadMoreImages() async {
    if (isLoading) return;
    isLoadingMore = true;
    setState(() {
      isLoading = true;
    });
    await preloadNextImages();
    await fetchImagesFromPixaBay();
  }

  Future<void> preloadNextImages() async {
    String nextApiUrl = 'https://pixabay.com/api/?key=38601396-1b0f193056b8aa73f4bc87cf3&page=${currentPage + 1}&per_page=20&order=popular&safesearch=true';
    http.Response nextResponse = await http.get(Uri.parse(nextApiUrl));
    Map<String, dynamic> nextData = json.decode(nextResponse.body);
    List<PixabayImage> nextImages = List<PixabayImage>.from(
      nextData['hits'].map((imageJson) => PixabayImage.fromJson(imageJson)),
    );
    preloadedImages.addAll(nextImages);
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

  Future<void> refreshImages() async {
    setState(() {
      pixaBayImages.clear();
    });
    await fetchImagesFromPixaBay();
  }

  @override
  bool get wantKeepAlive => true;
}
