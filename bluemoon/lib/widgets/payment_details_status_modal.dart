import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentDetailsStatusModal extends StatefulWidget {
  final Payment payment; // The payment to display and potentially update

  const PaymentDetailsStatusModal({super.key, required this.payment});

  @override
  State<PaymentDetailsStatusModal> createState() => _PaymentDetailsStatusModalState();
}

class _PaymentDetailsStatusModalState extends State<PaymentDetailsStatusModal> {
  final PaymentService _paymentService = PaymentService();
  late String _selectedStatus;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.payment.status;
  }

  Future<void> _updateStatus() async {
    if (_selectedStatus == widget.payment.status) {
      // No change, just pop
      Navigator.of(context).pop(false); // pop false if no change made
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _paymentService.updatePaymentStatus(widget.payment.id, _selectedStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trạng thái thanh toán đã được cập nhật.'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true); // Pop with true to indicate success
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
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Chi tiết và Cập nhật Thanh toán'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            _buildDetailRow('ID Thanh toán:', widget.payment.id, context),
            _buildDetailRow('Số căn hộ:', widget.payment.apartmentNumber ?? 'N/A', context),
            _buildDetailRow('Loại thanh toán:', widget.payment.paymentType, context),
            _buildDetailRow('Số tiền:', widget.payment.formattedAmount, context),
            _buildDetailRow('Ngày thanh toán:', widget.payment.formattedPaymentDate, context),
            _buildDetailRow('Hạn thanh toán:', widget.payment.formattedDueDate, context),
            if (widget.payment.notes != null && widget.payment.notes!.isNotEmpty)
              _buildDetailRow('Ghi chú:', widget.payment.notes!, context),
            const Divider(height: 20, thickness: 1),
            Text('Cập nhật trạng thái:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              items: PaymentStatus.all.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                }
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error)),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Đóng'),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
        ),
        ElevatedButton(
          onPressed: _isLoading || _selectedStatus == widget.payment.status ? null : _updateStatus,
          style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primaryContainer),
          child: _isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
              : Text('Cập nhật TT', style: TextStyle(color: theme.colorScheme.onPrimaryContainer)),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(value, textAlign: TextAlign.right, softWrap: true)),
        ],
      ),
    );
  }
}

// Helper function to show the modal
Future<bool?> showPaymentDetailsStatusModal(BuildContext context, Payment payment) {
  return showDialog<bool?>(
    context: context,
    barrierDismissible: true, // Allow dismissing by tapping outside
    builder: (BuildContext context) {
      return PaymentDetailsStatusModal(payment: payment);
    },
  );
} 