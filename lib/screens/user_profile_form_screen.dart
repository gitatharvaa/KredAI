// flutter_app/lib/screens/user_profile_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/user_profile_model.dart';
import '../utils/constants.dart';
import '../utils/data_validator.dart';
import 'application_form_screen.dart';

class UserProfileFormScreen extends ConsumerStatefulWidget {
  const UserProfileFormScreen({super.key});

  @override
  ConsumerState<UserProfileFormScreen> createState() => _UserProfileFormScreenState();
}

class _UserProfileFormScreenState extends ConsumerState<UserProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Form Controllers
  final _personalControllers = {
    'fullName': TextEditingController(),
    'phoneNumber': TextEditingController(),
    'emailAddress': TextEditingController(),
    'panNumber': TextEditingController(),
    'aadharNumber': TextEditingController(),
    'occupation': TextEditingController(),
    'employerName': TextEditingController(),
  };

  final _addressControllers = {
    'streetAddress': TextEditingController(),
    'city': TextEditingController(),
    'state': TextEditingController(),
    'postalCode': TextEditingController(),
    'workAddress': TextEditingController(),
  };

  DateTime? _selectedDateOfBirth;
  bool _consentDataProcessing = false;
  bool _consentCreditCheck = false;

  final List<String> _indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
    'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
    'Delhi', 'Puducherry', 'Chandigarh', 'Dadra and Nagar Haveli', 'Daman and Diu',
    'Lakshadweep', 'Ladakh', 'Jammu and Kashmir'
  ];

  @override
  void dispose() {
    _personalControllers.values.forEach((controller) => controller.dispose());
    _addressControllers.values.forEach((controller) => controller.dispose());
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final padding = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Information'),
        backgroundColor: const Color(AppConstants.primaryColorValue),
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(isSmallScreen ? 80 : 90),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStepIcon(0, Icons.person, 'Personal', isSmallScreen),
                    _buildStepIcon(1, Icons.home, 'Address', isSmallScreen),
                    _buildStepIcon(2, Icons.verified_user, 'Consent', isSmallScreen),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: 4.0),
                child: LinearProgressIndicator(
                  value: (_currentPage + 1) / 3,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) => setState(() => _currentPage = index),
          children: [
            _buildPersonalInfoPage(isSmallScreen, padding),
            _buildAddressInfoPage(isSmallScreen, padding),
            _buildConsentPage(isSmallScreen, padding),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(padding),
        child: Row(
          children: [
            if (_currentPage > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
              ),
            if (_currentPage > 0) SizedBox(width: padding),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_currentPage < 2) {
                    if (_validateCurrentPage()) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  } else {
                    _submitUserProfile();
                  }
                },
                icon: Icon(_currentPage < 2 ? Icons.arrow_forward : Icons.check),
                label: Text(_currentPage < 2 ? 'Next' : 'Continue to Application'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIcon(int index, IconData icon, String label, bool isSmallScreen) {
    final isActive = _currentPage == index;
    return Column(
      children: [
        CircleAvatar(
          radius: isSmallScreen ? 18 : 22,
          backgroundColor: isActive 
            ? Colors.white 
            : Colors.white.withOpacity(0.3),
          child: Icon(
            icon, 
            color: isActive 
              ? const Color(AppConstants.primaryColorValue) 
              : Colors.white,
            size: isSmallScreen ? 18 : 20,
          ),
        ),
        SizedBox(height: isSmallScreen ? 4 : 6),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 11 : 12,
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoPage(bool isSmallScreen, double padding) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Basic Information', isSmallScreen),
          SizedBox(height: padding),
          
          _buildFormField(
            controller: _personalControllers['fullName']!,
            label: 'Full Name *',
            hint: 'Enter your complete name as per official documents',
            icon: Icons.person,
            validator: DataValidator.validateFullName,
            textCapitalization: TextCapitalization.words,
            isSmallScreen: isSmallScreen,
          ),
          
          SizedBox(height: padding * 0.7),
          
          _buildDateOfBirthField(isSmallScreen),
          
          SizedBox(height: padding * 0.7),
          
          _buildFormField(
            controller: _personalControllers['phoneNumber']!,
            label: 'Phone Number *',
            hint: 'Enter 10-digit mobile number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: DataValidator.validatePhoneNumber,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            isSmallScreen: isSmallScreen,
          ),
          
          SizedBox(height: padding * 0.7),
          
          _buildFormField(
            controller: _personalControllers['emailAddress']!,
            label: 'Email Address *',
            hint: 'Enter your email address',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: DataValidator.validateEmail,
            isSmallScreen: isSmallScreen,
          ),
          
          SizedBox(height: padding),
          _buildSectionTitle('Optional Information', isSmallScreen),
          SizedBox(height: padding),
          
          _buildFormField(
            controller: _personalControllers['panNumber']!,
            label: 'PAN Number',
            hint: 'Enter PAN number (optional)',
            icon: Icons.credit_card,
            validator: DataValidator.validatePAN,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
              LengthLimitingTextInputFormatter(10),
            ],
            isSmallScreen: isSmallScreen,
          ),
          
          SizedBox(height: padding * 0.7),
          
          _buildFormField(
            controller: _personalControllers['occupation']!,
            label: 'Occupation',
            hint: 'Enter your current occupation',
            icon: Icons.work,
            textCapitalization: TextCapitalization.words,
            isSmallScreen: isSmallScreen,
          ),
          
          SizedBox(height: padding * 0.7),
          
          _buildFormField(
            controller: _personalControllers['employerName']!,
            label: 'Employer Name',
            hint: 'Enter your company/employer name',
            icon: Icons.business,
            textCapitalization: TextCapitalization.words,
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInfoPage(bool isSmallScreen, double padding) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Residential Address', isSmallScreen),
          SizedBox(height: padding),
          
          _buildFormField(
            controller: _addressControllers['streetAddress']!,
            label: 'Street Address *',
            hint: 'Enter your complete address',
            icon: Icons.home,
            validator: DataValidator.validateAddress,
            maxLines: 2,
            textCapitalization: TextCapitalization.words,
            isSmallScreen: isSmallScreen,
          ),
          
          SizedBox(height: padding * 0.7),
          
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: _addressControllers['city']!,
                  label: 'City *',
                  hint: 'Enter city',
                  icon: Icons.location_city,
                  validator: DataValidator.validateCity,
                  textCapitalization: TextCapitalization.words,
                  isSmallScreen: isSmallScreen,
                ),
              ),
              SizedBox(width: padding * 0.5),
              Expanded(
                child: _buildFormField(
                  controller: _addressControllers['postalCode']!,
                  label: 'PIN Code *',
                  hint: 'Enter PIN',
                  icon: Icons.mail,
                  keyboardType: TextInputType.number,
                  validator: DataValidator.validatePinCode,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  isSmallScreen: isSmallScreen,
                ),
              ),
            ],
          ),
          
          SizedBox(height: padding * 0.7),
          
          _buildStateDropdown(isSmallScreen),
          
          SizedBox(height: padding),
          _buildSectionTitle('Work Address (Optional)', isSmallScreen),
          SizedBox(height: padding),
          
          _buildFormField(
            controller: _addressControllers['workAddress']!,
            label: 'Work Address',
            hint: 'Enter your work address (if different)',
            icon: Icons.business,
            maxLines: 2,
            textCapitalization: TextCapitalization.words,
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildConsentPage(bool isSmallScreen, double padding) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Data Privacy & Consent', isSmallScreen),
          SizedBox(height: padding),
          
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  Icon(
                    Icons.security,
                    size: isSmallScreen ? 48 : 64,
                    color: const Color(AppConstants.primaryColorValue),
                  ),
                  SizedBox(height: padding),
                  Text(
                    'Your Privacy Matters',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(AppConstants.primaryColorValue),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: padding * 0.5),
                  Text(
                    'We are committed to protecting your personal and financial information in accordance with data protection regulations.',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: padding * 1.5),
          
          // Data Processing Consent
          Card(
            child: CheckboxListTile(
              value: _consentDataProcessing,
              onChanged: (value) {
                setState(() => _consentDataProcessing = value ?? false);
              },
              title: const Text(
                'Consent for Data Processing *',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'I consent to the processing of my personal data for credit assessment purposes, including sharing with authorized credit bureaus and financial institutions.',
              ),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: const Color(AppConstants.primaryColorValue),
            ),
          ),
          
          SizedBox(height: padding * 0.7),
          
          // Credit Check Consent
          Card(
            child: CheckboxListTile(
              value: _consentCreditCheck,
              onChanged: (value) {
                setState(() => _consentCreditCheck = value ?? false);
              },
              title: const Text(
                'Consent for Credit Verification *',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'I authorize the verification of my credit history, income details, and banking information through authorized agencies for loan assessment.',
              ),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: const Color(AppConstants.primaryColorValue),
            ),
          ),
          
          SizedBox(height: padding * 1.5),
          
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: const Color(AppConstants.infoColorValue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info,
                      color: Color(AppConstants.infoColorValue),
                    ),
                    SizedBox(width: padding * 0.5),
                    Text(
                      'Data Protection Rights',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: padding * 0.5),
                Text(
                  '• You have the right to access, modify, or delete your personal data\n'
                  '• Your data will be stored securely and used only for stated purposes\n'
                  '• You can withdraw consent at any time by contacting our support team\n'
                  '• Data retention follows regulatory compliance standards',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isSmallScreen) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isSmallScreen ? 18 : 20,
        fontWeight: FontWeight.bold,
        color: const Color(AppConstants.primaryColorValue),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isSmallScreen,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization? textCapitalization,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 12 : 16,
        ),
      ),
    );
  }

  Widget _buildDateOfBirthField(bool isSmallScreen) {
    return InkWell(
      onTap: () => _selectDateOfBirth(),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date of Birth *',
          hintText: 'Select your date of birth',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 12 : 16,
          ),
        ),
        child: Text(
          _selectedDateOfBirth != null
              ? DateFormat('dd MMM yyyy').format(_selectedDateOfBirth!)
              : 'Tap to select date',
          style: TextStyle(
            color: _selectedDateOfBirth != null ? null : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildStateDropdown(bool isSmallScreen) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'State *',
        prefixIcon: const Icon(Icons.location_on),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 12 : 16,
        ),
      ),
      items: _indianStates
          .map((state) => DropdownMenuItem(
                value: state,
                child: Text(state),
              ))
          .toList(),
      onChanged: (value) {
        _addressControllers['state']!.text = value ?? '';
      },
      validator: (value) => value == null ? 'Please select your state' : null,
    );
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(now.year - 100);
    final DateTime lastDate = DateTime(now.year - 18);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? lastDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select Date of Birth',
      fieldLabelText: 'Date of Birth',
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  bool _validateCurrentPage() {
    if (_currentPage == 0) {
      return _personalControllers['fullName']!.text.isNotEmpty &&
             _personalControllers['phoneNumber']!.text.length == 10 &&
             _personalControllers['emailAddress']!.text.contains('@') &&
             _selectedDateOfBirth != null;
    } else if (_currentPage == 1) {
      return _addressControllers['streetAddress']!.text.isNotEmpty &&
             _addressControllers['city']!.text.isNotEmpty &&
             _addressControllers['state']!.text.isNotEmpty &&
             _addressControllers['postalCode']!.text.length == 6;
    } else if (_currentPage == 2) {
      return _consentDataProcessing && _consentCreditCheck;
    }
    return false;
  }

  void _submitUserProfile() {
    if (_validateCurrentPage()) {
      final userProfile = UserProfileModel(
        fullName: _personalControllers['fullName']!.text.trim(),
        dateOfBirth: _selectedDateOfBirth!,
        phoneNumber: _personalControllers['phoneNumber']!.text.trim(),
        emailAddress: _personalControllers['emailAddress']!.text.trim(),
        streetAddress: _addressControllers['streetAddress']!.text.trim(),
        city: _addressControllers['city']!.text.trim(),
        state: _addressControllers['state']!.text.trim(),
        postalCode: _addressControllers['postalCode']!.text.trim(),
        panNumber: _personalControllers['panNumber']!.text.trim().isEmpty 
            ? null : _personalControllers['panNumber']!.text.trim(),
        occupation: _personalControllers['occupation']!.text.trim().isEmpty 
            ? null : _personalControllers['occupation']!.text.trim(),
        employerName: _personalControllers['employerName']!.text.trim().isEmpty 
            ? null : _personalControllers['employerName']!.text.trim(),
        workAddress: _addressControllers['workAddress']!.text.trim().isEmpty 
            ? null : _addressControllers['workAddress']!.text.trim(),
        consentForDataProcessing: _consentDataProcessing,
        consentForCreditCheck: _consentCreditCheck,
        consentTimestamp: DateTime.now(),
        preferredLanguage: context.locale.languageCode,
      );

      // Navigate to application form with user profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ApplicationFormScreen(userProfile: userProfile),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields and consent agreements'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
