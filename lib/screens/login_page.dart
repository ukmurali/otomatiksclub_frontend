import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import 'package:otomatiksclub/api/user_service/api_user_service.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:otomatiksclub/constants.dart';
import 'package:otomatiksclub/screens/verify_otp_page.dart';
import 'package:otomatiksclub/widgets/custom_button.dart';
import 'package:otomatiksclub/widgets/custom_snack_bar.dart';
import 'package:otomatiksclub/widgets/custom_text_form_field.dart';
import 'package:otomatiksclub/widgets/loading_indicator.dart';
import 'package:otomatiksclub/widgets/no_internet_view.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import for URL handling

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState(); // Changed to public
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+91'; // Default to India country code
  bool _isLoading = false;
  final List<Map<String, String>> _countryCodes = [];

  @override
  void initState() {
    super.initState();
    _getCountryCodes();
  }

  Future<void> _getCountryCodes() async {
    final response = await ApiUserService.getCountryCodes();
    if (response != null && response['statusCode'] == 200) {
      final responseBody = response['body'];
      final parsedResponse = jsonDecode(responseBody);
      setState(() {
        // Clear any existing country codes to avoid duplicates
        _countryCodes.clear();

        // Add each country code from the response
        parsedResponse.forEach((country) {
          _countryCodes.add({
            'code': country['code'],
            'name': country['name'],
          });
        });
      });
    } else {
      if (response!['body'] == 'Exception: No internet connection available') {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NoInternetPage(),
            ),
          );
        }
      } else {
        CustomSnackbar.showSnackBar(context, response['body'], false);
      }
    }
  }

  final _formKey = GlobalKey<FormState>();

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      // Handle error
      developer.log('Error launching URL: $e');
    }
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a mobile number';
    }
    // Remove non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 10) {
      return 'Phone number cannot exceed 10 digits';
    }
    if (digitsOnly.length < 10) {
      return 'Phone number must be 10 digits';
    }
    return null;
  }

  Future<void> _validateAndSubmit() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      setState(() => _isLoading = true);
      // Handle valid input
      final phoneNumber = _phoneController.text.trim();
      final response = await ApiUserService.sendOtp(phoneNumber);
      final responseBody = response['body'] as String;
      if (mounted) {
        setState(() => _isLoading = false);
        if (response['statusCode'] != 200) {
          if (response['body'] ==
              'Exception: No internet connection available') {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NoInternetPage(),
                ),
              );
            }
          } else {
            CustomSnackbar.showSnackBar(context, responseBody, false);
          }
          return;
        }
        CustomSnackbar.showSnackBar(context, responseBody, true);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VerifyOtpPage(
                  phoneNumber: phoneNumber,
                  selectedCountryCode: _selectedCountryCode)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: Stack(children: [
          AbsorbPointer(
            absorbing: _isLoading,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Get the height of the keyboard
                final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                final contentHeight = constraints.maxHeight - keyboardHeight;

                return SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: keyboardHeight),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: contentHeight),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/images/image1.png',
                                height: 150.0,
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            const Text(
                              'Welcome to ${AppConstants.appName}',
                              style: TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20.0),
                            const Text(
                              'Please log in with your mobile number to get started',
                              style: TextStyle(fontSize: 14.0),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40.0),
                            Center(
                              child: SizedBox(
                                width: isWeb ? 400 : double.infinity,
                                child: Row(
                                  children: [
                                    // Expanded(
                                    //   flex: 1,
                                    //   child: Padding(
                                    //     padding:
                                    //         const EdgeInsets.only(bottom: 18.0),
                                    //     child: DropdownButton<String>(
                                    //       value: _selectedCountryCode,
                                    //       items: _countryCodes.map((country) {
                                    //         return DropdownMenuItem<String>(
                                    //           value: country['code'],
                                    //           child:
                                    //               Text(country['code'] ?? ''),
                                    //         );
                                    //       }).toList(),
                                    //       onChanged: (value) {
                                    //         setState(() {
                                    //           _selectedCountryCode = value!;
                                    //         });
                                    //       },
                                    //       isExpanded: true,
                                    //       hint:
                                    //           const Text('Select Country Code'),
                                    //     ),
                                    //   ),
                                    // ),
                                    // const SizedBox(width: 10.0),
                                    Expanded(
                                      flex: 5,
                                      child: CustomTextFormField(
                                        controller: _phoneController,
                                        labelText: 'Mobile Number',
                                        keyboardType: TextInputType.number,
                                        validator: _validatePhoneNumber,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _formKey.currentState?.validate();
                                          });
                                        },
                                        maxLength: 10,
                                        readOnly: false,
                                        showCounter: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            Center(
                              child: SizedBox(
                                width: isWeb ? 400 : double.infinity,
                                child: CustomButton(
                                  buttonText: 'Continue',
                                  onPressed: _validateAndSubmit,
                                  isWeb: isWeb,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  _launchURL('https://otomatiks.com/');
                                },
                                child: const Text(
                                  'Terms and Conditions',
                                  style: TextStyle(
                                    color: AppColors
                                        .primaryColor, // Set your desired color
                                    fontSize: 16.0,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LoadingIndicator(),
        ]));
  }
}
