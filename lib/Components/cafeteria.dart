import 'package:flutter/material.dart';

class Cafeteria extends StatelessWidget {
  final AssetImage cafeImage;
  final void Function()? onTap;
  const Cafeteria({super.key, required this.cafeImage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(children: [
          Image(
            image: cafeImage,
            width: 150,
            height: 150,
          ),
        ]),
      ),
    );
  }
}
