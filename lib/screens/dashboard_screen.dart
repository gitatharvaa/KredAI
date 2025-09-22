// flutter_app/lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_card_widget.dart';
import '../widgets/analytics_chart_widget.dart';
import '../utils/constants.dart';
import '../models/dashboard_model.dart';
import 'package:kredai/widgets/app_drawer.dart';
import 'application_form_screen.dart';
// import 'settings_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.mediumAnimationDuration,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);   
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final padding = width * 0.05;
    final spacing = height * 0.02;

    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColorValue),
      drawer: const AppDrawer(),  // Drawer added here
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(AppConstants.primaryColorValue),
        elevation: 0,
        centerTitle: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: dashboardState.isLoading
                    ? _buildLoadingState(width, spacing)
                    : dashboardState.error != null
                        ? _buildErrorState(dashboardState.error!, width, spacing)
                        : _buildDashboardContent(
                            dashboardState, width, height, spacing),
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => const ApplicationFormScreen()),
      //   ),
      //   backgroundColor: const Color(AppConstants.secondaryColorValue),
      //   icon: const Icon(Icons.add, color: Colors.white),
      //   label: const Text(
      //     'New Application',
      //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //   ),
      // ),
    );
  }

  Widget _buildLoadingState(double width, double spacing) {
    return Column(
      children: [
        SizedBox(height: spacing * 2.5),
        const CircularProgressIndicator(),
        SizedBox(height: spacing),
        Text(
          'Loading data...',
          style: TextStyle(fontSize: width * 0.045),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error, double width, double spacing) {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Color(AppConstants.dangerColorValue),
          ),
          SizedBox(height: spacing),
          Text(
            'Error loading data',
            style: TextStyle(
              fontSize: width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spacing * 0.5),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: width * 0.04, color: Colors.grey[600]),
          ),
          SizedBox(height: spacing),
          ElevatedButton(
            onPressed: () => ref.read(dashboardProvider.notifier).refreshData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(
    DashboardState state, double width, double height, double spacing) {
    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(width, spacing),
          SizedBox(height: spacing * 2),
          _buildQuickStats(state.stats!, width, spacing),
          SizedBox(height: spacing * 2),
          _buildQuickActions(width, spacing),
          SizedBox(height: spacing * 2),
          ApplicationTrendsChart(data: state.applicationTrends),
          SizedBox(height: spacing),
          RiskDistributionChart(data: state.riskDistribution),
          SizedBox(height: spacing * 2),
          SizedBox(height: height * 0.12), // Extra spacing for FAB
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(double width, double spacing) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: Container(
        padding: EdgeInsets.all(width * 0.04),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(AppConstants.primaryColorValue).withOpacity(0.1),
              const Color(AppConstants.primaryLightColorValue).withOpacity(0.05),
            ],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting! 👋',
                    style: TextStyle(
                      fontSize: width * 0.05,
                      fontWeight: FontWeight.bold,
                      color: const Color(AppConstants.primaryColorValue),
                    ),
                  ),
                  SizedBox(height: spacing * 0.3),
                  const Text(
                    'Welcome to your Credit Assessment System',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: spacing * 0.4),
                  Text(
                    DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: width * 0.035,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(width * 0.03),
              decoration: BoxDecoration(
                color:
                    const Color(AppConstants.primaryColorValue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.account_balance,
                size: width * 0.08,
                color: const Color(AppConstants.primaryColorValue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(DashboardStats stats, double width, double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: TextStyle(
            fontSize: width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: spacing),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: width < 600 ? 2 : 4,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: width < 600 ? 1 : 1.4,
          children: [
            DashboardCard(
              title: 'Total Applications',
              value: stats.totalApplications.toString(),
              subtitle: 'All time',
              icon: Icons.assignment,
              color: const Color(AppConstants.primaryColorValue),
              animationIndex: 0,
            ),
            DashboardCard(
              title: 'Approved',
              value: stats.approvedApplications.toString(),
              subtitle: '${(stats.approvalRate * 100).toStringAsFixed(1)}% rate',
              icon: Icons.check_circle,
              color: const Color(AppConstants.successColorValue),
              animationIndex: 1,
            ),
            DashboardCard(
              title: 'Pending',
              value: stats.pendingApplications.toString(),
              subtitle: 'Under review',
              icon: Icons.hourglass_empty,
              color: const Color(AppConstants.warningColorValue),
              animationIndex: 2,
            ),
            DashboardCard(
              title: 'Total Disbursed',
              value:
                  '₹${NumberFormat('#,##,###').format(stats.totalDisbursed)}',
              subtitle: 'Approved loan amount',
              icon: Icons.account_balance_wallet,
              color: const Color(AppConstants.secondaryColorValue),
              animationIndex: 3,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(double width, double spacing) {
    final crossAxisCount = width < 400 ? 2 : 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: spacing),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: 0.9,
          children: [
            QuickActionCard(
              title: 'New Application',
              icon: Icons.add_circle_outline,
              color: const Color(AppConstants.primaryColorValue),
              animationIndex: 0,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ApplicationFormScreen()),
              ),
            ),
            QuickActionCard(
              title: 'Search Applications',
              icon: Icons.search,
              color: const Color(AppConstants.infoColorValue),
              animationIndex: 1,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search feature coming soon!')),
                );
              },
            ),
            QuickActionCard(
              title: 'Reports',
              icon: Icons.bar_chart,
              color: const Color(AppConstants.successColorValue),
              animationIndex: 2,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reports feature coming soon!')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
