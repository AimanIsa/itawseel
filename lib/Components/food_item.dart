import 'package:flutter/material.dart';
import 'package:itawseel/themes/colors.dart';

class FoodMenus extends StatelessWidget {
  final String food;
  final String price;
  //final void Function()? onTap;
  const FoodMenus({
    super.key,
    required this.food,
    required this.price,
    //required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor)),
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'lib/Images/Food.png',
                width: 30,
              ),
              Text(
                food,
                style: TextStyle(
                    color: primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                price,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
              ElevatedButton(onPressed: () {}, child: const Text("+"))
            ],
          ),
        ),
      ),
    );
  }
}
