import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:otomatiksclub/api/club_service/api_club_service.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:otomatiksclub/widgets/custom_snack_bar.dart';
import 'package:otomatiksclub/widgets/loading_indicator.dart';
import 'package:otomatiksclub/widgets/no_internet_view.dart';

class BottomSheetContent extends StatefulWidget {
  const BottomSheetContent({super.key, required this.plan});

  final Map<String, dynamic> plan;

  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  bool _isLoading = false;
  List<Map<String, dynamic>> tableData = [];

  @override
  void initState() {
    super.initState();
    _fetchClubs();
  }

  Future<void> _fetchClubs() async {
    try {
      setState(() => _isLoading = true);
      Map<String, dynamic>? result;
      result = await ApiClubService.fetchClubs();
      if (result != null && result['statusCode'] == 200) {
        final List<dynamic> clubs =
            List<Map<String, dynamic>>.from(json.decode(result['body']));
        setState(() {
          for (var club in clubs) {
            tableData.add({
              "clubName": club['name'],
              "postCreate": false,
              "checked": false
            });
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
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: _isLoading,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.plan['name'],
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      widget.plan['discountPrice'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '/${widget.plan['planMode']}',
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
                      ],
                    ),
                    ...tableData.map((data) {
                      return TableRow(
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(child: Text(data["clubName"]))),
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Confirm'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_isLoading) const LoadingIndicator(),
      ],
    );
  }
}
