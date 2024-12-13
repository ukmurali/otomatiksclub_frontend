import 'package:flutter/material.dart';
import 'package:otomatiksclub/widgets/bottom_sheet.dart';
import 'package:otomatiksclub/widgets/price_plan_card.dart';

class PricePlanPage extends StatefulWidget {
  const PricePlanPage({super.key});

  @override
  _PricePlanPageState createState() => _PricePlanPageState();
}

class _PricePlanPageState extends State<PricePlanPage> {
  final List<Map<String, dynamic>> plans = [
    {
      'name': 'Bronze Plan',
      'description': 'This plan allows you to post in one club of your choice while enjoying the ability to view posts from all clubs throughout the year.',
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
      'description': 'This plan lets you post in all clubs and enjoy unlimited club views for a year.',
      'discount': '50%',
      'price': 'Rs. 999',
      'discountPrice': 'Rs. 499',
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
          'This lifetime plan allows you to post in one club of your choice and view posts from all clubs.',
      'discount': '60%',
      'price': 'Rs. 1499',
      'discountPrice': 'Rs. 599',
      'planMode': 'LifeTime',
      'color': LinearGradient(
        colors: [Colors.amber.shade700, Colors.amber.shade200],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'isDefault': false,
    },
    {
      'name': 'Diamond Plan',
      'description': 'This lifetime plan lets you post in all clubs and enjoy unlimited access to view all club posts.',
      'discount': '60%',
      'price': 'Rs. 2499',
      'discountPrice': 'Rs. 999',
      'planMode': 'LifeTime',
      'color': LinearGradient(
        colors: [Colors.purple.shade700, Colors.purple.shade300],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'isDefault': false,
    },
    {
      'name': 'Custom Plan',
      'description': 'This custom plan lets you select your clubs for posting while enjoying unlimited access to view all club posts, available annually or for a lifetime.',
      'discount': '',
      'price': '',
      'discountPrice': 'Rs.0',
      'planMode': 'LifeTime',
      'color': LinearGradient(
        colors: [Colors.green.shade700, Colors.green.shade300],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'isDefault': false,
    }
  ];

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
