import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stem_club/colors/app_colors.dart';
import 'package:stem_club/screens/dashboard.dart';
import 'package:stem_club/widgets/custom_button.dart';
import 'package:stem_club/widgets/custom_text_form_field.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _validateField({required String? value, required String fieldName, int? minLength}) {
    if (value == null || value.isEmpty) {
      return 'Please enter your $fieldName';
    } else if (minLength != null && value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  String? _validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your date of birth';
    }

    final DateTime dob = DateFormat('yyyy-MM-dd').parse(value, true);
    if (dob != null) {
      final age = DateTime.now().year - dob.year;
      if (age < 8 || age > 18) {
        return 'Age must be between 8 and 18 years';
      }
    }

    return null;
  }

  void _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 8)),
      firstDate: DateTime(2006),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            dialogBackgroundColor: Colors.white, // Background color of the dialog
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Handle save profile logic here
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: isWeb ? 400 : double.infinity,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20.0),
                  CustomTextFormField(
                    controller: _userNameController,
                    labelText: 'User Name',
                    keyboardType: TextInputType.name,
                    validator: (value) => _validateField(value: value, fieldName: 'user name', minLength: 3),
                    readOnly: false,
                    showCounter: false,
                  ),
                  const SizedBox(height: 20.0),
                  CustomTextFormField(
                    controller: _firstNameController,
                    labelText: 'First Name',
                    keyboardType: TextInputType.name,
                    validator: (value) => _validateField(value: value, fieldName: 'first name', minLength: 3),
                    readOnly: false,
                    showCounter: false,
                  ),
                  const SizedBox(height: 20.0),
                  CustomTextFormField(
                    controller: _lastNameController,
                    labelText: 'Last Name',
                    keyboardType: TextInputType.name,
                    validator: (value) => _validateField(value: value, fieldName: 'last name'),
                    readOnly: false,
                    showCounter: false,
                  ),
                  const SizedBox(height: 20.0),
                  CustomTextFormField(
                    controller: _dobController,
                    labelText: 'Date of Birth',
                    keyboardType: TextInputType.name,
                    validator: _validateDateOfBirth,
                    readOnly: true,
                    showCounter: false,
                    onTap: () => _selectDateOfBirth(context),
                  ),
                  const SizedBox(height: 40.0),
                  CustomButton(
                    buttonText: 'Update Profile',
                    onPressed: _saveProfile,
                    isWeb: isWeb,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
