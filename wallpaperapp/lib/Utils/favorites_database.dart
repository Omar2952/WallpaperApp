import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:wallpaperapp/Models/wallpaper_model.dart';

class FavoritesManager {
  final _favorites = GetStorage('favorites');

  List<PixabayImage> getFavorites() {
    List<dynamic> jsonList = _favorites.read('images') ?? <dynamic>[];
    return jsonList.map((json) => PixabayImage.fromJson(jsonDecode(json))).toList();
  }

  void addToFavorites(PixabayImage image) {
    List<dynamic> jsonList = _favorites.read('images') ?? <dynamic>[];
    jsonList.add(jsonEncode(image.toJson()));
    _favorites.write('images', jsonList);
  }

  void removeFromFavorites(PixabayImage image) {
    List<dynamic> jsonList = _favorites.read('images') ?? <dynamic>[];
    jsonList.removeWhere((json) => PixabayImage.fromJson(jsonDecode(json)).id == image.id);
    _favorites.write('images', jsonList);
  }


  bool isFavorite(PixabayImage image) {
    List<dynamic> jsonList = _favorites.read('images') ?? <dynamic>[];
    return jsonList.any((json) => PixabayImage.fromJson(jsonDecode(json)).id == image.id);
  }
}
