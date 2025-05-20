import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import '../widgets/month_year_picker.dart'; // We'll create this helper
import 'payment_form_view.dart';
import 'main_layout.dart'; // To navigate via MainLayout
import '../widgets/payment_details_status_modal.dart'; // For later use
// import 'payment_details_status_modal.dart'; // For later use

class PaymentListView extends StatefulWidget {
  static const String routeName = '/payments';
  const PaymentListView({super.key});

  @override
  State<PaymentListView> createState() => _PaymentListViewState();
}

class _PaymentListViewState extends State<PaymentListView> {
  final PaymentService _paymentService = PaymentService();
  List<Payment> _payments = [];
  List<Payment> _filteredPayments = [];
  bool _isLoading = true;
  String? _error;

  // Filters
  String? _selectedStatus;
  String? _selectedPaymentType;
  DateTime? _selectedMonthYear; // For YYYY-MM filtering
  final TextEditingController _searchController = TextEditingController();

  final DateFormat _monthYearFormatter = DateFormat('MM/yyyy');
  final DateFormat _apiMonthYearFormatter = DateFormat('yyyy-MM');

  @override
  void initState() {
    super.initState();
    _fetchPayments();
    _searchController.addListener(_filterPaymentsLocally);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPayments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final payments = await _paymentService.fetchPayments(
        status: _selectedStatus,
        paymentType: _selectedPaymentType,
        monthYear: _selectedMonthYear != null ? _apiMonthYearFormatter.format(_selectedMonthYear!) : null,
      );
      setState(() {
        _payments = payments;
        _filteredPayments = payments; // Initially, filtered list is the full list
        _filterPaymentsLocally(); // Apply local search text if any
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

  void _filterPaymentsLocally() {
    List<Payment> tempFiltered = List.from(_payments);
    String searchTerm = _searchController.text.toLowerCase();

    if (searchTerm.isNotEmpty) {
      tempFiltered = tempFiltered.where((payment) {
        final apartmentMatch = payment.apartmentNumber?.toLowerCase().contains(searchTerm) ?? false;
        // Add more fields for local search if needed, e.g., household ID, notes
        return apartmentMatch;
      }).toList();
    }

    setState(() {
      _filteredPayments = tempFiltered;
    });
  }

  void _clearFiltersAndFetch() {
    setState(() {
      _selectedStatus = null;
      _selectedPaymentType = null;
      _selectedMonthYear = null;
      _searchController.clear(); // This will also trigger _filterPaymentsLocally due to listener
    });
    _fetchPayments(); // Refetch with no server-side filters
  }
  
  Future<void> _selectMonthYear(BuildContext context) async {
    final DateTime? picked = await showMonthYearPicker(context, initialDate: _selectedMonthYear ?? DateTime.now());
    if (picked != null && picked != _selectedMonthYear) {
      setState(() {
        _selectedMonthYear = picked;
      });
      _fetchPayments(); // Re-fetch with new month/year filter
    }
  }

  Future<void> _navigateToCreateForm() async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaymentFormView()),
    );
    if (result == true) {
      _fetchPayments(); // Refresh list if a payment was created
    }
  }

