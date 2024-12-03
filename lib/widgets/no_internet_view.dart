import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:otomatiksclub/api/api_client.dart';
import 'package:otomatiksclub/colors/app_colors.dart';

class NoInternetPage extends StatefulWidget {
  const NoInternetPage({super.key});

  @override
  _NoInternetPageState createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage> {
  Future<void> _retry(BuildContext context) async {
    Map<String, dynamic>? result = await ApiClient.checkConnectivity();
    if (result['statusCode'] == 200) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white.withOpacity(1.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/no_internet.json', // Path to your Lottie file
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
              const Text('Please connect to the internet and try again',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              FloatingActionButton(
                onPressed: () => _retry(context),
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: const Icon(
                  Icons.refresh,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              const Text('Retry',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
    );
  }
}
