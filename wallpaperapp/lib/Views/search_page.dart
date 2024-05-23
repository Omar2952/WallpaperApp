import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wallpaperapp/Utils/app_colors.dart';
import '../Models/wallpaper_model.dart';
import '../Widgets/PlaceHolderImage.dart';
import '../Widgets/TagsFilter.dart';
import 'ImageScreen.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  final TextEditingController _searchController = TextEditingController();
  var keyboardVisibilityController = KeyboardVisibilityController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  late StreamSubscription<bool> keyboardSubscription;
  List<PixabayImage> pixaBayImages = [];
  List<PixabayImage> preloadedImages = [];
  int currentPage = 1;
  bool isLoading = false;
  bool isLoadingMore = false;
  OverlayEntry? _overlayEntry;
  bool _isFocused = false;
  bool isSearchEmpty = false;
  bool isKeyboardVisible = false;
  List<String> _searchHistory = [];
  List<String> allTags = [
    'Famous',
    'Popular',
    'Anime',
    'Gaming',
    'Background',
    'Travel',
    'Latest',
    'Food',
    'Animals',
    'Music',
    'Health',
  ];
  List<String> selectedTags = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _searchFocusNode.addListener(_onFocusChange);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!isLoadingMore) {
          setState(() {
            pixaBayImages.addAll(preloadedImages);
            preloadedImages.clear();
          });
          loadMoreImages(_searchController.text.toString());
        }
      }
    });
    preloadNextImages(_searchController.text.toString());

    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
          setState(() {
            isKeyboardVisible = true;
          });
        });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextFormField(
                focusNode: _searchFocusNode,
                controller: _searchController,
                autofocus: false,
                cursorColor: sliderColor,
                decoration: InputDecoration(
                  suffixIcon: GestureDetector(
                    onTap: () {
                      if (_searchController.text.toString().isNotEmpty) {
                        setState(() {
                          _saveSearchHistory(_searchController.text.toString());
                          clearImages().then((value) => {
                            fetchImagesFromPixaBay(
                                _searchController.text.toString())
                          });
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: _isFocused ? sliderColor : Colors.grey,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                    BorderSide(width: .5, color: sliderColor),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  fillColor: Colors.grey.shade100,
                  hintText: 'Search Images Here ...',
                  hintStyle: const TextStyle(
                      fontSize: 16, fontFamily: 'Roboto-Condensed-Light'),
                  filled: true,
                ),
                onFieldSubmitted: (query) {
                  setState(() {
                    _saveSearchHistory(_searchController.text.toString());
                    clearImages().then((value) => {
                      fetchImagesFromPixaBay(
                          _searchController.text.toString())
                    });
                  });
                },
                onChanged: (query) {
                  if (query.isEmpty) {
                    clearImages();
                  }
                },
              ),
            ),
            if (_searchFocusNode.hasFocus && _searchHistory.isNotEmpty)
              SizedBox(
                height: _searchHistory.length * 56.0 <= 200
                    ? _searchHistory.length * 56.0
                    : 200,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20)),
                    child: ListView.builder(
                      itemCount: _searchHistory.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_searchHistory[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _searchHistory.removeAt(index);
                                _removeSearchHistoryItem(_searchHistory[index]);
                              });
                            },
                          ),
                          onTap: () {
                            _searchController.text = _searchHistory[index];
                            _searchController.selection =
                                TextSelection.fromPosition(
                                  TextPosition(offset: _searchController.text.length),
                                );
                            _searchFocusNode.requestFocus();
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TagsFilter(
                tags: allTags,
                selectedTags: selectedTags,
                onTagSelected: (tag) {
                  if (selectedTags.contains(tag)) {
                    setState(() {
                      selectedTags.remove(tag);
                    });
                  } else {
                    setState(() {
                      selectedTags.add(tag);
                    });
                  }
                  setState(() {
                    clearImages().then((value) =>
                    {fetchImagesFromPixaBay(selectedTags.toString())});
                  });
                },
              ),
            ),
            isSearchEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Visibility(
                  visible: !_isFocused,
                  child: Lottie.asset(
                    'assets/Animations/not_avaliable.json',
                    width: 300,
                    height: 300,
                    // Other optional properties
                  ),
                ),
              ),
            )
                : isLoading
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(child: CircularProgressIndicator()),
            )
                : Expanded(
              child: LiquidPullToRefresh(
                backgroundColor: sliderColor,
                color: Colors.deepPurple,
                height: 100,
                animSpeedFactor: 2,
                showChildOpacityTransition: false,
                onRefresh: refreshPage,
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
                                  builder: (context) =>
                                      ImageScreen(image: currentImage),
                                ),
                              );
                            },
                            onLongPress: () => _showLargerImage(
                                currentImage.largeImageURL),
                            onLongPressUp: _hideLargerImage,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                currentImage.largeImageURL,
                                fit: BoxFit.cover,
                                height: randomHeight(),
                                errorBuilder:
                                    (context, error, stackTrace) {
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
                    staggeredTileBuilder: (index) =>
                    const StaggeredTile.fit(1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchImagesFromPixaBay(String query) async {
    setState(() {
      isSearchEmpty = false;
      isLoading = true;
    });
    String pixabayApiUrl =
        'https://pixabay.com/api/?key=38601396-1b0f193056b8aa73f4bc87cf3&page=$currentPage&per_page=20&q=$query&safesearch=true';

    http.Response pixaBayResponse = await http.get(Uri.parse(pixabayApiUrl));
    Map<String, dynamic> pixaBayData = json.decode(pixaBayResponse.body);
    List<PixabayImage> fetchedImages = List<PixabayImage>.from(
      pixaBayData['hits'].map((imageJson) => PixabayImage.fromJson(imageJson)),
    );

    if (fetchedImages.isEmpty && _searchController.text.toString().isNotEmpty) {
      setState(() {
        isSearchEmpty = true;
        isLoading = false;
      });
    } else {
      setState(() {
        pixaBayImages.addAll(fetchedImages);
        isLoading = false;
        currentPage++;
      });
    }
  }

  Future<void> loadMoreImages(String query) async {
    if (isLoading) return;
    isLoadingMore = true;
    setState(() {
      isLoading = true;
    });
    await preloadNextImages(query);
    await fetchImagesFromPixaBay(query);
  }

  Future<void> preloadNextImages(String query) async {
    String nextApiUrl =
        'https://pixabay.com/api/?key=38601396-1b0f193056b8aa73f4bc87cf3&page=$currentPage&per_page=20&q=$query';
    http.Response nextResponse = await http.get(Uri.parse(nextApiUrl));
    Map<String, dynamic> nextData = json.decode(nextResponse.body);
    List<PixabayImage> nextImages = List<PixabayImage>.from(
      nextData['hits'].map((imageJson) => PixabayImage.fromJson(imageJson)),
    );
    preloadedImages.addAll(nextImages);
  }

  double randomHeight() {
    double minHeight = 280.0;
    double maxHeight = 350.0;
    double randomHeight =
        minHeight + Random().nextDouble() * (maxHeight - minHeight);
    return randomHeight;
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

  Future<void> clearImages() async {
    setState(() {
      isSearchEmpty = false;
      pixaBayImages.clear();
      preloadedImages.clear();
      currentPage = 1;
    });
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _searchFocusNode.hasFocus;
    });
  }

  Future<void> refreshPage() async {
    setState(() {
      clearImages().then((value) =>
      {fetchImagesFromPixaBay(_searchController.text.toString())});
    });
  }

  void _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  void _saveSearchHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_searchHistory.contains(query)) {
      _searchHistory.insert(0, query);
      prefs.setStringList('searchHistory', _searchHistory);
    }
  }

  void _removeSearchHistoryItem(String query) async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory.remove(query);
    prefs.setStringList('searchHistory', _searchHistory);
  }

}
