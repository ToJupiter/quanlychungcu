import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import '../services/household_service.dart'; // To fetch households for dropdown
import '../models/household_model.dart'; // For household selection
import '../widgets/month_year_picker.dart'; // For due date (optional)

class PaymentFormView extends StatefulWidget {
  final Payment? payment; // For editing existing payment
  const PaymentFormView({super.key, this.payment});

  @override
  State<PaymentFormView> createState() => _PaymentFormViewState();
}

class _PaymentFormViewState extends State<PaymentFormView> {
  final _formKey = GlobalKey<FormState>();
  final PaymentService _paymentService = PaymentService();
  final HouseholdService _householdService = HouseholdService();

  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late TextEditingController _paymentDateController; // For display
  late TextEditingController _dueDateController; // For display

  String? _selectedHouseholdId;
  String? _selectedPaymentType;
  String? _selectedStatus;
  DateTime? _paymentDate;
  DateTime? _dueDate;

  List<Household> _households = [];
  bool _isLoadingHouseholds = true;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditMode => widget.payment != null;
  final DateFormat _displayDateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _notesController = TextEditingController();
    _paymentDateController = TextEditingController();
    _dueDateController = TextEditingController();

    _fetchHouseholds();

    if (_isEditMode && widget.payment != null) {
      final p = widget.payment!;
      _selectedHouseholdId = p.householdId;
      _selectedPaymentType = p.paymentType;
      _selectedStatus = p.status;
      _amountController.text = p.amount.toStringAsFixed(0);
      _paymentDate = p.paymentDate;
      if (p.paymentDate != null) {
        _paymentDateController.text = _displayDateFormat.format(p.paymentDate!);
      }
      if (p.dueDate != null) {
        _dueDate = p.dueDate;
        _dueDateController.text = _displayDateFormat.format(p.dueDate!);
      }
      _notesController.text = p.notes ?? '';
    } else {
      // Default new payment to today, pending
      _paymentDate = DateTime.now();
      _paymentDateController.text = _displayDateFormat.format(_paymentDate!);
      _selectedStatus = PaymentStatus.pending;
    }
  }

  Future<void> _fetchHouseholds() async {
    setState(() => _isLoadingHouseholds = true);
    try {
      // Assuming householdService.fetchHouseholds() gets a list of all households
      // and each household has an `id` and a displayable name (e.g. `apartmentNumber` or `headResidentName`)
      final households = await _householdService.fetchHouseholds(); 
      setState(() {
        _households = households;
        // If creating new and households list is not empty, select the first one by default or leave null
        // if (_selectedHouseholdId == null && households.isNotEmpty) { 
        //   _selectedHouseholdId = households.first.id;
        // }
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Lỗi tải danh sách hộ: ${e.toString().replaceFirst("Exception: ", "")}";
      });
    }
    setState(() => _isLoadingHouseholds = false);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _paymentDateController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isPaymentDate) async {
    DateTime initial = isPaymentDate ? (_paymentDate ?? DateTime.now()) : (_dueDate ?? _paymentDate ?? DateTime.now());
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isPaymentDate) {
          _paymentDate = picked;
          _paymentDateController.text = _displayDateFormat.format(picked);
        } else {
          _dueDate = picked;
          _dueDateController.text = _displayDateFormat.format(picked);
        }
      });
    }
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _errorMessage = "Vui lòng kiểm tra lại các trường thông tin.");
      return;
    }
    if (_selectedHouseholdId == null) {
       setState(() => _errorMessage = "Vui lòng chọn một hộ gia đình.");
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final paymentData = {
      'household_id': _selectedHouseholdId!,
      'payment_type': _selectedPaymentType!,
      'amount': double.tryParse(_amountController.text) ?? 0.0,
      'payment_date': _apiDateFormat.format(_paymentDate ?? DateTime.now()),
      'status': _selectedStatus!,
      'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
      'due_date': _dueDate != null ? _apiDateFormat.format(_dueDate!) : null,
    };

    try {
      if (_isEditMode) {
        await _paymentService.updatePayment(widget.payment!.id, paymentData);
      } else {
        await _paymentService.createPayment(paymentData);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Khoản thanh toán đã được ${_isEditMode ? "cập nhật" : "tạo mới"} thành công!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true); // Pop with true to indicate success and trigger refresh
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst("Exception: ", "");
        });
      }
    }
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Chỉnh sửa Khoản Thanh toán' : 'Tạo Khoản Thanh toán Mới'),
      ),
      body: _isLoadingHouseholds
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildHouseholdDropdown(),
                        const SizedBox(height: 16),
                        _buildPaymentTypeDropdown(),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _amountController,
                          decoration: const InputDecoration(labelText: 'Số tiền', prefixIcon: Icon(Icons.attach_money), border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Vui lòng nhập số tiền.';
                            if (double.tryParse(value) == null) return 'Số tiền không hợp lệ.';
                            if (double.parse(value) <= 0) return 'Số tiền phải lớn hơn 0.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _paymentDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Ngày thanh toán',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(icon: const Icon(Icons.calendar_month), onPressed: () => _selectDate(context, true)),
                          ),
                          validator: (value) => (_paymentDate == null) ? 'Vui lòng chọn ngày thanh toán.' : null,
                        ),
                        const SizedBox(height: 16),
                         TextFormField(
                          controller: _dueDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Ngày đến hạn (tùy chọn)',
                            prefixIcon: const Icon(Icons.event_busy),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(icon: const Icon(Icons.calendar_month), onPressed: () => _selectDate(context, false)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStatusDropdown(),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(labelText: 'Ghi chú (tùy chọn)', prefixIcon: Icon(Icons.notes), border: OutlineInputBorder()),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 16)),
                          ),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _savePayment,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: _isSaving ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : Text(_isEditMode ? 'Lưu Thay đổi' : 'Tạo Phiếu thu'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHouseholdDropdown() {
    if (_isLoadingHouseholds && _households.isEmpty) {
      return const Center(child: Text("Đang tải danh sách hộ..."));
    }
    if (_households.isEmpty) {
      return const Center(child: Text("Không tìm thấy hộ nào. Vui lòng tạo hộ trước."));
    }
    return DropdownButtonFormField<String>(
      value: _selectedHouseholdId,
      decoration: const InputDecoration(labelText: 'Hộ gia đình', border: OutlineInputBorder(), prefixIcon: Icon(Icons.home_work)),
      isExpanded: true,
      hint: const Text('Chọn hộ gia đình'),
      items: _households.map((Household household) {
        return DropdownMenuItem<String>(
          value: household.id,
          // Display apartment number and head resident name if available
          child: Text('Căn hộ ${household.apartmentNumber ?? "[N/A]"} - ${household.headResidentName ?? "[Chưa có chủ hộ]"}'),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedHouseholdId = newValue;
        });
      },
      validator: (value) => value == null ? 'Vui lòng chọn hộ gia đình.' : null,
    );
  }

  Widget _buildPaymentTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedPaymentType,
      decoration: const InputDecoration(labelText: 'Loại thanh toán', border: OutlineInputBorder(), prefixIcon: Icon(Icons.receipt_long)),
      isExpanded: true,
      hint: const Text('Chọn loại thanh toán'),
      items: PaymentType.all.map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedPaymentType = newValue;
        });
      },
      validator: (value) => value == null ? 'Vui lòng chọn loại thanh toán.' : null,
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: const InputDecoration(labelText: 'Trạng thái thanh toán', border: OutlineInputBorder(), prefixIcon: Icon(Icons.check_circle_outline)),
      isExpanded: true,
      hint: const Text('Chọn trạng thái'),
      items: PaymentStatus.all.map((String status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(status),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedStatus = newValue;
        });
      },
      validator: (value) => value == null ? 'Vui lòng chọn trạng thái.' : null,
    );
  }
} 