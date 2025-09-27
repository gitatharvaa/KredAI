// flutter_app/lib/widgets/application_form_widget.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/application_model.dart';
import '../models/user_profile_model.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class ApplicationFormWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final UserProfileModel userProfile;
  final VoidCallback onVoiceInput;
  final bool isListening;
  final bool isSmallScreen;
  final Function(ApplicationModel) onSubmit;

  const ApplicationFormWidget({
    super.key,
    required this.formKey,
    required this.userProfile,
    required this.onVoiceInput,
    required this.isListening,
    required this.isSmallScreen,
    required this.onSubmit,
  });

  @override
  State<ApplicationFormWidget> createState() => _ApplicationFormWidgetState();
}

class _ApplicationFormWidgetState extends State<ApplicationFormWidget> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Form controllers
  final _personalControllers = {
    'income': TextEditingController(),
    'empLength': TextEditingController(),
  };

  final _loanControllers = {
    'amount': TextEditingController(),
    'intRate': TextEditingController(),
    'purpose': TextEditingController(),
  };

  final _creditControllers = {
    'histLength': TextEditingController(),
    'defaultFile': TextEditingController(),
  };

  final _alternativeControllers = {
    'monthlyIncome': TextEditingController(),
    'airtimeSpend': TextEditingController(),
    'dataUsage': TextEditingController(),
    'callsPerDay': TextEditingController(),
    'smsPerDay': TextEditingController(),
    'digitalTransactions': TextEditingController(),
    'transactionAmount': TextEditingController(),
    'socialMediaScore': TextEditingController(),
    'digitalScore': TextEditingController(),
    'financialScore': TextEditingController(),
  };

  final _utilityControllers = {
    'electricBill': TextEditingController(),
    'waterBill': TextEditingController(),
    'gasBill': TextEditingController(),
    'onTimePayments': TextEditingController(),
    'latePayments': TextEditingController(),
  };

  // Dropdown values
  String? _selectedLoanIntent;
  int _digitalWalletUsage = 0;
  int _mobileBankingUser = 0;
  int _defaultOnFile = 0;

  final List<String> _loanIntents = [
    'personal',
    'education',
    'medical',
    'venture',
    'homeimprovement',
    'debtconsolidation',
  ];

  @override
  void initState() {
    super.initState();
    _initializeWithUserData();
  }

  void _initializeWithUserData() {
    // Pre-populate with user profile data where applicable
    _personalControllers['empLength']!.text = '0';
    // Age is auto-calculated from user profile
  }

  @override
  void dispose() {
    _personalControllers.values.forEach((c) => c.dispose());
    _loanControllers.values.forEach((c) => c.dispose());
    _creditControllers.values.forEach((c) => c.dispose());
    _alternativeControllers.values.forEach((c) => c.dispose());
    _utilityControllers.values.forEach((c) => c.dispose());
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).size.width * 0.04;

    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(padding),
          
          // Form Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                _buildPersonalFinancePage(padding),
                _buildLoanDetailsPage(padding),
                _buildCreditHistoryPage(padding),
                _buildAlternativeDataPage(padding),
                _buildUtilityDataPage(padding),
              ],
            ),
          ),
          
          // Navigation Buttons
          _buildNavigationButtons(padding),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final isActive = _currentPage >= index;
              final icons = [
                Icons.person_outline,
                Icons.account_balance_wallet_outlined,
                Icons.credit_score_outlined,
                Icons.smartphone_outlined,
                Icons.home_outlined,
              ];
              final labels = [
                'Personal',
                'Loan',
                'Credit',
                'Digital',
                'Utility',
              ];
              
              return Column(
                children: [
                  CircleAvatar(
                    radius: widget.isSmallScreen ? 16 : 20,
                    backgroundColor: isActive
                        ? const Color(AppConstants.primaryColorValue)
                        : Colors.grey[300],
                    child: Icon(
                      icons[index],
                      size: widget.isSmallScreen ? 16 : 20,
                      color: isActive ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: widget.isSmallScreen ? 10 : 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive
                          ? const Color(AppConstants.primaryColorValue)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              );
            }),
          ),
          SizedBox(height: padding * 0.5),
          LinearProgressIndicator(
            value: (_currentPage + 1) / 5,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(AppConstants.primaryColorValue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalFinancePage(double padding) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Personal Finance Information'),
          SizedBox(height: padding),
          
          // Display user info
          Card(
            color: const Color(AppConstants.primaryColorValue).withOpacity(0.1),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: const Color(AppConstants.primaryColorValue)),
                      SizedBox(width: 8),
                      Text(
                        'Personal Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(AppConstants.primaryColorValue),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: padding * 0.5),
                  _buildInfoRow('Name', widget.userProfile.fullName),
                  _buildInfoRow('Age', '${widget.userProfile.age} years'),
                  _buildInfoRow('Location', '${widget.userProfile.city}, ${widget.userProfile.state}'),
                ],
              ),
            ),
          ),
          
          SizedBox(height: padding),
          
          _buildFormField(
            controller: _personalControllers['income']!,
            label: 'Annual Income (₹) *',
            hint: 'Enter your total yearly income',
            icon: Icons.currency_rupee,
            keyboardType: TextInputType.number,
            validator: Validators.validateIncome,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          
          SizedBox(height: padding * 0.7),
          
          _buildFormField(
            controller: _personalControllers['empLength']!,
            label: 'Employment Length (years) *',
            hint: 'Years of work experience',
            icon: Icons.work_history,
            keyboardType: TextInputType.number,
            validator: Validators.validateEmploymentLength,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoanDetailsPage(double padding) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Loan Requirements'),
          SizedBox(height: padding),
          
          _buildFormField(
            controller: _loanControllers['amount']!,
            label: 'Loan Amount (₹) *',
            hint: 'Enter required loan amount',
            icon: Icons.account_balance_wallet,
            keyboardType: TextInputType.number,
            validator: Validators.validateLoanAmount,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          
          SizedBox(height: padding * 0.7),
          
          _buildFormField(
            controller: _loanControllers['intRate']!,
            label: 'Expected Interest Rate (%) *',
            hint: 'Expected annual interest rate',
            icon: Icons.percent,
            keyboardType: TextInputType.number,
            validator: Validators.validateInterestRate,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
          
          SizedBox(height: padding * 0.7),
          
          _buildDropdownField(
            value: _selectedLoanIntent,
            label: 'Loan Purpose',
            hint: 'Select loan purpose',
            icon: Icons.category,
            items: _loanIntents.map((intent) {
              return DropdownMenuItem(
                value: intent,
                child: Text(intent.replaceAll('_', ' ').toUpperCase()),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedLoanIntent = value),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditHistoryPage(double padding) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Credit History'),
          SizedBox(height: padding),
          
          _buildFormField(
            controller: _creditControllers['histLength']!,
            label: 'Credit History Length (years) *',
            hint: 'Years since first credit account',
            icon: Icons.history,
            keyboardType: TextInputType.number,
            validator: Validators.validateCreditHistory,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
          
          SizedBox(height: padding * 0.7),
          
          _buildSwitchField(
            value: _defaultOnFile == 1,
            label: 'Previous Default on File',
            subtitle: 'Have you ever defaulted on a loan?',
            onChanged: (value) {
              setState(() => _defaultOnFile = value ? 1 : 0);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeDataPage(double padding) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Digital Footprint'),
          Text(
            'This information helps us better assess your creditworthiness',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: widget.isSmallScreen ? 12 : 14,
            ),
          ),
          SizedBox(height: padding),
          
          _buildFormField(
            controller: _alternativeControllers['monthlyIncome']!,
            label: 'Estimated Monthly Income (₹)',
            hint: 'Monthly income estimate',
            icon: Icons.calendar_month,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          
          SizedBox(height: padding * 0.7),
          
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: _alternativeControllers['airtimeSpend']!,
                  label: 'Monthly Airtime (₹)',
                  hint: 'Monthly phone recharge',
                  icon: Icons.phone,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              SizedBox(width: padding * 0.5),
              Expanded(
                child: _buildFormField(
                  controller: _alternativeControllers['dataUsage']!,
                  label: 'Data Usage (GB)',
                  hint: 'Monthly data usage',
                  icon: Icons.data_usage,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: padding * 0.7),
          
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: _alternativeControllers['callsPerDay']!,
                  label: 'Calls/Day',
                  hint: 'Average calls per day',
                  icon: Icons.call,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              SizedBox(width: padding * 0.5),
              Expanded(
                child: _buildFormField(
                  controller: _alternativeControllers['smsPerDay']!,
                  label: 'SMS/Day',
                  hint: 'Average SMS per day',
                  icon: Icons.sms,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          
          SizedBox(height: padding * 0.7),
          
          _buildSwitchField(
            value: _digitalWalletUsage == 1,
            label: 'Digital Wallet Usage',
            subtitle: 'Do you use digital wallets (Paytm, GPay, etc.)?',
            onChanged: (value) {
              setState(() => _digitalWalletUsage = value ? 1 : 0);
            },
          ),
          
          SizedBox(height: padding * 0.7),
          
          _buildSwitchField(
            value: _mobileBankingUser == 1,
            label: 'Mobile Banking User',
            subtitle: 'Do you use mobile banking apps?',
            onChanged: (value) {
              setState(() => _mobileBankingUser = value ? 1 : 0);
            },
          ),
          
          SizedBox(height: padding * 0.7),
          
          _buildFormField(
            controller: _alternativeControllers['digitalTransactions']!,
            label: 'Monthly Digital Transactions',
            hint: 'Number of digital transactions per month',
            icon: Icons.account_balance,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityDataPage(double padding) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Utility Payment History'),
          Text(
            'Your utility payment patterns help us understand your financial behavior',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: widget.isSmallScreen ? 12 : 14,
            ),
          ),
          SizedBox(height: padding),
          
          _buildFormField(
            controller: _utilityControllers['electricBill']!,
            label: 'Monthly Electricity Bill (₹)',
            hint: 'Average electricity bill',
            icon: Icons.electrical_services,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          
          SizedBox(height: padding * 0.7),
          
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: _utilityControllers['waterBill']!,
                  label: 'Water Bill (₹)',
                  hint: 'Monthly water bill',
                  icon: Icons.water_drop,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              SizedBox(width: padding * 0.5),
              Expanded(
                child: _buildFormField(
                  controller: _utilityControllers['gasBill']!,
                  label: 'Gas Bill (₹)',
                  hint: 'Monthly gas bill',
                  icon: Icons.local_gas_station,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          
          SizedBox(height: padding),
          
          Text(
            'Payment History (Last 12 Months)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: widget.isSmallScreen ? 16 : 18,
            ),
          ),
          SizedBox(height: padding * 0.5),
          
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: _utilityControllers['onTimePayments']!,
                  label: 'On-Time Payments',
                  hint: 'Number of on-time payments',
                  icon: Icons.check_circle,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              SizedBox(width: padding * 0.5),
              Expanded(
                child: _buildFormField(
                  controller: _utilityControllers['latePayments']!,
                  label: 'Late Payments',
                  hint: 'Number of late payments',
                  icon: Icons.warning,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
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
                if (_currentPage < 4) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  _submitApplication();
                }
              },
              icon: Icon(_currentPage < 4 ? Icons.arrow_forward : Icons.send),
              label: Text(_currentPage < 4 ? 'Next' : 'Submit Application'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: widget.isSmallScreen ? 18 : 20,
        fontWeight: FontWeight.bold,
        color: const Color(AppConstants.primaryColorValue),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: widget.isListening
            ? const Icon(Icons.mic, color: Colors.red)
            : IconButton(
                icon: const Icon(Icons.mic_none),
                onPressed: widget.onVoiceInput,
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildSwitchField({
    required bool value,
    required String label,
    required String subtitle,
    required Function(bool) onChanged,
  }) {
    return Card(
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(label),
        subtitle: Text(subtitle),
        activeColor: const Color(AppConstants.primaryColorValue),
      ),
    );
  }

void _submitApplication() {
  // Add authentication check
  final user = FirebaseAuth.instance.currentUser;
  
  if (user == null) {
    // Sign in anonymously for demo purposes
    FirebaseAuth.instance.signInAnonymously().then((_) {
      _processApplication();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication failed: $error')),
      );
    });
  } else {
    _processApplication();
  }
}

void _processApplication() {
  final applicationData = ApplicationModel(
    personIncome: double.tryParse(_personalControllers['income']!.text) ?? 0,
    personEmpLength: double.tryParse(_personalControllers['empLength']!.text) ?? 0,
    age: widget.userProfile.age,
    loanAmnt: double.tryParse(_loanControllers['amount']!.text) ?? 0,
    loanIntRate: double.tryParse(_loanControllers['intRate']!.text) ?? 0,
    loanIntent: _selectedLoanIntent,
    cbPersonCredHistLength: double.tryParse(_creditControllers['histLength']!.text) ?? 0,
    cbPersonDefaultOnFile: _defaultOnFile,
    estimatedMonthlyIncome: double.tryParse(_alternativeControllers['monthlyIncome']!.text),
    monthlyAirtimeSpend: double.tryParse(_alternativeControllers['airtimeSpend']!.text) ?? 0,
    monthlyDataUsageGb: double.tryParse(_alternativeControllers['dataUsage']!.text) ?? 0,
    avgCallsPerDay: double.tryParse(_alternativeControllers['callsPerDay']!.text) ?? 0,
    avgSmsPerDay: double.tryParse(_alternativeControllers['smsPerDay']!.text) ?? 0,
    digitalWalletUsage: _digitalWalletUsage,
    mobileBankingUser: _mobileBankingUser,
    monthlyDigitalTransactions: double.tryParse(_alternativeControllers['digitalTransactions']!.text) ?? 0,
    avgTransactionAmount: double.tryParse(_alternativeControllers['transactionAmount']!.text) ?? 0,
    electricityBillAvg: double.tryParse(_utilityControllers['electricBill']!.text) ?? 0,
    waterBillAvg: double.tryParse(_utilityControllers['waterBill']!.text) ?? 0,
    gasBillAvg: double.tryParse(_utilityControllers['gasBill']!.text) ?? 0,
    onTimePayments12m: int.tryParse(_utilityControllers['onTimePayments']!.text) ?? 0,
    latePayments12m: int.tryParse(_utilityControllers['latePayments']!.text) ?? 0,
  );

  widget.onSubmit(applicationData);
}
}
