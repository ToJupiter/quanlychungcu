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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 900) {
              return _buildMobilePaymentView();
            } else {
              return _buildDesktopPaymentTable();
            }
          },
        ),
      ),
    );
  }

  Widget _buildDesktopPaymentTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          ),
          headingRowHeight: 56,
          dataRowMaxHeight: 72,
          columnSpacing: 12,
          horizontalMargin: 24,
          columns: [
            DataColumn(
              label: const Text(
                'ID',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: const Text(
                'Căn hộ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: const Text(
                'Loại thanh toán',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: const Text(
                'Số tiền',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              numeric: true,
            ),
            DataColumn(
              label: const Text(
                'Hạn thanh toán',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: const Text(
                'Ngày thanh toán',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: const Text(
                'Trạng thái',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const DataColumn(
              label: Text(
                'Thao tác',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: _filteredPayments.asMap().entries.map((entry) {
            final index = entry.key;
            final payment = entry.value;
            final isEven = index % 2 == 0;
            
            return DataRow(
              color: WidgetStateProperty.all(
                isEven 
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              cells: [
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        payment.id.length > 6 ? payment.id.substring(0, 6) + "..." : payment.id,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.apartment,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          payment.apartmentNumber ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        payment.paymentType,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      payment.formattedAmount,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          payment.formattedDueDate,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        if (payment.dueDate != null && payment.status != PaymentStatus.paid)
                          Text(
                            _getDaysUntilDue(payment.dueDate!),
                            style: TextStyle(
                              fontSize: 11,
                              color: _getDueDateColor(payment.dueDate!),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      payment.formattedPaymentDate,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(payment.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getStatusColor(payment.status).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        payment.status,
                        style: TextStyle(
                          color: _getStatusColor(payment.status),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton.filledTonal(
                          icon: const Icon(Icons.edit, size: 18),
                          tooltip: "Chỉnh sửa",
                          onPressed: () => _navigateToEditForm(payment),
                        ),
                        const SizedBox(width: 4),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.receipt_long, size: 18),
                          tooltip: "Chi tiết & Cập nhật",
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                          onPressed: () => _showUpdateStatusModal(payment),
                        ),
                        const SizedBox(width: 4),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.delete, size: 18),
                          tooltip: "Xóa",
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.errorContainer,
                            foregroundColor: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _deletePayment(payment.id),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobilePaymentView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredPayments.length,
      itemBuilder: (context, index) {
        final payment = _filteredPayments[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(payment.status).withOpacity(0.2),
              child: Icon(
                Icons.payment,
                color: _getStatusColor(payment.status),
                size: 20,
              ),
            ),
            title: Text(
              'Căn hộ ${payment.apartmentNumber ?? 'N/A'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.paymentType),
                Text(
                  payment.formattedAmount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPaymentInfoRow(Icons.schedule, 'Hạn thanh toán', payment.formattedDueDate),
                    const SizedBox(height: 8),
                    _buildPaymentInfoRow(Icons.payment, 'Ngày thanh toán', payment.formattedPaymentDate),
                    const SizedBox(height: 8),
                    _buildPaymentInfoRow(Icons.info_outline, 'Trạng thái', payment.status),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Sửa'),
                          onPressed: () => _navigateToEditForm(payment),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.receipt_long, size: 16),
                          label: const Text('Chi tiết'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                          onPressed: () => _showUpdateStatusModal(payment),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Xóa'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _deletePayment(payment.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  String _getDaysUntilDue(DateTime dueDate) {
    final days = dueDate.difference(DateTime.now()).inDays;
    if (days < 0) {
      return 'Quá hạn ${(-days)} ngày';
    } else if (days == 0) {
      return 'Hết hạn hôm nay';
    } else if (days <= 7) {
      return 'Còn $days ngày';
    } else {
      return '';
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final days = dueDate.difference(DateTime.now()).inDays;
    if (days < 0) {
      return Colors.red;
    } else if (days <= 3) {
      return Colors.orange;
    } else if (days <= 7) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
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