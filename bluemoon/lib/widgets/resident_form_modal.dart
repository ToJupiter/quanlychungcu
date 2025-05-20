import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/resident_model.dart';
import '../services/household_service.dart'; // For add/update resident

class ResidentFormModal extends StatefulWidget {
  final String? residentId; // Nullable for create mode
  final String householdId; 
  final Resident? initialResident; // For pre-filling form in edit mode

  const ResidentFormModal({
    super.key,
    required this.householdId,
    this.residentId,
    this.initialResident,
  });

  @override
  State<ResidentFormModal> createState() => _ResidentFormModalState();
}

class _ResidentFormModalState extends State<ResidentFormModal> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  final HouseholdService _householdService = HouseholdService();

  late TextEditingController _fullNameController;
  DateTime? _dobDate;
  late TextEditingController _dobDisplayController; // To show formatted date
  late TextEditingController _cccdController;
  late TextEditingController _roleController;

  bool _isLoading = false;
  String _errorMessage = '';
  bool get _isEditMode => widget.residentId != null && widget.initialResident != null;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.initialResident?.fullName);
    _dobDate = widget.initialResident?.dateOfBirth;
    _dobDisplayController = TextEditingController(text: _dobDate != null ? _dateFormatter.format(_dobDate!) : '');
    _cccdController = TextEditingController(text: widget.initialResident?.cccdNumber);
    _roleController = TextEditingController(text: widget.initialResident?.roleInHousehold);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobDisplayController.dispose();
    _cccdController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _selectDob(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dobDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dobDate) {
      setState(() {
        _dobDate = picked;
        _dobDisplayController.text = _dateFormatter.format(picked);
      });
    }
  }

  Future<void> _saveResident() async {
    if (!_formKey.currentState!.validate()) {
      setState(() { _errorMessage = 'Please correct the errors in the form.';});
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    Map<String, dynamic> residentData = {
      'full_name': _fullNameController.text,
      'date_of_birth': _dobDate != null ? DateFormat('yyyy-MM-dd').format(_dobDate!) : null,
      'cccd_number': _cccdController.text.isNotEmpty ? _cccdController.text : null,
      'role_in_household': _roleController.text.isNotEmpty ? _roleController.text : null,
      // household_id is part of the URL for add, not needed in body here
      // For update, residentId is part of URL.
    };
    if (!_isEditMode) {
      residentData['household_id'] = widget.householdId; // Backend might need this for creation if not in URL
    }

    try {
      if (_isEditMode) {
        await _householdService.updateResident(widget.residentId!, residentData);
      } else {
        await _householdService.addResident(widget.householdId, residentData);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resident ${_isEditMode ? 'updated' : 'added'} successfully!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true); // Pop with true to indicate success
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
    return AlertDialog(
      title: Text(_isEditMode ? 'Chỉnh sửa Thành viên' : 'Thêm Thành viên'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: ListBody(
            children: <Widget>[
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Họ tên', prefixIcon: Icon(Icons.person)),
                validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập họ tên' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dobDisplayController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Ngày sinh',
                  prefixIcon: const Icon(Icons.cake),
                  suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _selectDob(context)),
                ),
                // validator: (value) => _dobDate == null ? 'Vui lòng chọn ngày sinh' : null, // Optional
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cccdController,
                decoration: const InputDecoration(labelText: 'Số CCCD', prefixIcon: Icon(Icons.badge)),
                keyboardType: TextInputType.number,
                validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length != 9 && value.length != 12) {
                        return 'Số CCCD phải có 9 hoặc 12 chữ số';
                      }
                      if (RegExp(r'[^0-9]').hasMatch(value)) {
                        return 'Số CCCD chỉ được chứa chữ số';
                      }
                    }
                    return null;
                  },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: 'Vai trò trong hộ', hintText: 'VD: Con, Vợ, Chồng, Thuê phòng...', prefixIcon: Icon(Icons.people_alt_outlined)),
                // validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập vai trò' : null, // Optional
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
          child: const Text('Cancel'),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveResident,
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save'),
        ),
      ],
    );
  }
}

Future<bool?> showResidentFormModal(BuildContext context, String householdId, {String? residentId, Resident? initialResident}) {
  return showDialog<bool?>(
    context: context,
    barrierDismissible: false, // User must tap button!
    builder: (BuildContext context) {
      return ResidentFormModal(householdId: householdId, residentId: residentId, initialResident: initialResident);
    },
  );
}
