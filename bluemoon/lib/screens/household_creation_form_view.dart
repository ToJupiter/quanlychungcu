import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/apartment_model.dart'; // For fetching available apartments
import '../services/apartment_service.dart'; // For fetching available apartments
import '../services/household_service.dart'; // For creating household
// import '../models/household_model.dart'; // Not strictly needed for the form itself, but for the data structure sent

class HouseholdCreationFormView extends StatefulWidget {
  const HouseholdCreationFormView({super.key});

  @override
  State<HouseholdCreationFormView> createState() => _HouseholdCreationFormViewState();
}

class _HouseholdCreationFormViewState extends State<HouseholdCreationFormView> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  // Form state variables
  String? _selectedApartmentId;
  DateTime? _moveInDate;
  final _headFullNameController = TextEditingController();
  DateTime? _headDobDate;
  final _headDobController = TextEditingController(); // To display formatted DOB
  final _headCccdController = TextEditingController();

  List<Apartment> _availableApartments = [];
  bool _isFetchingApartments = true;
  bool _isLoading = false;
  String _errorMessage = '';

  final ApartmentService _apartmentService = ApartmentService();
  final HouseholdService _householdService = HouseholdService();

  @override
  void initState() {
    super.initState();
    _fetchAvailableApartments();
  }

  @override
  void dispose() {
    _headFullNameController.dispose();
    _headDobController.dispose();
    _headCccdController.dispose();
    super.dispose();
  }

  Future<void> _fetchAvailableApartments() async {
    setState(() {
      _isFetchingApartments = true;
      _errorMessage = '';
    });
    try {
      // Fetch all apartments and then filter for vacant ones, or adapt if backend provides a direct way
      final allApartments = await _apartmentService.fetchApartments();
      if (mounted) {
        setState(() {
          _availableApartments = allApartments.where((apt) => apt.status == 'vacant').toList();
          // Or, if your backend supports fetching only available apartments:
          // _availableApartments = await _apartmentService.fetchAvailableApartments(); 
          _isFetchingApartments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load available apartments: ${e.toString()}';
          _isFetchingApartments = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime? initialDate, ValueChanged<DateTime> onDateSelected, {TextEditingController? controller}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
      if (controller != null) {
        controller.text = _dateFormatter.format(picked);
      }
    }
  }

  Future<void> _saveHousehold() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = 'Please correct the errors in the form.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final Map<String, dynamic> householdData = {
      'apartment_id': _selectedApartmentId,
      'move_in_date': _moveInDate != null ? DateFormat('yyyy-MM-dd').format(_moveInDate!) : null,
      // Flatten head resident details to match backend controller expectations
      'head_full_name': _headFullNameController.text,
      'head_date_of_birth': _headDobDate != null ? DateFormat('yyyy-MM-dd').format(_headDobDate!) : null,
      'head_cccd_number': _headCccdController.text.isNotEmpty ? _headCccdController.text : null, // Send null if empty, controller might handle optional cccd
    };

    try {
      await _householdService.createHousehold(householdData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Household created successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Pop with success
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
                  'Thêm Hộ gia đình mới',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24.0),
                _isFetchingApartments
                    ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                    : _availableApartments.isEmpty
                      ? Text('No vacant apartments available to create a new household.', style: TextStyle(color: Theme.of(context).colorScheme.error))
                      : DropdownButtonFormField<String>(
                        value: _selectedApartmentId,
                        decoration: const InputDecoration(
                          labelText: 'Căn hộ (Chỉ hiển thị căn hộ trống)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.apartment_rounded),
                        ),
                        hint: const Text('Chọn căn hộ'),
                        items: _availableApartments.map((Apartment apt) {
                          return DropdownMenuItem<String>(
                            value: apt.id,
                            child: Text('${apt.apartmentNumber} (Diện tích: ${apt.area.toStringAsFixed(1)}m²)'),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedApartmentId = newValue;
                          });
                        },
                        validator: (value) => value == null ? 'Vui lòng chọn căn hộ' : null,
                      ),
                const SizedBox(height: 16.0),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Ngày chuyển đến',
                    hintText: 'Chọn ngày',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.date_range_rounded),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context, _moveInDate, (date) => setState(() => _moveInDate = date)),
                    )
                  ),
                  controller: TextEditingController(text: _moveInDate != null ? _dateFormatter.format(_moveInDate!) : ''),
                  validator: (value) => _moveInDate == null ? 'Vui lòng chọn ngày chuyển đến' : null,
                ),
                const SizedBox(height: 24.0),
                const Text(
                  'Thông tin Chủ hộ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Divider(height: 16.0),
                TextFormField(
                  controller: _headFullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Họ tên Chủ hộ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline_rounded)
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập họ tên chủ hộ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _headDobController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Ngày sinh Chủ hộ',
                    hintText: 'Chọn ngày sinh',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.cake_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context, _headDobDate, (date) => setState(() => _headDobDate = date), controller: _headDobController),
                    )
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _headCccdController,
                  decoration: const InputDecoration(
                    labelText: 'Số CCCD Chủ hộ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge_outlined)
                  ),
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
                        label: const Text('Save Household'),
                        onPressed: _saveHousehold,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
                      ),
                const SizedBox(height: 12.0),
                TextButton.icon(
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel'),
                  onPressed: _isLoading ? null : () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 