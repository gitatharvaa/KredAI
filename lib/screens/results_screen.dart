// flutter_app/lib/screens/results_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kredai/screens/dashboard_screen.dart';
import '../providers/application_provider.dart';
import '../widgets/risk_gauge_widget.dart';
import '../widgets/shap_chart_widget.dart';
import '../utils/constants.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  bool _explanationLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExplanation();
    });
  }

  void _loadExplanation() async {
    final state = ref.read(applicationProvider);
    if (state.applicationResponse != null) {
      final applicationId = state.applicationResponse!['application_id'];
      await ref.read(applicationProvider.notifier).getExplanation(applicationId);
      setState(() => _explanationLoaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicationState = ref.watch(applicationProvider);
    final predictionResult = applicationState.predictionResult;
    final explanation = applicationState.explanation;

    if (predictionResult == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Results'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            ref.read(applicationProvider.notifier).clearState();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // Risk Assessment Card
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Credit Assessment Result',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // Risk Gauge
                    SizedBox(
                      height: 200,
                      child: RiskGaugeWidget(
                        riskProbability: predictionResult.riskProbability,
                        riskCategory: predictionResult.riskCategory,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: predictionResult.isApproved 
                          ? const Color(AppConstants.successColorValue)
                          : const Color(AppConstants.dangerColorValue),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            predictionResult.isApproved 
                              ? Icons.check_circle 
                              : Icons.cancel,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            predictionResult.loanStatus,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Risk Details
                    _buildRiskDetails(predictionResult),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Explanation Section
            if (_explanationLoaded && explanation != null)
              _buildExplanationSection(explanation)
            else if (!_explanationLoaded)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading explanation...'),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(applicationProvider.notifier).clearState();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text('New Assessment'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // In a real app, this would navigate to loan application
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Loan application feature coming soon!'),
                        ),
                      );
                    },
                    child: Text(predictionResult.isApproved ? 'Apply for Loan' : 'Improve Profile'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskDetails(predictionResult) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildDetailRow('Risk Probability', '${(predictionResult.riskProbability * 100).toStringAsFixed(1)}%'),
          const Divider(),
          _buildDetailRow('Risk Category', predictionResult.riskCategory),
          const Divider(),
          _buildDetailRow('Model Confidence', '${(predictionResult.confidence * 100).toStringAsFixed(1)}%'),
          const Divider(),
          _buildDetailRow('Assessment Time', predictionResult.predictionTimestamp.split('T')[0]),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExplanationSection(explanation) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: Color(AppConstants.primaryColorValue)),
                const SizedBox(width: 8),
                Text(
                  'AI Explanation',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Understanding the factors that influenced your assessment',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // SHAP Chart
            SizedBox(
              height: 300,
              child: ShapChartWidget(explanation: explanation),
            ),
            
            const SizedBox(height: 24),
            
            // Readable Explanations
            Text(
              'Key Factors:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ...explanation.readableExplanation.take(5).map((exp) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.fiber_manual_record, size: 8, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        exp,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ).toList(),
          ],
        ),
      ),
    );
  }
}
