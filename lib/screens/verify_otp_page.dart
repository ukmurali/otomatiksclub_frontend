import 'package:flutter/material.dart';
import 'package:stem_club/colors/app_colors.dart';
import 'dart:async';
import 'package:stem_club/screens/profile_page.dart';
import 'package:stem_club/widgets/custom_button.dart';
import 'package:stem_club/widgets/custom_text_form_field.dart';

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({super.key});

  @override
  _VerifyOtpPageState createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  bool _isResendEnabled = false;
  bool _isOtpValid = true; // Track OTP validation
  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
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
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _resendOtp() {
    setState(() {
      _secondsRemaining = 30;
      _isResendEnabled = false;
    });
    _startTimer();
    // Logic to resend OTP
  }

  void _verifyOtp() {
    // Check if all fields are filled
    bool allFieldsFilled =
        _otpControllers.every((controller) => controller.text.isNotEmpty);

    setState(() {
      _isOtpValid = allFieldsFilled; // Set validation status
    });

    if (_isOtpValid) {
      // Proceed with OTP verification
      final otp = _otpControllers.map((controller) => controller.text).join();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } else {
      // Show an error message or handle invalid OTP
      print('Please enter all 6 digits.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Verify Your Mobile Number',
              style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Enter the 6-digit OTP sent to your number.',
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40.0),
            Center(
              child: SizedBox(
                width: isWeb ? 400 : double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: isWeb ? 50 : 40,
                      child: CustomTextFormField(
                        controller: _otpControllers[index],
                        labelText: '',
                        readOnly: false,
                        maxLength: 1,
                        keyboardType: TextInputType.number,
                        showCounter: false,
                        onChanged: (value) {
                          if (value.length == 1 && index < 5) {
                            FocusScope.of(context).nextFocus();
                          }
                          if (value.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
              ),
            ),
            if (!_isOtpValid) // Show error message if OTP is invalid
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Please enter all 6 digits.',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
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
                    color:
                        _isResendEnabled ? AppColors.primaryColor : Colors.grey,
                    fontSize: 16.0,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
