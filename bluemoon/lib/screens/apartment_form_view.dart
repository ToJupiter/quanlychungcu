import 'package:flutter/material.dart';
import '../models/apartment_model.dart';
import '../services/apartment_service.dart';

class ApartmentFormView extends StatefulWidget {
  final String? apartmentId; // Nullable for create mode
  final Apartment? initialApartment; // Pass initial data for editing

  const ApartmentFormView({
    super.key,
    this.apartmentId,
    this.initialApartment,
  });

  @override
  State<ApartmentFormView> createState() => _ApartmentFormViewState();
}

class _ApartmentFormViewState extends State<ApartmentFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _apartmentNumberController;
  late TextEditingController _areaController;
  String? _selectedStatus;
  final List<String> _statusOptions = ['occupied', 'vacant'];

  bool _isLoading = false;
  String _errorMessage = '';
  bool _isEditMode = false;
  final ApartmentService _apartmentService = ApartmentService();

  @override
  void initState() {
    super.initState();
    _apartmentNumberController = TextEditingController();
    _areaController = TextEditingController();

    _isEditMode = widget.apartmentId != null && widget.initialApartment != null;

    if (_isEditMode) {
      _apartmentNumberController.text = widget.initialApartment!.apartmentNumber;
      _areaController.text = widget.initialApartment!.area.toString();
      _selectedStatus = widget.initialApartment!.status;
    } else {
      _selectedStatus = _statusOptions[1]; // Default to 'vacant' for new apartments
    }
  }

  @override
  void dispose() {
    _apartmentNumberController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _saveApartment() async {
    if (!_formKey.currentState!.validate()) {
      setState(() { _errorMessage = 'Please correct the errors in the form.'; });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final Map<String, dynamic> apartmentData = {
      'apartment_number': _apartmentNumberController.text,
      'area': double.tryParse(_areaController.text) ?? 0.0,
      'status': _selectedStatus!,
    };

    try {
      if (_isEditMode) {
        await _apartmentService.updateApartment(widget.apartmentId!, apartmentData);
      } else {
        await _apartmentService.createApartment(apartmentData);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Apartment ${_isEditMode ? 'updated' : 'created'} successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Pop with true to indicate success/refresh
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
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
    // This view is a child of MainLayout, so MainLayout provides the Scaffold and AppBar.
    // We just return the form content.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  _isEditMode ? 'Chỉnh sửa Căn hộ' : 'Thêm Căn hộ mới',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: _apartmentNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Số Căn hộ',
                    hintText: 'VD: A101',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.tag_rounded)
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số căn hộ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _areaController,
                  decoration: const InputDecoration(
                    labelText: 'Diện tích (m²)',
                    hintText: 'VD: 75.5',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.square_foot_rounded)
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'Diện tích không hợp lệ';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Diện tích phải lớn hơn 0';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Trạng thái',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.info_outline_rounded)
                  ),
                  items: _statusOptions.map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status == 'occupied' ? 'Đã có người ở (Occupied)' : 'Còn trống (Vacant)'),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStatus = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Vui lòng chọn trạng thái' : null,
                ),
                const SizedBox(height: 32.0),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Save'),
                        onPressed: _saveApartment,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                      ),
                const SizedBox(height: 12.0),
                TextButton.icon(
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel'),
                  onPressed: _isLoading ? null : () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 