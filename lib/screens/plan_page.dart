import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:otomatiksclub/api/pricing_plan_service/api_pricing_plan_service.dart';
import 'package:otomatiksclub/widgets/bottom_sheet.dart';
import 'package:otomatiksclub/widgets/custom_snack_bar.dart';
import 'package:otomatiksclub/widgets/loading_indicator.dart';
import 'package:otomatiksclub/widgets/no_internet_view.dart';
import 'package:otomatiksclub/widgets/price_plan_card.dart';

class PricePlanPage extends StatefulWidget {
  const PricePlanPage({super.key});

  @override
  _PricePlanPageState createState() => _PricePlanPageState();
}

class _PricePlanPageState extends State<PricePlanPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPricingPlans();
  }

  MaterialColor getPlanName(String planName) {
    switch (planName) {
      case 'Bronze Plan':
        return Colors.red;
      case 'Silver Plan':
        return Colors.grey;
      case 'Gold Plan':
        return Colors.amber;
      case 'Diamond Plan':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

  LinearGradient getPlanColor(String planName) {
    MaterialColor materialColor = getPlanName(planName);
    return LinearGradient(
      colors: [materialColor.shade700, materialColor.shade300],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  List<Map<String, dynamic>> plans = [];

  Future<void> _fetchPricingPlans() async {
    try {
      setState(() => _isLoading = true);
      Map<String, dynamic>? result;
      result = await ApiPricingPlanService.fetchPricingPlans();
      if (result != null && result['statusCode'] == 200) {
        final List<dynamic> pricingPlans =
            List<Map<String, dynamic>>.from(json.decode(result['body']));
        setState(() {
          for (var plan in pricingPlans) {
            plans.add(
              {
                'name': plan['name'],
                'description': plan['description'],
                'discount': '${plan['discount']}%',
                'price': 'Rs. ${plan['price']}',
                'discountPrice': 'Rs. ${plan['discountPrice']}',
                'planMode': plan['planMode'],
                'color': getPlanColor(plan['name'])
              },
            );
          }
          _isLoading = false;
        });
      } else {
        if (result?['body'] == 'Exception: No internet connection available') {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NoInternetPage(),
              ),
            );
          }
        } else {
          CustomSnackbar.showSnackBar(context, result?['body'], false);
        }
        return;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isLoading,
            child: Container(
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
          ),
          if (_isLoading) const LoadingIndicator(),
        ],
      ),
    );
  }
}
