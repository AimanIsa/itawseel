import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itawseel/pages/Customer/detailsorder.dart';
import 'package:itawseel/themes/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'Food.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;

  const CartPage({super.key, required this.cartItems});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<CartItem> _cartItems = [];
  final String _selectedLocation = 'Location';

  @override
  void initState() {
    super.initState();
    // initialize cartItems here
  }

  void removeCartItem(int index) {
    setState(() {
      widget.cartItems.removeAt(index);
    });
  }

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

  void saveOrderToFirestore(List<CartItem> cartItem) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc().get();
      // Generate a unique order ID
      final orderId = FirebaseFirestore.instance.collection('orders').doc().id;
      final user = FirebaseAuth.instance.currentUser!;

// Create order data
      final orderData = {
        'location': _selectedLocation,
        'orderId': orderId,
        'totalPrice': getTotalPrice().toStringAsFixed(2),
        'timestamp': FieldValue.serverTimestamp(),
        'fooditem': widget.cartItems
            .map((item) => {
                  'name': item.itemName,
                  'quantity': item.quantity,
                  'price': item.itemPrice
                }) // Access quantity and price within each item
            .toList(),
        'offerStatus': '',
        'offered': FieldValue.arrayUnion([
          {
            'riderId': 'rider',
            'username': 'username',
            'imageUrl': 'default',
            'offeredChargeFees': 1,
          }
        ])
      };

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .set(orderData);

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.email) // Access the specific order document
          .update({'location': _selectedLocation});

      // Clear cart (optional)
      widget.cartItems.clear();
      // Navigate to selectrider.dart
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderDetails(
            orderID: orderId,
          ),
        ),
      );

      setState(() {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Order placed successfully!',
          // autoCloseDuration: const Duration(seconds: 2),
          showConfirmBtn: true,
        );
      });
    } catch (error) {
      // Handle errors gracefully
      // ignore: avoid_print
      print('Error saving order: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order. Please try again.'),
        ),
      );
    }
  }

  double getTotalPrice() => widget.cartItems
      .fold(0.0, (sum, cartItem) => sum + cartItem.getTotalPrice());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cart',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
            itemCount: widget.cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = widget.cartItems[index];
              return Padding(
                padding: const EdgeInsets.all(7.0),
                child: Card(
                  child: Column(
                    children: [
                      SizedBox(height: 5),
                      ListTile(
                        leading: Image.asset(
                          cartItem.image,
                          width: 50,
                          height: 50,
                        ),
                        title: Text(
                          cartItem.itemName,
                          style: TextStyle(
                              color: primaryColor, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            'Qty: ${cartItem.quantity} | Price: RM ${cartItem.itemPrice.toStringAsFixed(2)} | Total: RM ${cartItem.getTotalPrice().toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          color: primaryColor,
                          onPressed: () => removeCartItem(index),
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
              );
            }),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: primaryColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                SizedBox(width: 30),
                Text(
                  'Total: \RM ${getTotalPrice().toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                const Spacer(),
                Visibility(
                    visible: getTotalPrice() != 0.00,
                    child: ElevatedButton(
                      onPressed: () {
                        saveOrderToFirestore(_cartItems);
                      },
                      child: const Text('Checkout',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    )),
                const SizedBox(width: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
