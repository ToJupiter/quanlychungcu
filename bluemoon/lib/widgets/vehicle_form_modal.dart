import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vehicle_model.dart';
import '../services/household_service.dart'; // For add/update vehicle

class VehicleFormModal extends StatefulWidget {
  final String? vehicleId; // Nullable for create mode
  final String householdId;
  final Vehicle? initialVehicle; // For pre-filling form in edit mode

  const VehicleFormModal({
    super.key,
    required this.householdId,
    this.vehicleId,
    this.initialVehicle,
  });

  @override
  State<VehicleFormModal> createState() => _VehicleFormModalState();
}

class _VehicleFormModalState extends State<VehicleFormModal> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  final HouseholdService _householdService = HouseholdService();

  late TextEditingController _plateNumberController;
  String? _selectedVehicleType;
  DateTime? _registrationDate;
  late TextEditingController _registrationDateDisplayController;

  bool _isLoading = false;
  String _errorMessage = '';
  bool get _isEditMode => widget.vehicleId != null && widget.initialVehicle != null;

  final List<String> _vehicleTypes = ['Xe máy', 'Ô tô']; // Example types

  @override
  void initState() {
    super.initState();
    _plateNumberController = TextEditingController(text: widget.initialVehicle?.plateNumber);
    _selectedVehicleType = widget.initialVehicle?.vehicleType;
    _registrationDate = widget.initialVehicle?.registrationDate;
    _registrationDateDisplayController = TextEditingController(
        text: _registrationDate != null ? _dateFormatter.format(_registrationDate!) : '');
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    _registrationDateDisplayController.dispose();
    super.dispose();
  }

  Future<void> _selectRegistrationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _registrationDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _registrationDate) {
      setState(() {
        _registrationDate = picked;
        _registrationDateDisplayController.text = _dateFormatter.format(picked);
      });
    }
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) {
      setState(() { _errorMessage = 'Vui lòng sửa các lỗi trong form.'; });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    Map<String, dynamic> vehicleData = {
      'plate_number': _plateNumberController.text,
      'vehicle_type': _selectedVehicleType,
      'registration_date': _registrationDate != null ? DateFormat('yyyy-MM-dd').format(_registrationDate!) : null,
      // 'household_id': widget.householdId, // Only include if backend expects it for POST to /vehicles endpoint.
                                          // For PUT /vehicles/:id, it's not needed.
                                          // For POST /households/:householdId/vehicles, it's implied.
    };
    
    // If your backend requires household_id in the body for creating a vehicle associated with a household
    // even when POSTing to /management/households/:householdId/vehicles, uncomment the line below.
    // if (!_isEditMode) {
    //   vehicleData['household_id'] = widget.householdId;
    // }


    try {
      if (_isEditMode) {
        await _householdService.updateVehicle(widget.vehicleId!, vehicleData);
      } else {
        await _householdService.addVehicle(widget.householdId, vehicleData);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Phương tiện đã được ${_isEditMode ? 'cập nhật' : 'thêm'} thành công!'), backgroundColor: Colors.green),
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
    return AlertDialog(
      title: Text(_isEditMode ? 'Chỉnh sửa Phương tiện' : 'Thêm Phương tiện'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: ListBody(
            children: <Widget>[
              TextFormField(
                controller: _plateNumberController,
                decoration: const InputDecoration(labelText: 'Biển số xe', prefixIcon: Icon(Icons.directions_car)),
                validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập biển số xe' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedVehicleType,
                decoration: const InputDecoration(labelText: 'Loại xe', prefixIcon: Icon(Icons.category)),
                items: _vehicleTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedVehicleType = newValue;
                  });
                },
                validator: (value) => value == null || value.isEmpty ? 'Vui lòng chọn loại xe' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _registrationDateDisplayController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Ngày đăng ký',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _selectRegistrationDate(context)),
                ),
                // validator: (value) => _registrationDate == null ? 'Vui lòng chọn ngày đăng ký' : null, // Optional
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(_errorMessage, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Hủy'),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveVehicle,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer, // Use theme color
          ),
          child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
              : Text('Lưu', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
        ),
      ],
    );
  }
}

Future<bool?> showVehicleFormModal(BuildContext context, String householdId, {String? vehicleId, Vehicle? initialVehicle}) {
  return showDialog<bool?>(
    context: context,
    barrierDismissible: false, // User must tap button!
    builder: (BuildContext context) {
      return VehicleFormModal(householdId: householdId, vehicleId: vehicleId, initialVehicle: initialVehicle);
    },
  );
}
