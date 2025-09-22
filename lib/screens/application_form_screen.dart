// flutter_app/lib/screens/application_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/application_model.dart';
import '../providers/application_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import 'results_screen.dart';

class ApplicationFormScreen extends ConsumerStatefulWidget {
  const ApplicationFormScreen({super.key});

  @override
  ConsumerState<ApplicationFormScreen> createState() =>
      _ApplicationFormScreenState();
}

class _ApplicationFormScreenState
    extends ConsumerState<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Form controllers
  final _personalControllers = {
    'income': TextEditingController(),
    'empLength': TextEditingController(),
    'age': TextEditingController(),
  };

  final _loanControllers = {
    'amount': TextEditingController(),
    'intRate': TextEditingController(),
    'intent': TextEditingController(),
    'credHistLength': TextEditingController(),
  };

  final _alternativeControllers = {
    'monthlyIncome': TextEditingController(),
    'airtime': TextEditingController(),
    'dataUsage': TextEditingController(),
    'electricBill': TextEditingController(),
    'waterBill': TextEditingController(),
    'gasBill': TextEditingController(),
    'onTimePayments': TextEditingController(),
    'latePayments': TextEditingController(),
  };

  bool _digitalWallet = false;
  bool _mobileBanking = false;

  final List<String> _loanIntents = [
    'personal',
    'education',
    'medical',
    'venture',
    'homeimprovement',
    'debtconsolidation',
  ];

  @override
  Widget build(BuildContext context) {
    final applicationState = ref.watch(applicationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Application'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStepIcon(0, Icons.person, "Personal"),
                _buildStepIcon(1, Icons.account_balance, "Loan"),
                _buildStepIcon(2, Icons.bar_chart, "Data"),
              ],
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentPage = index),
          children: [
            _buildPersonalInfoPage(),
            _buildLoanDetailsPage(),
            _buildAlternativeDataPage(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Row(
          children: [
            if (_currentPage > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text('Previous'),
                ),
              ),
            if (_currentPage > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: applicationState.isLoading
                    ? null
                    : () {
                        if (_currentPage < 2) {
                          if (_formKey.currentState!.validate()) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        } else {
                          _submitApplication();
                        }
                      },
                child: applicationState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(_currentPage < 2 ? 'Next' : 'Submit Application'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Stepper Icons
  Widget _buildStepIcon(int index, IconData icon, String label) {
    final isActive = _currentPage == index;
    return Column(
      children: [
        CircleAvatar(
          backgroundColor:
              isActive ? const Color(AppConstants.primaryColorValue) : Colors.grey,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.black : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            )),
      ],
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageTitle("Personal Information"),
          const SizedBox(height: 24),

          // Income Slider
          _sliderWithValue(
            label: "Annual Income",
            min: 50000,
            max: 2000000,
            step: 5000,
            controller: _personalControllers['income']!,
            prefix: "₹",
            validator: Validators.validateIncome,
          ),
          const SizedBox(height: 16),

          _sliderWithValue(
            label: "Employment Length (Years)",
            min: 0,
            max: 40,
            step: 1,
            controller: _personalControllers['empLength']!,
            validator: Validators.validateEmploymentLength,
          ),
          const SizedBox(height: 16),

          _sliderWithValue(
            label: "Age",
            min: 18,
            max: 70,
            step: 1,
            controller: _personalControllers['age']!,
            validator: Validators.validateAge,
          ),
        ],
      ),
    );
  }

  Widget _buildLoanDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageTitle("Loan Details"),
          const SizedBox(height: 24),

          _sliderWithValue(
            label: "Loan Amount",
            min: 10000,
            max: 1000000,
            step: 5000,
            controller: _loanControllers['amount']!,
            prefix: "₹",
            validator: Validators.validateLoanAmount,
          ),
          const SizedBox(height: 16),

          _sliderWithValue(
            label: "Interest Rate (%)",
            min: 5,
            max: 36,
            step: 0.5,
            controller: _loanControllers['intRate']!,
            suffix: "%",
            validator: Validators.validateInterestRate,
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Loan Purpose',
              helperText: 'What will you use this loan for?',
            ),
            items: _loanIntents
                .map((intent) => DropdownMenuItem(
                      value: intent,
                      child: Text(intent
                          .replaceAll('homeimprovement', 'home improvement')
                          .replaceAll('debtconsolidation', 'debt consolidation')
                          .toUpperCase()),
                    ))
                .toList(),
            onChanged: (value) =>
                _loanControllers['intent']!.text = value ?? '',
            validator: (value) =>
                value == null ? 'Please select loan purpose' : null,
          ),
          const SizedBox(height: 16),

          _sliderWithValue(
            label: "Credit History Length (Years)",
            min: 0,
            max: 30,
            step: 1,
            controller: _loanControllers['credHistLength']!,
            validator: Validators.validateCreditHistory,
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeDataPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageTitle("Alternative Data"),
          const SizedBox(height: 16),

          _sliderWithValue(
            label: "Estimated Monthly Income",
            min: 3000,
            max: 100000,
            step: 500,
            controller: _alternativeControllers['monthlyIncome']!,
            prefix: "₹",
          ),
          const SizedBox(height: 16),

          _sliderWithValue(
            label: "Monthly Airtime Spend",
            min: 0,
            max: 5000,
            step: 50,
            controller: _alternativeControllers['airtime']!,
            prefix: "₹",
          ),
          const SizedBox(height: 16),

          _sliderWithValue(
            label: "Monthly Data Usage (GB)",
            min: 0,
            max: 100,
            step: 1,
            controller: _alternativeControllers['dataUsage']!,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  title: const Text('Digital Wallet'),
                  value: _digitalWallet,
                  onChanged: (value) =>
                      setState(() => _digitalWallet = value),
                ),
              ),
              Expanded(
                child: SwitchListTile(
                  title: const Text('Mobile Banking'),
                  value: _mobileBanking,
                  onChanged: (value) =>
                      setState(() => _mobileBanking = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _pageTitle("Utility Bills"),
          const SizedBox(height: 16),

          _sliderWithValue(
            label: "Electric Bill (Avg)",
            min: 0,
            max: 10000,
            step: 100,
            controller: _alternativeControllers['electricBill']!,
            prefix: "₹",
          ),
          const SizedBox(height: 16),

          _sliderWithValue(
            label: "Water Bill (Avg)",
            min: 0,
            max: 5000,
            step: 50,
            controller: _alternativeControllers['waterBill']!,
            prefix: "₹",
          ),
          const SizedBox(height: 16),

          _sliderWithValue(
            label: "Gas Bill (Avg)",
            min: 0,
            max: 5000,
            step: 50,
            controller: _alternativeControllers['gasBill']!,
            prefix: "₹",
          ),
          const SizedBox(height: 24),

          _pageTitle("Payment History (Last 12 Months)"),
          const SizedBox(height: 16),

          _sliderWithValue(
            label: "On-time Payments",
            min: 0,
            max: 12,
            step: 1,
            controller: _alternativeControllers['onTimePayments']!,
          ),
          const SizedBox(height: 16),

          _sliderWithValue(
            label: "Late Payments",
            min: 0,
            max: 12,
            step: 1,
            controller: _alternativeControllers['latePayments']!,
          ),
        ],
      ),
    );
  }

  /// Common Slider with Value Display
  Widget _sliderWithValue({
    required String label,
    required double min,
    required double max,
    required double step,
    required TextEditingController controller,
    String? prefix,
    String? suffix,
    String? Function(String?)? validator,
  }) {
    double currentValue =
        double.tryParse(controller.text.isEmpty ? "0" : controller.text) ??
            min;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            prefixText: prefix,
            suffixText: suffix,
          ),
          keyboardType: TextInputType.number,
          onChanged: (val) {
            if (val.isNotEmpty) {
              setState(() {});
            }
          },
        ),
        Slider(
          value: currentValue.clamp(min, max),
          min: min,
          max: max,
          divisions: ((max - min) / step).round(),
          label: "${prefix ?? ''}${currentValue.toStringAsFixed(0)}${suffix ?? ''}",
          onChanged: (value) {
            setState(() {
              controller.text = value.toStringAsFixed(0);
            });
          },
        ),
      ],
    );
  }

  Widget _pageTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(AppConstants.primaryColorValue),
          ),
    );
  }

  void _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      final application = ApplicationModel(
        personIncome: double.parse(_personalControllers['income']!.text),
        personEmpLength: double.parse(_personalControllers['empLength']!.text),
        age: int.parse(_personalControllers['age']!.text),
        loanAmnt: double.parse(_loanControllers['amount']!.text),
        loanIntRate: double.parse(_loanControllers['intRate']!.text),
        loanIntent: _loanControllers['intent']!.text,
        cbPersonCredHistLength:
            double.parse(_loanControllers['credHistLength']!.text),
        estimatedMonthlyIncome:
            double.tryParse(_alternativeControllers['monthlyIncome']!.text),
        monthlyAirtimeSpend:
            double.tryParse(_alternativeControllers['airtime']!.text) ?? 0,
        monthlyDataUsageGb:
            double.tryParse(_alternativeControllers['dataUsage']!.text) ?? 0,
        digitalWalletUsage: _digitalWallet ? 1 : 0,
        mobileBankingUser: _mobileBanking ? 1 : 0,
        electricityBillAvg:
            double.tryParse(_alternativeControllers['electricBill']!.text) ?? 0,
        waterBillAvg:
            double.tryParse(_alternativeControllers['waterBill']!.text) ?? 0,
        gasBillAvg:
            double.tryParse(_alternativeControllers['gasBill']!.text) ?? 0,
        onTimePayments12m:
            int.tryParse(_alternativeControllers['onTimePayments']!.text) ?? 0,
        latePayments12m:
            int.tryParse(_alternativeControllers['latePayments']!.text) ?? 0,
      );

      await ref.read(applicationProvider.notifier).submitApplication(application);

      final state = ref.read(applicationProvider);
      if (state.predictionResult != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ResultsScreen(),
          ),
        );
      } else if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${state.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _personalControllers.values) {
      controller.dispose();
    }
    for (var controller in _loanControllers.values) {
      controller.dispose();
    }
    for (var controller in _alternativeControllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }
}
