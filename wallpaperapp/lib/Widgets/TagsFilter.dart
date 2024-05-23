
import 'package:flutter/material.dart';
import 'package:wallpaperapp/Utils/app_colors.dart';

class TagsFilter extends StatelessWidget {
  final List<String> tags;
  final List<String> selectedTags;
  final ValueChanged<String> onTagSelected;

  const TagsFilter({super.key,
    required this.tags,
    required this.selectedTags,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tags.map((tag) {
          final isSelected = selectedTags.contains(tag);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Theme(
              data: ThemeData(
                inputDecorationTheme: const InputDecorationTheme(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: sliderColor, width: 1.0), // Adjust the width as needed
                  ),
                ),
              ),
              child: InputChip(
                label: Text(
                  tag,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                      fontFamily: 'Roboto-Condensed-Light', letterSpacing: 1
                  ),
                ),
                backgroundColor: isSelected ? sliderColor : Colors.grey[200],
                onSelected: (value) {
                  onTagSelected(tag);
                },
                selected: isSelected,
                selectedColor: sliderColor,
                selectedShadowColor: Colors.white, // Change the selected icon color to white
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
