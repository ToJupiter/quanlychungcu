import 'package:flutter/material.dart';
import '../screens/dashboard_view.dart'; // Example import
import '../screens/apartment_list_view.dart';
import '../screens/household_list_view.dart';
import '../screens/payment_list_view.dart';
import '../screens/financial_report_view.dart';
import '../screens/staff_registration_view.dart';
import '../screens/staff_list_view.dart';
import '../screens/change_password_view.dart';
import '../screens/login_view.dart'; // For logout
import '../services/auth_service.dart'; // Added for role checking

class MainLayout extends StatefulWidget {
  final Widget child;
  final String? currentRoute;

  const MainLayout({super.key, required this.child, this.currentRoute});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final AuthService _authService = AuthService();
  String? _userRole;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authData = await _authService.getAuthData();
    if (mounted) {
      setState(() {
        _userName = authData['fullName'] ?? 'User';
        _userRole = authData['role'];
      });
    }
  }

  // Helper to create navigation tiles
  Widget _buildNavItem(BuildContext context, IconData icon, String title, String routeName, Widget destinationScreen) {
    final bool isSelected = widget.currentRoute == routeName;
    final Color? activeColor = Theme.of(context).colorScheme.secondary;
    final Color? inactiveColor = Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7);

    return ListTile(
      leading: Icon(icon, color: isSelected ? activeColor : inactiveColor),
      title: Text(
        title,
        style: TextStyle(color: isSelected ? activeColor : inactiveColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      ),
      tileColor: isSelected ? activeColor?.withOpacity(0.1) : null,
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (!isSelected) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainLayout(currentRoute: routeName, child: destinationScreen)),
          );
        }
      },
    );
  }

  void _logout(BuildContext context) async { // Make async for service call
    await _authService.logout(); // Clear auth data from service
    if (mounted) {
        Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
        (Route<dynamic> route) => false, 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HỆ THỐNG QUẢN LÝ CHUNG CƯ'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        actions: [
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(_userName?.substring(0,1).toUpperCase() ?? 'U', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
            ),
            onSelected: (value) {
              if (value == 'changePassword') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainLayout(currentRoute: ChangePasswordView.routeName, child: ChangePasswordView())),
                );
              } else if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'userName',
                enabled: false, // Not selectable, just for display
                child: Text(_userName ?? 'Loading...', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'changePassword',
                child: ListTile(
                  leading: Icon(Icons.vpn_key_outlined),
                  title: Text('Đổi mật khẩu'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Đăng xuất'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ]
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Container(
              height: 120, // Adjust height as needed
              width: double.infinity,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BlueMoon Condo', // App Logo/Title
                    style: TextStyle(
                      color: Colors.black, 
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _userName ?? '', 
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                ],
              )
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _buildNavItem(context, Icons.dashboard_outlined, 'Dashboard', DashboardView.routeName, const DashboardView()),
                  _buildNavItem(context, Icons.apartment_outlined, 'Căn hộ', ApartmentListView.routeName, const ApartmentListView()),
                  _buildNavItem(context, Icons.people_outline, 'Hộ gia đình', HouseholdListView.routeName, const HouseholdListView()),
                  _buildNavItem(context, Icons.payment_outlined, 'Thanh toán', PaymentListView.routeName, const PaymentListView()),
                  _buildNavItem(context, Icons.bar_chart_outlined, 'Báo cáo', FinancialReportView.routeName, const FinancialReportView()),
                  _buildNavItem(context, Icons.people_alt_outlined, 'Quản lý nhân viên', StaffListView.routeName, const StaffListView()),
                  if (_userRole == 'admin') // Conditionally show Staff Registration
                    _buildNavItem(context, Icons.person_add_alt_1_outlined, 'Đăng ký nhân viên', StaffRegistrationView.routeName, const StaffRegistrationView()),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7)),
              title: Text('Đăng xuất', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7))),
              onTap: () => _logout(context),
            ),
            const SizedBox(height: 8), // Some padding at the bottom
          ],
        ),
      ),
      body: widget.child,
    );
  }
} 