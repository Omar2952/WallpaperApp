
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wallpaperapp/Utils/app_colors.dart';

import '../Utils/text_style.dart';



class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final String imageUrl;
  final Color backgroundColor;
  final List<IconButton> actions;
  final double? elevation;
  final Function()? onTap;

  const CustomAppBar({
    super.key,
    required this.name,
    required this.imageUrl,
    this.backgroundColor = sliderColor,
    this.actions = const [],
    this.onTap, this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation ?? 0.0,
      centerTitle: false,
      leading: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              backgroundColor: sliderColor,
              radius: 40.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                color: Colors.white,
                              ),
                            );
                          }
                        },
                      ),
                    )
                  else
                    const Icon(Icons.image),
                ],
              ),
            )
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          const Text(
            'Good Day!',
            style: TextStyle(
              fontSize: 14.0,
              color: sliderColor,
              fontWeight: FontWeight.w400,
              fontFamily: regular,
            ),
          ),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontFamily: bold,
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
