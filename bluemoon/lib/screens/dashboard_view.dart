import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For currency formatting
import '../screens/household_list_view.dart';
import '../screens/financial_report_view.dart';
import '../screens/staff_list_view.dart';
import '../screens/main_layout.dart'; 
import '../services/apartment_service.dart'; // For apartment count
import '../services/payment_service.dart';   // For financial summary
import '../services/household_service.dart'; // For resident count

class DashboardView extends StatefulWidget {
  static const String routeName = '/'; // For MainLayout navigation
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final ApartmentService _apartmentService = ApartmentService();
  final PaymentService _paymentService = PaymentService();
  final HouseholdService _householdService = HouseholdService();

  String _totalApartments = '--';
  String _totalRevenueThisMonth = '--';
  String _totalResidents = '--';
  final String _serviceRequests = 'N/A'; // Placeholder, as it's not implemented yet
  bool _isLoading = true;
  String? _error;

  final NumberFormat _currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final DateFormat _apiMonthYearFormatter = DateFormat('yyyy-MM');

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch all data in parallel
      final apartmentList = await _apartmentService.fetchApartments(); // Fetch the list
      final financialSummaryResult = await _paymentService.fetchFinancialSummary(monthYear: _apiMonthYearFormatter.format(DateTime.now()));
      final residentsCountResult = await _householdService.getResidentsCount();


      // Process apartment count
      _totalApartments = apartmentList.length.toString(); // Get length of the list
      
      // Process financial summary - fixed revenue calculation to reflect actual paid amounts
      final financialSummary = financialSummaryResult; // Already a Map<String, dynamic>
      // Use totalCollected which represents actual paid revenue, not just due amounts
      final double totalRevenue = (financialSummary['totalCollected'] as num?)?.toDouble() ?? 0.0;
      _totalRevenueThisMonth = _currencyFormatter.format(totalRevenue);

      // Process residents count
      _totalResidents = residentsCountResult.toString();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst("Exception: ", "");
          _totalApartments = 'Lỗi';
          _totalRevenueThisMonth = 'Lỗi';
          _totalResidents = 'Lỗi';
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, {bool isLoading = false}) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 36, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 12.0),
            if (isLoading)
              const SizedBox(height:22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
            else
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 4.0),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton(BuildContext context, String title, IconData icon, VoidCallback onPressed, {bool comingSoon = false}) {
    return Expanded(
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: InkWell(
          onTap: comingSoon ? null : onPressed,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 32, color: comingSoon ? Colors.grey : Theme.of(context).colorScheme.secondary),
                const SizedBox(height: 8.0),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: comingSoon ? Colors.grey : null),
                ),
                if (comingSoon)
                  const Text(
                    '(Sắp ra mắt)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (_error != null)
                  IconButton(
                    icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                    tooltip: _error,
                    onPressed: (){ /* Maybe show full error in a dialog */}
                  )
              ],
            ),
            const SizedBox(height: 20.0),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2, 
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.2 : 1.1,
              children: <Widget>[
                _buildMetricCard(context, 'Tổng số căn hộ', _totalApartments, Icons.apartment_outlined, isLoading: _isLoading),
                _buildMetricCard(context, 'Doanh Thu (Tháng)', _totalRevenueThisMonth, Icons.trending_up_outlined, isLoading: _isLoading),
                _buildMetricCard(context, 'Tổng số cư dân', _totalResidents, Icons.people_alt_outlined, isLoading: _isLoading),
                _buildMetricCard(context, 'Yêu cầu dịch vụ', _serviceRequests, Icons.build_circle_outlined, isLoading: false), // Not loading this one yet
              ],
            ),
            const SizedBox(height: 32.0),
            Text(
              'Truy cập nhanh',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildQuickAccessButton(
                  context,
                  'Quản lý Hộ GĐ',
                  Icons.groups_outlined,
                  () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainLayout(currentRoute: HouseholdListView.routeName, child: HouseholdListView())),
                    );
                  }
                ),
                const SizedBox(width: 16),
                _buildQuickAccessButton(
                  context,
                  'Xem Báo cáo',
                  Icons.assessment_outlined,
                  () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainLayout(currentRoute: FinancialReportView.routeName, child: FinancialReportView())),
                    );
                  }
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildQuickAccessButton(
                  context,
                  'Gửi Thông báo',
                  Icons.notifications_active_outlined,
                  () {},
                  comingSoon: true
                ),
                const SizedBox(width: 16),
                _buildQuickAccessButton(
                  context,
                  'Quản lý Nhân viên',
                  Icons.people_alt_outlined,
                  () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainLayout(currentRoute: StaffListView.routeName, child: StaffListView())),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
} 