import 'package:flutter/material.dart';
import 'package:wallpaperapp/Utils/app_colors.dart';


class CustomBottomNavigation extends StatefulWidget {
  final List<IconData> icons;
  final List<String> labels;
  final Function(int) onTap;
  final int currentIndex;

  const CustomBottomNavigation({
    Key? key,
    required this.icons,
    required this.labels,
    required this.onTap,
    required this.currentIndex,
  }) : super(key: key);

  @override
  _CustomBottomNavigationState createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation> {
  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.all(displayWidth * .04),
      height: displayWidth * .155,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        borderRadius: BorderRadius.circular(50),
      ),
      child: ListView.builder(
        itemCount: widget.icons.length,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: displayWidth * .02),
        itemBuilder: (context, index) => InkWell(
          onTap: () {
            widget.onTap(index);
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                curve: Curves.fastLinearToSlowEaseIn,
                width: index == widget.currentIndex
                    ? displayWidth * .32
                    : displayWidth * .18,
                alignment: Alignment.center,
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.fastLinearToSlowEaseIn,
                  height: index == widget.currentIndex ? displayWidth * .12 : 0,
                  width: index == widget.currentIndex ? displayWidth * .32 : 0,
                  decoration: BoxDecoration(
                    color: index == widget.currentIndex
                        ? Colors.purpleAccent.withOpacity(.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                curve: Curves.fastLinearToSlowEaseIn,
                width: index == widget.currentIndex
                    ? displayWidth * .31
                    : displayWidth * .18,
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(seconds: 1),
                          curve: Curves.fastLinearToSlowEaseIn,
                          width: index == widget.currentIndex
                              ? displayWidth * .13
                              : 0,
                        ),
                        AnimatedOpacity(
                          opacity: index == widget.currentIndex ? 1 : 0,
                          duration: const Duration(seconds: 1),
                          curve: Curves.fastLinearToSlowEaseIn,
                          child: Text(
                            index == widget.currentIndex
                                ? widget.labels[index]
                                : '',
                            style: const TextStyle(
                              color: sliderColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(seconds: 1),
                          curve: Curves.fastLinearToSlowEaseIn,
                          width: index == widget.currentIndex
                              ? displayWidth * .03
                              : 20,
                        ),
                        Icon(
                          widget.icons[index],
                          size: displayWidth * .076,
                          color: index == widget.currentIndex
                              ? sliderColor
                              : Colors.black26,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
