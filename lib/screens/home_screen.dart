// flutter_app/lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'application_form_screen.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isHealthy = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkBackendHealth();
  }

  Future<void> _checkBackendHealth() async {
    final apiService = ApiService();
    final isHealthy = await apiService.checkHealth();
    setState(() {
      _isHealthy = isHealthy;
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(AppConstants.primaryColorValue).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.primaryColorValue),
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(AppConstants.primaryColorValue).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // App Title
                Text(
                  'Credit Risk Assessment',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(AppConstants.primaryColorValue),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Subtitle
                Text(
                  'For Underbanked People',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Technology badges
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    _buildTechChip('Federated Learning'),
                    _buildTechChip('Explainable AI'),
                    _buildTechChip('Alternative Data'),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // Backend Status
                _buildStatusCard(),
                
                const SizedBox(height: 32),
                
                // Start Assessment Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isHealthy 
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ApplicationFormScreen(),
                          ),
                        )
                      : null,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Start Credit Assessment',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Info text
                Text(
                  'Powered by AI and Machine Learning\nSecure • Fast • Transparent',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTechChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: const Color(AppConstants.primaryColorValue).withOpacity(0.1),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _isChecking 
              ? Icons.sync 
              : (_isHealthy ? Icons.check_circle : Icons.error),
            color: _isChecking 
              ? Colors.orange 
              : (_isHealthy ? Colors.green : Colors.red),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Backend Status',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isChecking 
                    ? 'Checking connection...' 
                    : (_isHealthy ? 'Connected and Ready' : 'Backend Unavailable'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (!_isHealthy && !_isChecking)
            TextButton(
              onPressed: () {
                setState(() => _isChecking = true);
                _checkBackendHealth();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}

