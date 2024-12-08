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
      'name': 'Diamond Plan',
      'description': 'The ultimate plan for users who want everything.',
      'discount': '60%',
      'price': 'Rs. 2499',
      'discountPrice': 'Rs. 999',
      'planMode': 'Life Time',
      'color': LinearGradient(
        colors: [Colors.purple.shade700, Colors.purple.shade300],
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
        title: const Text(
          'Pricing Plans',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[400],
        child: Padding(
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
                onChoosePlan: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.0),
                      ),
                    ),
                    builder: (context) {
                      return BottomSheetContent(plan: plan);
                    },
                  );
                },
              );
            },
          ),
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
  final Gradient color;
  final bool isDefault;
  final VoidCallback onChoosePlan;

  const PlanCard({
    super.key,
    required this.name,
    required this.description,
    required this.discount,
    required this.price,
    required this.discountPrice,
    required this.planMode,
    required this.color,
    required this.isDefault,
    required this.onChoosePlan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Row(
          children: [
            Container(
              width: 25,
              height: 135,
              decoration: BoxDecoration(
                gradient: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          discountPrice,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '/$planMode',
                          style: const TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                          ),
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
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '$discount OFF',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: AppColors.textColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: onChoosePlan,
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
    );
  }
}

class BottomSheetContent extends StatelessWidget {
  final Map<String, dynamic> plan;

  const BottomSheetContent({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // Ensures full width for the children
        children: [
          // Plan name with bold styling
          Text(
            plan['name'],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Plan description
          Text(plan['description']),
          const SizedBox(height: 16),

          // Table View - Column Headers
          Table(
            border: TableBorder.all(), // Adds border around each cell
            columnWidths: const {
              0: FixedColumnWidth(100), // Club Name column width
              1: FixedColumnWidth(70), // Post Create column width
              2: FixedColumnWidth(70), // Post View column width
              3: FixedColumnWidth(70), // Action column width
            },
            children: [
              // Table Header
              const TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Club Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'Post \nCreate',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'Post \nView',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Action',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              // Table Row with data (this could be dynamic based on your data)
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('Robotics')),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                        child: Icon(Icons.check,
                            color: Colors.green)), // Green Tick for Post Create
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                        child: Icon(Icons.check,
                            color: Colors.green)), // Green Tick for Post View
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Checkbox(
                        value: true,
                        onChanged: (bool? value) {},
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('Art & Craft')),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                        child: Icon(Icons.cancel,
                            color: Colors.red)), // Green Tick for Post Create
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                        child: Icon(Icons.check,
                            color: Colors.green)), // Green Tick for Post View
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: Checkbox(
                      value: true,
                      onChanged: (bool? value) {},
                      activeColor:
                          AppColors.primaryColor, // Custom color from AppColors
                      checkColor:
                          AppColors.textColor, // Custom color for check mark
                    )),
                  ),
                ],
              ),
              // More rows can be added here dynamically
            ],
          ),
          const SizedBox(height: 16),

          // Row with both Cancel and Confirm buttons
          Row(
            children: [
              // Cancel Button
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.textColor, // Button background color
                    foregroundColor: AppColors.primaryColor, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // Rounded corners
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // Handle cancel action here
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10), // Space between buttons
              // Confirm Plan Button
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primaryColor, // Button background color
                    foregroundColor: AppColors.textColor, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // Rounded corners
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // Handle plan confirmation here
                  },
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
