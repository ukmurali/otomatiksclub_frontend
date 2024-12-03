import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:otomatiksclub/api/user_service/api_user_service.dart';
import 'package:otomatiksclub/colors/app_colors.dart';
import 'package:otomatiksclub/constants.dart';
import 'package:otomatiksclub/screens/club_selection_page.dart';
import 'package:otomatiksclub/screens/dashboard.dart';
import 'package:otomatiksclub/screens/profile_page.dart';
import 'package:otomatiksclub/utils/utils.dart';
import 'package:otomatiksclub/widgets/custom_button.dart';
import 'package:otomatiksclub/widgets/custom_snack_bar.dart';
import 'package:otomatiksclub/widgets/custom_text_form_field.dart';
import 'package:otomatiksclub/widgets/loading_indicator.dart';
import 'package:otomatiksclub/widgets/no_internet_view.dart';

class VerifyOtpPage extends StatefulWidget {
  final String phoneNumber;
  final String selectedCountryCode;
  const VerifyOtpPage({
    super.key,
    required this.phoneNumber,
    required this.selectedCountryCode,
  });

  @override
  VerifyOtpPageState createState() => VerifyOtpPageState();
}

class VerifyOtpPageState extends State<VerifyOtpPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isResendEnabled = false;
  bool _isLoading = false;
  int _secondsRemaining = 30;
  Timer? _timer;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  String? _validateField({required String? value, required int minLength}) {
    if (value == null || value.isEmpty || value.length < minLength) {
      return 'Please enter 6 digits';
    }
    return null;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _isResendEnabled = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _resendOtp() async {
    setState(() {
      _secondsRemaining = 30;
      _isResendEnabled = false;
      _isLoading = true;
    });
    _startTimer();
    // Logic to resend OTP
    final response = await ApiUserService.sendOtp(widget.phoneNumber);
    final responseBody = response['body'] as String;
    bool isSuccess = true;
    if (mounted) {
      setState(() => _isLoading = false);
      if (response['statusCode'] != 200) {
        isSuccess = false;
      }
      CustomSnackbar.showSnackBar(context, responseBody, isSuccess);
    }
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final otp = _otpController.text;
    final response = await ApiUserService.verifyOtp(widget.phoneNumber, otp);
    final responseBody = response['body'] as String;
    if (mounted) {
      setState(() => _isLoading = false);
      if (response['statusCode'] != 200) {
        if (response['body'] == 'Exception: No internet connection available') {
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
      final userResponse =
          await ApiUserService.checkUserExists(widget.phoneNumber);
      if (userResponse != null) {
        final result = jsonDecode(userResponse['body']);
        if (result['user'] == null) {
          navigateProfilePage();
        } else {
          await storeValue(AppConstants.userKey, result);
          Map<String, dynamic>? club = await getValue(AppConstants.clubKey);
          if (club != null) {
            _onLoginSuccess();
          } else {
            _navigateClubSelectionPage();
          }
        }
      }
    }
  }

  void _onLoginSuccess() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DashboardPage()),
      (Route<dynamic> route) => false,
    );
  }

  void _navigateClubSelectionPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const ClubSelectionPage()),
      (Route<dynamic> route) => false,
    );
  }

  void navigateProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProfilePage(
              phoneNumber: widget.phoneNumber,
              selectedCountryCode: widget.selectedCountryCode)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isLoading,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SizedBox(
                  width: isWeb ? 400 : double.infinity,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Verify Your Mobile Number',
                          style: TextStyle(
                              fontSize: 25.0, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14.0),
                        const Text(
                          'Enter the 6-digit OTP sent to your number',
                          style: TextStyle(fontSize: 14.0),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40.0),
                        Center(
                          child: SizedBox(
                            width: isWeb ? 400 : double.infinity,
                            child: CustomTextFormField(
                              controller: _otpController,
                              labelText: 'OTP',
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  _validateField(value: value, minLength: 6),
                              readOnly: false,
                              maxLength: 6,
                              showCounter: false,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Center(
                          child: SizedBox(
                            width: isWeb ? 400 : double.infinity,
                            child: CustomButton(
                              buttonText: 'Verify OTP',
                              onPressed: _verifyOtp,
                              isWeb: isWeb,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Center(
                          child: TextButton(
                            onPressed: _isResendEnabled ? _resendOtp : null,
                            child: Text(
                              _isResendEnabled
                                  ? 'Resend OTP'
                                  : 'Resend OTP in $_secondsRemaining s',
                              style: TextStyle(
                                color: _isResendEnabled
                                    ? AppColors.primaryColor
                                    : Colors.grey,
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
            ),
          ),
          if (_isLoading) const LoadingIndicator(),
        ],
      ),
    );
  }
}
