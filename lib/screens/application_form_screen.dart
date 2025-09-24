// lib/screens/application_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
    // phone bills replaces airtime label
    'phoneBills': TextEditingController(),
    'dataUsage': TextEditingController(),
    'electricBill': TextEditingController(),
    'waterBill': TextEditingController(),
    'gasBill': TextEditingController(),
    'onTimePayments': TextEditingController(),
    'latePayments': TextEditingController(),
  };

  bool _digitalWallet = false;
  bool _mobileBanking = false;

  // flag to track if user manually edited monthly income
  bool _monthlyEdited = false;

  // voice-to-text (nullable and lazily initialized to avoid LateInitializationError)
  stt.SpeechToText? _speech;
  bool _speechAvailable = false;
  bool _isListening = false;

  final List<String> _loanIntents = [
    'personal',
    'education',
    'medical',
    'venture',
    'homeimprovement',
    'debtconsolidation',
    'other',
  ];

  // Business rule: multiplier for max loan relative to declared annual income
  static const double _loanIncomeMultiplier = 5; // loan <= income * 5
  static const double _loanHardCap = 8000000; // ₹8,000,000 (80 lakh)

  @override
  void initState() {
    super.initState();
    _initSpeech();

    // listen to annual income changes to auto-fill monthly income, unless user edited monthly manually
    _personalControllers['income']!.addListener(() {
      final annualText = _personalControllers['income']!.text;
      final annual = double.tryParse(annualText.replaceAll(',', ''));
      if (!_monthlyEdited && annual != null) {
        final monthly = annual / 12;
        // round to nearest integer for UI
        _alternativeControllers['monthlyIncome']!.text = monthly.toStringAsFixed(0);
        setState(() {});
      }
    });

    // if user edits monthly income, mark flag
    _alternativeControllers['monthlyIncome']!.addListener(() {
      // if monthly income was changed by the user (and not empty), mark _monthlyEdited true
      // Note: when we programmatically set monthly we still trigger listener; to keep simple we'll
      // detect user keyboard focus before setting flag below in TextFormField onChanged.
    });
  }

  Future<void> _initSpeech() async {
    _speech ??= stt.SpeechToText();
    try {
      _speechAvailable = await _speech!.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
            });
          }
        },
        onError: (error) {
          setState(() {
            _isListening = false;
          });
        },
      );
    } catch (_) {
      _speechAvailable = false;
    }
    if (mounted) setState(() {});
  }

  String? _localeIdForSpeech() {
    final code = context.locale.languageCode;
    switch (code) {
      case 'hi':
        return 'hi_IN';
      case 'bn':
        return 'bn_IN';
      case 'ta':
        return 'ta_IN';
      case 'te':
        return 'te_IN';
      case 'mr':
        return 'mr_IN';
      case 'en':
      default:
        return 'en_US';
    }
  }

  Future<void> _startListeningToController(TextEditingController controller) async {
    _speech ??= stt.SpeechToText();

    if (!_speechAvailable) {
      await _initSpeech();
    }

    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('speech_unavailable'.tr())),
      );
      return;
    }

    if (!_isListening) {
      setState(() => _isListening = true);
      try {
        await _speech!.listen(
          localeId: _localeIdForSpeech(),
          onResult: (result) {
            if (result.finalResult) {
              setState(() => _isListening = false);
              final recognized = result.recognizedWords;
              final numeric = _extractNumericFromSpeech(recognized);
              if (numeric.isNotEmpty) {
                controller.text = numeric;
              } else {
                controller.text = recognized;
              }
            } else {
              final recognized = result.recognizedWords;
              final numeric = _extractNumericFromSpeech(recognized);
              if (numeric.isNotEmpty) controller.text = numeric;
            }
          },
        );
      } catch (e) {
        setState(() {
          _isListening = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('speech_unavailable'.tr())),
        );
      }
    } else {
      try {
        await _speech!.stop();
      } catch (_) {}
      setState(() => _isListening = false);
    }
  }

  String _extractNumericFromSpeech(String s) {
    final digitsOnly = RegExp(r'[\d,.]+');
    final match = digitsOnly.firstMatch(s);
    if (match != null) {
      final raw = match.group(0) ?? '';
      return raw.replaceAll(',', '');
    }
    final fallback = s.replaceAll(RegExp(r'[^0-9]'), '');
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final applicationState = ref.watch(applicationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr()),
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (locale) async {
              await context.setLocale(locale);
              await _initSpeech();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: const Locale('en'),
                child: const Text('English'),
              ),
              PopupMenuItem(
                value: const Locale('hi'),
                child: const Text('हिन्दी'),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStepIcon(0, Icons.person, 'Personal'),
                    _buildStepIcon(1, Icons.account_balance, 'Loan'),
                    _buildStepIcon(2, Icons.bar_chart, 'Data'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
                  child: Text('previous'.tr()),
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(_currentPage < 2 ? 'next'.tr() : 'submit_app'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIcon(int index, IconData icon, String label) {
    final isActive = _currentPage == index;
    return InkWell(
      onTap: () {
        // jump to selected page, keep state (controllers retain values)
        _pageController.jumpToPage(index);
        setState(() {
          _currentPage = index;
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isActive ? const Color(AppConstants.primaryColorValue) : Colors.grey[300],
            child: Icon(icon, color: isActive ? Colors.white : Colors.black54, size: 20),
          ),
          const SizedBox(height: 6),
          // label text in white as required
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageTitle('personal_info'.tr()),
          const SizedBox(height: 16),
          _labeledFieldWithTooltip(
            label: 'annual_income'.tr(),
            tooltipKey: 'tooltip_income',
            child: _sliderWithValue(
              label: 'annual_income'.tr(),
              min: 50000,
              max: 2000000,
              step: 5000,
              controller: _personalControllers['income']!,
              prefix: '₹',
              validator: _validateIncome,
            ),
          ),
          const SizedBox(height: 12),
          _labeledFieldWithTooltip(
            label: 'employment_length'.tr(),
            tooltipKey: 'tooltip_emp_length',
            child: _sliderWithValue(
              label: 'employment_length'.tr(),
              min: 0,
              max: 40,
              step: 1,
              controller: _personalControllers['empLength']!,
              validator: _validateEmploymentLength,
            ),
          ),
          const SizedBox(height: 12),
          _labeledFieldWithTooltip(
            label: 'age'.tr(),
            tooltipKey: 'tooltip_age',
            child: _sliderWithValue(
              label: 'age'.tr(),
              min: 18,
              max: 70,
              step: 1,
              controller: _personalControllers['age']!,
              validator: Validators.validateAge,
            ),
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
          _pageTitle('loan_details'.tr()),
          const SizedBox(height: 16),
          _labeledFieldWithTooltip(
            label: 'loan_amount'.tr(),
            tooltipKey: 'tooltip_loan_amount',
            child: _sliderWithValue(
              label: 'loan_amount'.tr(),
              min: 10000,
              max: _loanHardCap,
              step: 5000,
              controller: _loanControllers['amount']!,
              prefix: '₹',
              validator: _validateLoanAmount,
            ),
          ),
          const SizedBox(height: 12),
          _labeledFieldWithTooltip(
            label: 'interest_rate'.tr(),
            tooltipKey: 'tooltip_interest',
            child: _sliderWithValue(
              label: 'interest_rate'.tr(),
              min: 5,
              max: 36,
              step: 0.5,
              controller: _loanControllers['intRate']!,
              suffix: '%',
              validator: Validators.validateInterestRate,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'loan_purpose'.tr(),
              helperText: 'loan_purpose_helper'.tr(),
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
            onChanged: (value) => _loanControllers['intent']!.text = value ?? '',
            validator: (value) => value == null ? 'please_select'.tr() : null,
          ),
          const SizedBox(height: 12),
          _labeledFieldWithTooltip(
            label: 'credit_history_length'.tr(),
            tooltipKey: 'tooltip_credit_history',
            child: _sliderWithValue(
              label: 'credit_history_length'.tr(),
              min: 0,
              max: 30,
              step: 1,
              controller: _loanControllers['credHistLength']!,
              validator: Validators.validateCreditHistory,
            ),
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
          _pageTitle('alternative_data'.tr()),
          const SizedBox(height: 12),
          _labeledFieldWithTooltip(
            label: 'estimated_monthly_income'.tr(),
            tooltipKey: 'tooltip_est_month_income',
            child: _sliderWithValue(
              label: 'estimated_monthly_income'.tr(),
              min: 3000,
              max: 100000,
              step: 500,
              controller: _alternativeControllers['monthlyIncome']!,
              prefix: '₹',
              // allow user to edit monthly income; onChanged will set _monthlyEdited
            ),
          ),
          const SizedBox(height: 12),
          _labeledFieldWithTooltip(
            label: 'phone_bills'.tr(), // label key should be added in translations as 'phone_bills'
            tooltipKey: 'tooltip_phone_bills',
            child: _sliderWithValue(
              label: 'phone_bills'.tr(),
              min: 0,
              max: 5000,
              step: 50,
              controller: _alternativeControllers['phoneBills']!,
              prefix: '₹',
            ),
          ),
          const SizedBox(height: 12),
          _labeledFieldWithTooltip(
            label: 'data_usage_gb'.tr(),
            tooltipKey: 'tooltip_data_usage',
            child: _sliderWithValue(
              label: 'data_usage_gb'.tr(),
              min: 0,
              max: 100,
              step: 1,
              controller: _alternativeControllers['dataUsage']!,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  title: Text('digital_wallet'.tr()),
                  subtitle: Text('digital_wallet_helper'.tr()),
                  value: _digitalWallet,
                  onChanged: (value) => setState(() => _digitalWallet = value),
                ),
              ),
              Expanded(
                child: SwitchListTile(
                  title: Text('mobile_banking'.tr()),
                  subtitle: Text('mobile_banking_helper'.tr()),
                  value: _mobileBanking,
                  onChanged: (value) => setState(() => _mobileBanking = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _pageTitle('utility_bills'.tr()),
          const SizedBox(height: 8),
          _labeledFieldWithTooltip(
            label: 'electric_bill'.tr(),
            tooltipKey: 'tooltip_electric',
            child: _sliderWithValue(
              label: 'electric_bill'.tr(),
              min: 0,
              max: 10000,
              step: 100,
              controller: _alternativeControllers['electricBill']!,
              prefix: '₹',
            ),
          ),
          const SizedBox(height: 12),
          _labeledFieldWithTooltip(
            label: 'water_bill'.tr(),
            tooltipKey: 'tooltip_water',
            child: _sliderWithValue(
              label: 'water_bill'.tr(),
              min: 0,
              max: 5000,
              step: 50,
              controller: _alternativeControllers['waterBill']!,
              prefix: '₹',
            ),
          ),
          const SizedBox(height: 12),
          _labeledFieldWithTooltip(
            label: 'gas_bill'.tr(),
            tooltipKey: 'tooltip_gas',
            child: _sliderWithValue(
              label: 'gas_bill'.tr(),
              min: 0,
              max: 5000,
              step: 50,
              controller: _alternativeControllers['gasBill']!,
              prefix: '₹',
            ),
          ),
          const SizedBox(height: 12),
          _pageTitle('payment_history_12m'.tr()),
          const SizedBox(height: 8),
          _labeledFieldWithTooltip(
            label: 'on_time_payments'.tr(),
            tooltipKey: 'tooltip_on_time',
            child: _sliderWithValue(
              label: 'on_time_payments'.tr(),
              min: 0,
              max: 12,
              step: 1,
              controller: _alternativeControllers['onTimePayments']!,
            ),
          ),
          const SizedBox(height: 12),
          _labeledFieldWithTooltip(
            label: 'late_payments'.tr(),
            tooltipKey: 'tooltip_late',
            child: _sliderWithValue(
              label: 'late_payments'.tr(),
              min: 0,
              max: 12,
              step: 1,
              controller: _alternativeControllers['latePayments']!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _labeledFieldWithTooltip({
    required String label,
    required String tooltipKey,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
            Tooltip(
              message: tooltipKey.tr(),
              preferBelow: true,
              child: Icon(Icons.info_outline, color: Colors.grey[600], size: 18),
            ),
          ],
        ),
        const SizedBox(height: 6),
        child,
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
    final parsed = double.tryParse(controller.text.replaceAll(',', '')) ?? min;
    final currentValue = parsed.clamp(min, max);
    final divisions = (step > 0) ? ((max - min) / step).round() : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            isDense: true,
            labelText: label,
            prefixText: prefix,
            suffixText: suffix,
            suffixIcon: IconButton(
              icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
              onPressed: () => _startListeningToController(controller),
            ),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (val) {
            // If user manually edits monthly income field, mark it as edited
            if (controller == _alternativeControllers['monthlyIncome']) {
              _monthlyEdited = true;
            }
            setState(() {});
          },
        ),
        Slider(
          value: currentValue,
          min: min,
          max: max,
          divisions: divisions,
          label: "${prefix ?? ''}${currentValue.toStringAsFixed(step < 1 ? 1 : 0)}${suffix ?? ''}",
          onChanged: (value) {
            setState(() {
              if (step < 1) {
                controller.text = value.toStringAsFixed(1);
              } else {
                controller.text = value.round().toString();
              }
            });
          },
        ),
      ],
    );
  }

  /// Validators
  String? _validateIncome(String? value) {
    final base = Validators.validateIncome(value);
    if (base != null) return base;
    return null;
  }

  String? _validateEmploymentLength(String? value) {
    final base = Validators.validateEmploymentLength(value);
    if (base != null) return base;

    // Additional business rule: employment length should be <= (age - 16)
    final ageText = _personalControllers['age']!.text;
    final empText = value ?? '';
    final age = int.tryParse(ageText) ?? -1;
    final empLen = double.tryParse(empText) ?? -1;

    if (age > 0 && empLen >= 0) {
      final maxAllowedEmp = (age - 16).toInt();
      if (empLen > maxAllowedEmp) {
        return 'Employment length seems too long for the given age. Maximum allowed is $maxAllowedEmp years.';
      }
    }
    return null;
  }

  String? _validateLoanAmount(String? value) {
    final base = Validators.validateLoanAmount(value);
    if (base != null) return base;

    final incomeText = _personalControllers['income']!.text;
    final loanText = value ?? '';
    final income = double.tryParse(incomeText.replaceAll(',', '')) ?? 0;
    final loan = double.tryParse(loanText.replaceAll(',', '')) ?? 0;

    double computedMax = income * _loanIncomeMultiplier;
    if (computedMax > _loanHardCap) computedMax = _loanHardCap;

    if (loan > computedMax) {
      return 'Requested loan exceeds maximum allowed (₹${computedMax.toStringAsFixed(0)}). Please reduce amount or increase income.';
    }

    return null;
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
        monthlyAirtimeSpend: double.tryParse(_alternativeControllers['phoneBills']!.text) ?? 0,
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
            content: Text('error_message'.tr(args: [state.error ?? ''])),
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
    try {
      if (_speech != null) {
        _speech!.stop();
      }
    } catch (_) {}
    super.dispose();
  }
}
