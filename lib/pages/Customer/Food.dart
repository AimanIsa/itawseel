class FoodItem {
  final String assetpath;
  final String name;
  final double price;

  FoodItem({required this.assetpath, required this.name, required this.price});
}

class CartItem {
  final String itemName;
  final double itemPrice;
  final String image;
  int quantity;

  CartItem(
      {required this.itemName,
      required this.itemPrice,
      required this.image,
      required this.quantity});

  double getTotalPrice() => itemPrice * quantity;
}
