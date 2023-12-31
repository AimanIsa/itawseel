// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:itawseel/pages/Customer/cart.dart';
import 'package:itawseel/themes/colors.dart';
// import 'package:quickalert/models/quickalert_type.dart';
// import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'Food.dart';

class MenuPage extends StatefulWidget {
  final List<FoodItem> foodItems;

  const MenuPage({required this.foodItems});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<CartItem> cartItems = [];

  Card buildButton({
    required onTap,
    required title,
    required text,
  }) {
    return Card(
      shape: const StadiumBorder(),
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: ListTile(
        onTap: onTap,
        title: Text(title ?? ""),
        subtitle: Text(text ?? ""),
        trailing: const Icon(
          Icons.keyboard_arrow_right_rounded,
        ),
      ),
    );
  }

  void addToCart(FoodItem item) {
    final index =
        cartItems.indexWhere((cartItem) => cartItem.itemName == item.name);
    final existingItem = index >= 0 ? cartItems[index] : null;
    if (existingItem != null) {
      setState(() {
        existingItem.quantity++;
      });
    } else {
      setState(() {
        cartItems.add(CartItem(
            itemName: item.name,
            itemPrice: item.price,
            image: item.assetpath,
            quantity: 1));
        // QuickAlert.show(
        //   context: context,
        //   type: QuickAlertType.success,
        //   text: 'Add to Cart',
        //   autoCloseDuration: const Duration(seconds: 2),
        //   showConfirmBtn: false,
        // );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The item has been added to the cart.'),
          duration: Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Menus',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: widget.foodItems.length,
          itemBuilder: (context, index) {
            final foodItem = widget.foodItems[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Column(
                children: [
                  const SizedBox(height: 7),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 7),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: ListTile(
                          leading: Image.asset(foodItem.assetpath,
                              width: 70, height: 70),
                          title: Text(
                            foodItem.name,
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle:
                              Text('\RM ${foodItem.price.toStringAsFixed(2)}'),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shadowColor: Colors.black,
                                minimumSize: const Size(35, 35),
                                backgroundColor: primaryColor,
                                shape: const CircleBorder(),
                                side: BorderSide(color: primaryColor)),
                            onPressed: () => addToCart(foodItem),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(30.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              )),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CartPage(cartItems: cartItems))),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Cart",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.shopping_cart,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