  Future<void> _navigateToEditForm(Payment payment) async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentFormView(payment: payment)),
    );
    if (result == true) {
      _fetchPayments(); // Refresh list if a payment was updated
    }
  }
  
  Future<void> _deletePayment(String paymentId) async {
    final bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
            return AlertDialog(
            title: const Text('Xác nhận Xóa'),
            content: const Text('Bạn có chắc chắn muốn xóa khoản thanh toán này?'),
            actions: <Widget>[
                TextButton(child: const Text('Hủy'), onPressed: () => Navigator.of(context).pop(false)),
                TextButton(child: const Text('Xóa', style: TextStyle(color: Colors.red)), onPressed: () => Navigator.of(context).pop(true)),
            ],
            );
        },
        ) ?? false;

    if (confirmDelete) {
        setState(() { _isLoading = true; });
        try {
            await _paymentService.deletePayment(paymentId);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Khoản thanh toán đã được xóa.'), backgroundColor: Colors.green)
            );
            _fetchPayments(); // Refresh
        } catch (e) {
            if (mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi xóa: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Theme.of(context).colorScheme.error)
                );
            }
            setState(() { _isLoading = false; });
        }
    }
  }
  
  Future<void> _showUpdateStatusModal(Payment payment) async {
    final bool? result = await showPaymentDetailsStatusModal(context, payment);
    if (result == true && mounted) {
      _fetchPayments(); // Refresh list if status was updated
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trạng thái thanh toán đã được cập nhật.'), backgroundColor: Colors.green),
      );
    } else if (result == false && mounted) {
      // Optional: Show a message if no changes were made, or just do nothing
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Không có thay đổi nào được thực hiện.')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Thanh toán'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Tạo phiếu thu mới',
            onPressed: _navigateToCreateForm,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: _fetchPayments,
          )
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('Lỗi: $_error', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center)))
                    : RefreshIndicator(
                        onRefresh: _fetchPayments,
                        child: _filteredPayments.isEmpty
                            ? Center(child: Text(_payments.isEmpty ? 'Không có khoản thanh toán nào.' : 'Không có kết quả nào khớp với tìm kiếm/lọc của bạn.'))
                            : _buildPaymentDataTable(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Tìm theo số căn hộ...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12) // Adjusted padding
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Trạng thái', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)), // Adjusted padding & isDense
                  value: _selectedStatus,
                  hint: const Text('Tất cả'),
                  isExpanded: true,
                  items: [const DropdownMenuItem<String>(value: null, child: Text('Tất cả'))]
                      .followedBy(PaymentStatus.all.map((status) => DropdownMenuItem(value: status, child: Text(status))))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                    _fetchPayments();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Loại thanh toán', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)), // Adjusted padding & isDense
                  value: _selectedPaymentType,
                  hint: const Text('Tất cả'),
                  isExpanded: true,
                  items: [const DropdownMenuItem<String>(value: null, child: Text('Tất cả'))]
                      .followedBy(PaymentType.all.map((type) => DropdownMenuItem(value: type, child: Text(type))))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedPaymentType = value);
                    _fetchPayments();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => _selectMonthYear(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Tháng/Năm',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12), // Adjusted padding & isDense
                      suffixIcon: _selectedMonthYear != null ? IconButton(icon: const Icon(Icons.clear, size: 20), onPressed: (){ setState(()=>_selectedMonthYear = null); _fetchPayments();}) : null,
                    ),
                    child: Text(_selectedMonthYear != null ? _monthYearFormatter.format(_selectedMonthYear!) : 'Tất cả', style: const TextStyle(fontSize: 14)), // Ensure text size is controlled
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: "Xóa bộ lọc & tải lại",
                child: IconButton.filledTonal(
                  icon: const Icon(Icons.clear_all),
                  onPressed: _clearFiltersAndFetch,
                  padding: const EdgeInsets.all(10), // Adjust padding for button size
                  iconSize: 20, // Adjust icon size
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPaymentDataTable() {
    final columns = [
      DataColumn(label: Text('ID', style: Theme.of(context).textTheme.titleSmall)),
      DataColumn(label: Text('Số Căn Hộ', style: Theme.of(context).textTheme.titleSmall)),
      DataColumn(label: Text('Loại TT', style: Theme.of(context).textTheme.titleSmall)),
      DataColumn(label: Text('Số Tiền', style: Theme.of(context).textTheme.titleSmall), numeric: true),
      DataColumn(label: Text('Ngày TT', style: Theme.of(context).textTheme.titleSmall)),
      DataColumn(label: Text('Hạn TT', style: Theme.of(context).textTheme.titleSmall)),
      DataColumn(label: Text('Trạng Thái', style: Theme.of(context).textTheme.titleSmall)),
      DataColumn(label: Text('Hành Động', style: Theme.of(context).textTheme.titleSmall)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.vertical, // Ensure vertical scroll for the table itself if content overflows
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Allow horizontal scroll for wide tables
        child: DataTable(
          columns: columns,
          rows: _filteredPayments.map((payment) {
            return DataRow(
              cells: [
                DataCell(Text(payment.id.substring(0, 6) + "...")), // Shorten ID
                DataCell(Text(payment.apartmentNumber ?? 'N/A')),
                DataCell(Text(payment.paymentType)),
                DataCell(Text(payment.formattedAmount)),
                DataCell(Text(payment.formattedPaymentDate)),
                DataCell(Text(payment.formattedDueDate)),
                DataCell(Text(payment.status, style: TextStyle(color: _getStatusColor(payment.status)))),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, size: 20), tooltip: "Sửa", onPressed: () => _navigateToEditForm(payment)),
                    IconButton(icon: Icon(Icons.receipt_long, size: 20, color: Colors.blueGrey[600]), tooltip: "Chi tiết & Cập nhật TT", onPressed: () => _showUpdateStatusModal(payment)),
                    IconButton(icon: Icon(Icons.delete, size: 20, color: Theme.of(context).colorScheme.error), tooltip: "Xóa", onPressed: () => _deletePayment(payment.id)),
                  ],
                )),
              ],
            );
          }).toList(),
          columnSpacing: 10,
          headingRowHeight: 40,
          dataRowMaxHeight: 48,
          showCheckboxColumn: false,
        ),
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.overdue:
        return Colors.red;
      case PaymentStatus.cancelled:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
} 