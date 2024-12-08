import 'package:flutter/material.dart';
import 'package:otomatiksclub/colors/app_colors.dart';

class PricePlanPage extends StatelessWidget {
  final List<Map<String, dynamic>> plans = [
    {
      'name': 'Bronze Plan',
      'description': 'The best plan for premium users with all features.',
      'discount': '50%',
      'price': 'Rs. 199',
      'discountPrice': 'Rs. 99',
      'planMode': 'Yearly',
      'color': LinearGradient(
        colors: [Colors.red.shade700, Colors.red.shade300],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'isDefault': true,
    },
    {
      'name': 'Silver Plan',
      'description': 'A budget-friendly plan for basic features.',
      'discount': '60%',
      'price': 'Rs. 375',
      'discountPrice': 'Rs. 149',
      'planMode': 'Yearly',
      'color': const LinearGradient(
        colors: [
          Color.fromARGB(255, 62, 55, 55),
          Color.fromARGB(255, 90, 90, 90)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'isDefault': false,
    },
    {
      'name': 'Gold Plan',
      'description':
          'A mid-tier plan with essential features for professionals.',
      'discount': '50%',
      'price': 'Rs. 999',
      'discountPrice': 'Rs. 499',
      'planMode': 'Life Time',
      'color': LinearGradient(
        colors: [Colors.amber.shade700, Colors.amber.shade200],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'isDefault': false,
    },
    {
      'name': 'Platinum Plan',
      'description': 'The ultimate plan for users who want everything.',
      'discount': '60%',
      'price': 'Rs. 2499',
      'discountPrice': 'Rs. 999',
      'planMode': 'Life Time',
      'color': LinearGradient(
        colors: [Colors.green.shade700, Colors.green.shade300],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'isDefault': false,
    }
  ];

  PricePlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pricing Plans'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return PlanCard(
              name: plan['name'],
              description: plan['description'],
              discount: plan['discount'],
              price: plan['price'],
              discountPrice: plan['discountPrice'],
              planMode: plan['planMode'],
              color: plan['color'],
              isDefault: plan['isDefault'],
            );
          },
        ),
      ),
    );
  }
}

class PlanCard extends StatelessWidget {
  final String name;
  final String description;
  final String discount;
  final String price;
  final String discountPrice;
  final String planMode;
  final Gradient color; // Gradient type (can be used for the left-side bar)
  final bool isDefault;

  const PlanCard({
    super.key,
    required this.name,
    required this.description,
    required this.discount,
    required this.price,
    required this.discountPrice,
    required this.planMode,
    required this.color, // Gradient for the left-side bar
    required this.isDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        // Make the content scrollable
        padding: const EdgeInsets.only(right: 16.0),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: Row(
            children: [
              // Left side bar with color
              Container(
                width: 20, // Width of the left bar
                height: 130, // Full height
                decoration: BoxDecoration(
                  gradient: color, // Apply gradient to the left side bar
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                  ),
                ),
              ),

              // Right side content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            discountPrice,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '/ $planMode',
                            style: const TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 20),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price: $price',
                                  style: const TextStyle(
                                    decoration: TextDecoration
                                        .lineThrough, // Apply strikeout
                                    color: Colors
                                        .grey, // Optionally change color to grey or any other color for strikethrough
                                  ),
                                ),
                                Text(
                                  '$discount OFF',
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: AppColors.textColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    5), // Set the desired corner radius
                              ),
                            ),
                            onPressed: () {
                              // Handle Plan Selection
                            },
                            child: const Text('Choose Plan'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
