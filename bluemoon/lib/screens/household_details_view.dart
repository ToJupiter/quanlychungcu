import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/household_model.dart';
import '../models/resident_model.dart';
import '../models/vehicle_model.dart';
import '../services/household_service.dart';
import '../widgets/resident_form_modal.dart';
import '../widgets/vehicle_form_modal.dart';

class HouseholdDetailsView extends StatefulWidget {
  final String householdId;
  const HouseholdDetailsView({super.key, required this.householdId});

  @override
  State<HouseholdDetailsView> createState() => _HouseholdDetailsViewState();
}

class _HouseholdDetailsViewState extends State<HouseholdDetailsView> {
  final HouseholdService _householdService = HouseholdService();
  late Future<HouseholdDetailsData> _detailsFuture;
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  // These will be updated by the FutureBuilder
  // Household? _householdInfo;
  // List<Resident> _residents = [];
  // List<Vehicle> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() {
    setState(() {
      _detailsFuture = _householdService.fetchHouseholdDetails(widget.householdId);
    });
  }

  Future<void> _showAddResidentForm() async {
    final bool? success = await showResidentFormModal(context, widget.householdId);
    if (success == true && mounted) {
      _loadDetails(); // Refresh data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thành viên đã được thêm.'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _showEditResidentForm(Resident resident) async {
    final bool? success = await showResidentFormModal(
      context,
      widget.householdId, // householdId is still needed for context, even if resident has it
      residentId: resident.id,
      initialResident: resident,
    );
    if (success == true && mounted) {
      _loadDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thông tin thành viên đã được cập nhật.'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _deleteResident(String residentId) async {
    final bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Xác nhận Xóa'),
              content: const Text('Bạn có chắc chắn muốn xóa thành viên này không?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Hủy'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ?? false; // Ensure it defaults to false if dialog is dismissed

    if (confirmDelete && mounted) {
      try {
        await _householdService.deleteResident(residentId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thành viên đã được xóa.'), backgroundColor: Colors.green),
        );
        _loadDetails(); // Refresh
      } catch (e) {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi xóa thành viên: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Theme.of(context).colorScheme.error),
            );
        }
      }
    }
  }

  Future<void> _showAddVehicleForm() async {
    final bool? success = await showVehicleFormModal(context, widget.householdId);
    if (success == true && mounted) {
      _loadDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phương tiện đã được thêm.'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _showEditVehicleForm(Vehicle vehicle) async {
    final bool? success = await showVehicleFormModal(
      context,
      widget.householdId, // householdId for context
      vehicleId: vehicle.id,
      initialVehicle: vehicle,
    );
    if (success == true && mounted) {
      _loadDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thông tin phương tiện đã được cập nhật.'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _deleteVehicle(String vehicleId) async {
    final bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Xác nhận Xóa'),
              content: const Text('Bạn có chắc chắn muốn xóa phương tiện này không?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Hủy'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ?? false;

    if (confirmDelete && mounted) {
      try {
        await _householdService.deleteVehicle(vehicleId);
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phương tiện đã được xóa.'), backgroundColor: Colors.green),
        );
        _loadDetails(); // Refresh
      } catch (e) {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi xóa phương tiện: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Theme.of(context).colorScheme.error),
            );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Hộ gia đình'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại dữ liệu',
            onPressed: _loadDetails,
          )
        ],
      ),
      body: FutureBuilder<HouseholdDetailsData>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Lỗi tải dữ liệu: ${snapshot.error?.toString().replaceFirst("Exception: ", "")}', textAlign: TextAlign.center),
            ));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Không tìm thấy dữ liệu chi tiết cho hộ này.'));
          }

          final householdInfo = snapshot.data!.householdInfo;
          final residents = snapshot.data!.residents;
          final vehicles = snapshot.data!.vehicles;

          return RefreshIndicator(
            onRefresh: () async => _loadDetails(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(), // Ensure scroll even when content is small for RefreshIndicator
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHouseholdInfoCard(householdInfo),
                  const SizedBox(height: 24),
                  _buildResidentsSection(context, residents),
                  const SizedBox(height: 24),
                  _buildVehiclesSection(context, vehicles),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHouseholdInfoCard(Household household) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thông tin Chung', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 20, thickness: 1),
            _infoRow('Mã căn hộ:', household.apartmentId), 
            _infoRow('Số căn hộ:', household.apartmentNumber ?? 'N/A'),
            _infoRow('Chủ hộ:', household.headResidentName ?? 'N/A'),
            _infoRow('Ngày chuyển vào:', household.moveInDate != null ? _dateFormatter.format(household.moveInDate!) : 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 3, child: Text(value, textAlign: TextAlign.right, softWrap: true)),
        ],
      ),
    );
  }

  Widget _buildResidentsSection(BuildContext context, List<Resident> residents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Thành viên (${residents.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm'),
              onPressed: _showAddResidentForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        residents.isEmpty
            ? Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  child: const Center(child: Text('Chưa có thành viên nào.', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)))
                )
              )
            : Card(
                child: SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    columnSpacing: 10,
                    horizontalMargin: 10,
                    headingRowHeight: 40,
                    dataRowMinHeight: 48,
                    dataRowMaxHeight: 56,
                    columns: const [
                      DataColumn(label: Text('Họ tên', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Ngày sinh', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('CCCD', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Vai trò', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('H.Động', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                    ],
                    rows: residents.map((resident) {
                      return DataRow(
                        cells: [
                          DataCell(Text(resident.fullName, overflow: TextOverflow.ellipsis)),
                          DataCell(Text(resident.dateOfBirth != null ? _dateFormatter.format(resident.dateOfBirth!) : 'N/A')),
                          DataCell(Text(resident.cccdNumber ?? 'N/A')),
                          DataCell(Text(resident.roleInHousehold ?? 'N/A')),
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showEditResidentForm(resident), tooltip: 'Sửa', visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                              IconButton(icon: Icon(Icons.delete, size: 20, color: Theme.of(context).colorScheme.error), onPressed: () => _deleteResident(resident.id), tooltip: 'Xóa', visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                            ],
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildVehiclesSection(BuildContext context, List<Vehicle> vehicles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Phương tiện (${vehicles.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm'),
              onPressed: _showAddVehicleForm,
               style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        vehicles.isEmpty
            ? Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  child: const Center(child: Text('Chưa có phương tiện nào.', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)))
                )
              )
            : Card(
                child: SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    columnSpacing: 10,
                    horizontalMargin: 10,
                    headingRowHeight: 40,
                    dataRowMinHeight: 48,
                    dataRowMaxHeight: 56,
                    columns: const [
                      DataColumn(label: Text('Biển số', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Loại xe', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Ngày ĐK', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('H.Động', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                    ],
                    rows: vehicles.map((vehicle) {
                      return DataRow(
                        cells: [
                          DataCell(Text(vehicle.plateNumber, overflow: TextOverflow.ellipsis)),
                          DataCell(Text(vehicle.vehicleType ?? 'N/A')),
                          DataCell(Text(vehicle.registrationDate != null ? _dateFormatter.format(vehicle.registrationDate!) : 'N/A')),
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showEditVehicleForm(vehicle), tooltip: 'Sửa', visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                              IconButton(icon: Icon(Icons.delete, size: 20, color: Theme.of(context).colorScheme.error), onPressed: () => _deleteVehicle(vehicle.id), tooltip: 'Xóa', visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                            ],
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
      ],
    );
  }
} 