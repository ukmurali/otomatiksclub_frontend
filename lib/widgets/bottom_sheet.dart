import 'package:flutter/material.dart';
import 'package:otomatiksclub/colors/app_colors.dart';

class BottomSheetContent extends StatefulWidget {
  const BottomSheetContent({super.key, required this.plan});

  final Map<String, dynamic> plan;

  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  List<Map<String, dynamic>> tableData = [
    {"clubName": "Robotics", "postCreate": false, "checked": false},
    {"clubName": "AI Club", "postCreate": false, "checked": false},
    {"clubName": "Tech Club", "postCreate": false, "checked": false},
  ];

  int _selectedPlanModeIndex = 0; // 0 for Yearly, 1 for Lifetime
  int _priceYearly = 0;
  int _priceLifeTime = 0;

  @override
  void initState() {
    super.initState();
    _initializeDefaults();
  }

  void _initializeDefaults() {
    if (widget.plan['name'] == 'Silver Plan' ||
        widget.plan['name'] == 'Diamond Plan') {
      for (var data in tableData) {
        data["postCreate"] = true;
        data["checked"] = true;
      }
    } else if (widget.plan['name'] == 'Bronze Plan') {
      for (var data in tableData) {
        data["postCreate"] = false;
        data["checked"] = false;
      }
    }
  }

  int _getCustomPlan(bool? value, int price, int priceValue, int incrementPrice) {
    price = price == 0
        ? priceValue + price
        : price + (value == true ? incrementPrice : -incrementPrice);
    return price <= 0 ? 0 : price;
  }

  void _setPlan(List<Map<String, dynamic>> tableData, Map<String, dynamic> data,
      String planName) {
    if (planName == 'Bronze Plan' || planName == 'Gold Plan') {
      for (var item in tableData) {
        if (item != data) {
          item["checked"] = false;
          item["postCreate"] = false;
        }
      }
    }
  }

  bool _isAnyClubSelected() {
    return tableData.any((data) => data["checked"] == true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.plan['name'],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          widget.plan['name'] == 'Custom Plan'
              ? ToggleButtons(
                  isSelected: [
                    _selectedPlanModeIndex == 0,
                    _selectedPlanModeIndex == 1
                  ],
                  onPressed: (int index) {
                    setState(() {
                      _selectedPlanModeIndex = index;
                      widget.plan['discountPrice'] = _selectedPlanModeIndex == 0
                          ? 'Rs. $_priceYearly'
                          : 'Rs. $_priceLifeTime';
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  fillColor: AppColors.primaryColor,
                  selectedColor: AppColors.textColor,
                  color: Colors.black,
                  constraints: const BoxConstraints(minHeight: 36),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Yearly'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Lifetime'),
                    ),
                  ],
                )
              : const SizedBox(),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Rs. ${widget.plan['name'] == 'Custom Plan' ? _selectedPlanModeIndex == 0 ? _priceYearly: _priceLifeTime : widget.plan['discountPrice']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                _selectedPlanModeIndex == 0 ? '/Yearly' : '/Lifetime',
                style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(widget.plan['description']),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(),
            columnWidths: const {
              0: FixedColumnWidth(100),
              1: FixedColumnWidth(70),
              2: FixedColumnWidth(70),
              3: FixedColumnWidth(70),
            },
            children: [
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
              ...tableData.map((data) {
                return TableRow(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(child: Text(data["clubName"]))),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Icon(
                          data["postCreate"] ? Icons.check : Icons.close,
                          color: data["postCreate"] ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Icon(
                          Icons.check,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Checkbox(
                          value: data["checked"],
                          activeColor: AppColors.primaryColor,
                          checkColor: AppColors.textColor,
                          onChanged: (widget.plan['name'] == 'Silver Plan' ||
                                  widget.plan['name'] == 'Diamond Plan')
                              ? null
                              : (bool? value) {
                                  setState(() {
                                    data["checked"] = value;
                                    data["postCreate"] = value ?? false;
                                    _priceYearly = _getCustomPlan(value, _priceYearly, 99, 100);
                                    _priceLifeTime = _getCustomPlan(value, _priceLifeTime, 599, 600);
                                    _setPlan(
                                        tableData, data, widget.plan['name']);
                                  });
                                },
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textColor,
                    foregroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.textColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: _isAnyClubSelected()
                      ? () {
                          Navigator.pop(context);
                        }
                      : null,
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
