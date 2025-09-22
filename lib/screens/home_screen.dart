// flutter_app/lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'application_form_screen.dart';
import 'dashboard_screen.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

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
    final authState = ref.watch(authProvider);

    // Responsive helpers
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final padding = width * 0.05; // responsive padding ~5% of width
    final spacing = height * 0.02; // responsive vertical spacing
    final buttonHeight = height * 0.07; // responsive button height

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'dashboard':
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                  );
                  break;
                case 'logout':
                  _showLogoutDialog();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'dashboard',
                child: ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Dashboard'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  authState.user?.displayName?.substring(0, 1).toUpperCase() ??
                  authState.user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(
                    color: const Color(AppConstants.primaryColorValue),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
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
            padding: EdgeInsets.all(padding),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: height - (kToolbarHeight + MediaQuery.of(context).padding.top),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Welcome Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(padding),
                          child: Column(
                            children: [
                              Text(
                                'Hello! ${authState.user?.displayName ?? 'Friend'}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(AppConstants.primaryColorValue),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: spacing * 0.5),
                              Text(
                                'Welcome to your Credit Assessment System',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: spacing * 2),

                      // App Logo/Icon
                      Container(
                        width: width * 0.3,
                        height: width * 0.3,
                        decoration: BoxDecoration(
                          color: const Color(AppConstants.primaryColorValue),
                          borderRadius: BorderRadius.circular(width * 0.15),
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

                      SizedBox(height: spacing * 2),

                      // App Title
                      Text(
                        'Credit Risk Assessment',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(AppConstants.primaryColorValue),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: spacing),

                      // Subtitle
                      Text(
                        'For Underbanked People',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: spacing * 0.5),

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

                      SizedBox(height: spacing * 2.5),

                      // Backend Status
                      _buildStatusCard(),

                      SizedBox(height: spacing * 2),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: buttonHeight,
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                                ),
                                icon: const Icon(Icons.dashboard),
                                label: const Text('Dashboard'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(AppConstants.primaryColorValue),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: spacing),
                          Expanded(
                            child: SizedBox(
                              height: buttonHeight,
                              child: ElevatedButton.icon(
                                onPressed: _isHealthy 
                                  ? () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ApplicationFormScreen(),
                                      ),
                                    )
                                  : null,
                                icon: const Icon(Icons.add),
                                label: const Text('New Application'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(AppConstants.secondaryColorValue),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: spacing),

                      // Info text
                      Text(
                        'Powered by AI and Machine Learning\nSecure • Fast • Transparent',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Fill remaining space if any
                      const Spacer(),
                    ],
                  ),
                ),
              ),
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(authProvider.notifier).signOut();
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
