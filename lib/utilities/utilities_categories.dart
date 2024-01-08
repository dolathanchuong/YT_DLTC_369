// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../constants.dart';
import '../theme/theme_colors.dart';

class Categories extends StatefulWidget {
  final void Function(int) callback;
  final int trendingIndex;
  const Categories({
    super.key,
    required this.callback,
    required this.trendingIndex,
  });

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  List<String> categories = ["Trending", "Music", "Gaming", "Movies"];
  late int selectedCategoryIndex;

  @override
  void initState() {
    super.initState();
    selectedCategoryIndex = widget.trendingIndex;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) => buildCategory(index),
      ),
    );
  }

  Widget buildCategory(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategoryIndex = index;
          widget.callback(selectedCategoryIndex);
        });
      },
      child: widget.trendingIndex == index
          ? Align(
              child: Container(
                height: 38,
                width: 80,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), color: pink),
                child: Center(
                  child: Text(
                    categories[index],
                    style: const TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo'),
                  ),
                ),
              ),
            )
          : Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: Center(
                child: Text(
                  categories[index],
                  style: const TextStyle(
                      color: Color(0xff9e9e9e),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo'),
                ),
              ),
            ),
    );
  }
}
