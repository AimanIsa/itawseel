import 'package:flutter/material.dart';
import 'package:itawseel/themes/colors.dart';

class OrderCard extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final double offeredChargeFees;
  final Function(String, double) onUpdateOfferedChargeFees;
  final Function(String, double) onOfferChargeFees;

  const OrderCard({
    Key? key,
    required this.orderData,
    required this.onUpdateOfferedChargeFees,
    required this.onOfferChargeFees,
    required this.offeredChargeFees,
  }) : super(key: key);

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  double _offeredChargeFee = 3.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order ID: ${widget.orderData['orderId']}'),
                  Row(
                    children: [
                      const Text('Location:  '),
                      Text(
                        '${widget.orderData['location']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Text('Items:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (widget.orderData['fooditem'] as List<dynamic>?)
                            ?.length ??
                        0, // Ensure length is available
                    itemBuilder: (context, index) {
                      final foodItems =
                          widget.orderData['fooditem'] as List<dynamic>?;
                      if (foodItems != null && index < foodItems.length) {
                        final item = foodItems[index];
                        return Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(item['name']),
                                  const Spacer(),
                                  Text(
                                    '${item['quantity']} x RM ${item['price'].toStringAsFixed(2)}',
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const SizedBox(); // Or display an error message
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Total price: '),
                      Text(
                        'RM ${widget.orderData['totalPrice']} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text("Fees: "),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _offeredChargeFee -=
                                1.0; // Update user's specific fee
                          });
                          widget.onUpdateOfferedChargeFees(
                            widget.orderData['orderId'],
                            _offeredChargeFee, // Use the user's specific fee
                          );
                        },
                        icon: const Icon(Icons.remove_circle_rounded),
                        color: primaryColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _offeredChargeFee.toStringAsFixed(1),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _offeredChargeFee +=
                                1.0; // Update user's specific fee
                          });
                          widget.onUpdateOfferedChargeFees(
                            widget.orderData['orderId'],
                            _offeredChargeFee, // Use the user's specific fee
                          );
                        },
                        icon: const Icon(Icons.add_circle_rounded),
                        color: primaryColor,
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        onPressed: () {
                          widget.onOfferChargeFees(
                              widget.orderData['orderId'], _offeredChargeFee);
                        },
                        child: const Text(
                          'Offer',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
