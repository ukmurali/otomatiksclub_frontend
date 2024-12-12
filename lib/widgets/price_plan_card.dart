import 'package:flutter/material.dart';
import 'package:otomatiksclub/colors/app_colors.dart';

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
              height: 105,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                    if (name != 'Custom Plan')
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
                          if (name != 'Custom Plan')
                            Text(
                              '/$planMode',
                              style: const TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      )
                    else
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    if (name != 'Custom Plan')
                      Row(
                        children: [
                          Text(
                            'Price: $price',
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$discount OFF',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
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
