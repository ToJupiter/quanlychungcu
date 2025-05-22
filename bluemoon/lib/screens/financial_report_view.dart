import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/payment_service.dart';
import '../widgets/month_year_picker.dart'; // Re-use for selecting month/year for report
import 'main_layout.dart';
import 'package:fl_chart/fl_chart.dart'; // Added for charts

class FinancialReportView extends StatefulWidget {
  static const String routeName = '/financial-reports';
  const FinancialReportView({super.key});

  @override
  State<FinancialReportView> createState() => _FinancialReportViewState();
}

class _FinancialReportViewState extends State<FinancialReportView> {
  final PaymentService _paymentService = PaymentService();
  Map<String, dynamic>? _summaryData;
  bool _isLoading = true;
  String? _error;
  DateTime _selectedMonthYear = DateTime.now(); // Default to current month

  final DateFormat _monthYearFormatter = DateFormat('MM/yyyy');
  final DateFormat _apiMonthYearFormatter = DateFormat('yyyy-MM');
  final NumberFormat _currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _fetchFinancialSummary();
  }

  Future<void> _fetchFinancialSummary() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final summary = await _paymentService.fetchFinancialSummary(monthYear: _apiMonthYearFormatter.format(_selectedMonthYear));
      setState(() {
        _summaryData = summary;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst("Exception: ", "");
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectMonthYear(BuildContext context) async {
    final DateTime? picked = await showMonthYearPicker(
      context,
      initialDate: _selectedMonthYear,
      firstDate: DateTime(DateTime.now().year - 5), // Allow reports for past 5 years
      lastDate: DateTime.now(), // Up to current month
    );
    // Compare only month and year to ensure change is detected correctly
    if (picked != null && 
        (picked.year != _selectedMonthYear.year || picked.month != _selectedMonthYear.month)) {
      setState(() {
        _selectedMonthYear = picked; // Day will be 1st, time 00:00 from picker logic
      });
      _fetchFinancialSummary(); // Re-fetch with new month/year filter
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Báo cáo Tài chính'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Tải lại báo cáo',
              onPressed: _fetchFinancialSummary,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _fetchFinancialSummary,
          child: Column(
            children: [
              _buildMonthSelector(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('Lỗi tải báo cáo: $_error', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center)))
                        : _summaryData == null || _summaryData!.isEmpty
                            ? const Center(child: Text('Không có dữ liệu báo cáo cho tháng đã chọn.'))
                            : _buildReportContent(),
              ),
            ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Xem báo cáo cho tháng: ', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(_monthYearFormatter.format(_selectedMonthYear)),
            onPressed: () => _selectMonthYear(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    // Backend keys: totalCollected, totalDueInPeriod, totalOutstandingUnpaid
    final double totalCollected = (_summaryData!['totalCollected'] as num?)?.toDouble() ?? 0.0;
    final double totalDueInPeriod = (_summaryData!['totalDueInPeriod'] as num?)?.toDouble() ?? 0.0; 
    final double totalOutstandingUnpaid = (_summaryData!['totalOutstandingUnpaid'] as num?)?.toDouble() ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tổng quan Tài chính - Tháng ${_monthYearFormatter.format(_selectedMonthYear)}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Row for the three main summary cards
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Align cards to the top if they have different heights
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context,
                  title: 'Phải Thu (Kỳ)', // Shortened title
                  value: _currencyFormatter.format(totalDueInPeriod),
                  icon: Icons.assignment_turned_in_outlined,
                  color: Colors.blue,
                  isSmall: true, // Make all cards in this row small
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  title: 'Đã Thu (Kỳ)',
                  value: _currencyFormatter.format(totalCollected),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  isSmall: true, // Make all cards in this row small
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  title: 'Tồn Đọng (Cuối Kỳ)', // Shortened title
                  value: _currencyFormatter.format(totalOutstandingUnpaid),
                  icon: Icons.error_outline,
                  color: Colors.orange,
                  isSmall: true, // Make all cards in this row small
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Biểu đồ Doanh Thu (Minh Họa)',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (totalDueInPeriod > 0 ? totalDueInPeriod * 1.2 : 1000000), // Dynamic max Y
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => SideTitleWidget(axisSide: meta.axisSide, child: Text(_currencyFormatter.format(value).replaceAll('₫', '').trim() + 'tr', style: const TextStyle(fontSize: 10))))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => SideTitleWidget(axisSide: meta.axisSide, child: Text(['Phải Thu', 'Đã Thu', 'Tồn Đọng'][value.toInt()], style: const TextStyle(fontSize: 10))))),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true, checkToShowHorizontalLine: (value) => value % ( (totalDueInPeriod > 0 ? totalDueInPeriod : 1000000) / 5) == 0),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: totalDueInPeriod, color: Colors.blue, width: 25)]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: totalCollected, color: Colors.green, width: 25)]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: totalOutstandingUnpaid, color: Colors.orange, width: 25)]),
                ],
                ),
              ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '(Số liệu phiếu thu và biểu đồ chi tiết hơn sẽ được cập nhật sớm)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, {required String title, required String value, required IconData icon, Color? color, bool isSmall = false}) {
    final cardColor = color ?? Theme.of(context).colorScheme.surfaceVariant;
    final iconColor = color != null ? Colors.white.withOpacity(0.8) : Theme.of(context).colorScheme.onSurfaceVariant;
    final textColor = color != null ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant;
    
    final titleStyle = (isSmall ? Theme.of(context).textTheme.titleSmall : Theme.of(context).textTheme.titleMedium)?.copyWith(color: textColor, fontWeight: FontWeight.w600);
    final valueStyle = (isSmall ? Theme.of(context).textTheme.headlineSmall : Theme.of(context).textTheme.headlineMedium)?.copyWith(color: textColor, fontWeight: FontWeight.bold);

    
    return Card(
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Slightly smaller radius
      child: Padding(
        padding: EdgeInsets.all(isSmall ? 10.0 : 12.0), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Make column take minimum space
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                  title,
                    style: titleStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, size: isSmall ? 24 : 30, color: iconColor), // Smaller icon
              ],
            ),
            const SizedBox(height: 6), // Reduced spacing
            Text(
              value,
              style: valueStyle,
            ),
          ],
        ),
      ),
    );
  }
} 