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
  ConsumerState<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends ConsumerState<ApplicationFormScreen> {
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
    'calls': TextEditingController(),
    'sms': TextEditingController(),
    'digitalTransactions': TextEditingController(),
    'socialMedia': TextEditingController(),
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
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / 3,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
                onPressed: applicationState.isLoading ? null : () {
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          TextFormField(
            controller: _personalControllers['income'],
            decoration: const InputDecoration(
              labelText: 'Annual Income',
              prefixText: '\$',
              helperText: 'Your total yearly income',
            ),
            keyboardType: TextInputType.number,
            validator: (value) => Validators.validateIncome(value),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _personalControllers['empLength'],
            decoration: const InputDecoration(
              labelText: 'Employment Length (years)',
              helperText: 'How long have you been employed?',
            ),
            keyboardType: TextInputType.number,
            validator: (value) => Validators.validateEmploymentLength(value),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _personalControllers['age'],
            decoration: const InputDecoration(
              labelText: 'Age',
              helperText: 'Your current age',
            ),
            keyboardType: TextInputType.number,
            validator: (value) => Validators.validateAge(value),
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
          Text(
            'Loan Details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          TextFormField(
            controller: _loanControllers['amount'],
            decoration: const InputDecoration(
              labelText: 'Loan Amount',
              prefixText: '\$',
              helperText: 'How much do you want to borrow?',
            ),
            keyboardType: TextInputType.number,
            validator: (value) => Validators.validateLoanAmount(value),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _loanControllers['intRate'],
            decoration: const InputDecoration(
              labelText: 'Interest Rate (%)',
              helperText: 'Expected interest rate for this loan',
            ),
            keyboardType: TextInputType.number,
            validator: (value) => Validators.validateInterestRate(value),
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Loan Purpose',
              helperText: 'What will you use this loan for?',
            ),
            items: _loanIntents.map((intent) => DropdownMenuItem(
              value: intent,
              child: Text(intent.replaceAll('homeimprovement', 'home improvement')
                          .replaceAll('debtconsolidation', 'debt consolidation')
                          .toUpperCase()),
            )).toList(),
            onChanged: (value) => _loanControllers['intent']!.text = value ?? '',
            validator: (value) => value == null ? 'Please select loan purpose' : null,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _loanControllers['credHistLength'],
            decoration: const InputDecoration(
              labelText: 'Credit History Length (years)',
              helperText: 'How long have you had credit?',
            ),
            keyboardType: TextInputType.number,
            validator: (value) => Validators.validateCreditHistory(value),
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
          Text(
            'Alternative Data',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This information helps us better assess your creditworthiness',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Digital Services
          _buildSectionTitle('Digital Services'),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _alternativeControllers['monthlyIncome'],
            decoration: const InputDecoration(
              labelText: 'Estimated Monthly Income',
              prefixText: '\$',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _alternativeControllers['airtime'],
                  decoration: const InputDecoration(
                    labelText: 'Monthly Airtime',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _alternativeControllers['dataUsage'],
                  decoration: const InputDecoration(
                    labelText: 'Data Usage (GB)',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  title: const Text('Digital Wallet'),
                  value: _digitalWallet,
                  onChanged: (value) => setState(() => _digitalWallet = value),
                ),
              ),
              Expanded(
                child: SwitchListTile(
                  title: const Text('Mobile Banking'),
                  value: _mobileBanking,
                  onChanged: (value) => setState(() => _mobileBanking = value),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Utility Bills
          _buildSectionTitle('Utility Bills'),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _alternativeControllers['electricBill'],
                  decoration: const InputDecoration(
                    labelText: 'Electric Bill',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _alternativeControllers['waterBill'],
                  decoration: const InputDecoration(
                    labelText: 'Water Bill',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _alternativeControllers['gasBill'],
            decoration: const InputDecoration(
              labelText: 'Gas Bill',
              prefixText: '\$',
            ),
            keyboardType: TextInputType.number,
          ),
          
          const SizedBox(height: 24),
          
          // Payment History
          _buildSectionTitle('Payment History (Last 12 Months)'),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _alternativeControllers['onTimePayments'],
                  decoration: const InputDecoration(
                    labelText: 'On-time Payments',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _alternativeControllers['latePayments'],
                  decoration: const InputDecoration(
                    labelText: 'Late Payments',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
        cbPersonCredHistLength: double.parse(_loanControllers['credHistLength']!.text),
        estimatedMonthlyIncome: double.tryParse(_alternativeControllers['monthlyIncome']!.text),
        monthlyAirtimeSpend: double.tryParse(_alternativeControllers['airtime']!.text) ?? 0,
        monthlyDataUsageGb: double.tryParse(_alternativeControllers['dataUsage']!.text) ?? 0,
        digitalWalletUsage: _digitalWallet ? 1 : 0,
        mobileBankingUser: _mobileBanking ? 1 : 0,
        electricityBillAvg: double.tryParse(_alternativeControllers['electricBill']!.text) ?? 0,
        waterBillAvg: double.tryParse(_alternativeControllers['waterBill']!.text) ?? 0,
        gasBillAvg: double.tryParse(_alternativeControllers['gasBill']!.text) ?? 0,
        onTimePayments12m: int.tryParse(_alternativeControllers['onTimePayments']!.text) ?? 0,
        latePayments12m: int.tryParse(_alternativeControllers['latePayments']!.text) ?? 0,
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
    _personalControllers.values.forEach((controller) => controller.dispose());
    _loanControllers.values.forEach((controller) => controller.dispose());
    _alternativeControllers.values.forEach((controller) => controller.dispose());
    _pageController.dispose();
    super.dispose();
  }
}
