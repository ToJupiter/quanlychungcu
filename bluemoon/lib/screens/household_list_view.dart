import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../models/household_model.dart';
import '../screens/household_creation_form_view.dart';
import '../screens/household_details_view.dart';
import '../screens/main_layout.dart';
import '../services/household_service.dart'; // Import HouseholdService

class HouseholdListView extends StatefulWidget {
  static const String routeName = '/households'; // Added routeName
  const HouseholdListView({super.key});

  @override
  State<HouseholdListView> createState() => _HouseholdListViewState();
}

class _HouseholdListViewState extends State<HouseholdListView> {
  List<Household> _households = [];
  bool _isLoading = true;
  String? _errorMessage;
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  final HouseholdService _householdService = HouseholdService(); // Instantiate service

  // For client-side filtering (optional as per spec)
  List<Household> _filteredHouseholds = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHouseholds();
    _searchController.addListener(_filterHouseholds);
  }

  @override
  void dispose(){
    _searchController.removeListener(_filterHouseholds);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchHouseholds() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _households = await _householdService.fetchHouseholds();
      if (mounted) {
        setState(() {
          _filteredHouseholds = List.from(_households);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _filterHouseholds() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredHouseholds = _households.where((household) {
        final apartmentNumberMatch = household.apartmentNumber.toLowerCase().contains(query);
        final headResidentNameMatch = household.headResidentName.toLowerCase().contains(query);
        return apartmentNumberMatch || headResidentNameMatch;
      }).toList();
    });
  }

  void _navigateToAddHousehold() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MainLayout(
          currentRoute: '/households/new',
          child: HouseholdCreationFormView(),
        ),
      ),
    ).then((success) {
      if (success == true) _fetchHouseholds();
    });
  }

  void _navigateToHouseholdDetails(String householdId) {
     Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainLayout(
          currentRoute: '/households/details/$householdId',
          child: HouseholdDetailsView(householdId: householdId),
        ),
      ),
    ).then((_) => _fetchHouseholds());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quản lý Hộ gia đình',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add New'),
                onPressed: _navigateToAddHousehold,
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          // Optional Search Bar (client-side filtering)
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by Apartment No. or Head Resident...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            ),
          ),
          const SizedBox(height: 20.0),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage != null)
            Expanded(child: Center(child: Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error))))
          else if (_filteredHouseholds.isEmpty)
            Expanded(child: Center(child: Text(_searchController.text.isNotEmpty ? 'No households match your search.' : 'No households found. Add a new one!')))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchHouseholds,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(label: Text('ID Hộ')),
                      DataColumn(label: Text('Số Căn hộ')),
                      DataColumn(label: Text('Chủ hộ')),
                      DataColumn(label: Text('Ngày chuyển đến')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: _filteredHouseholds.map((Household household) {
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(household.id)),
                          DataCell(Text(household.apartmentNumber)),
                          DataCell(Text(household.headResidentName)),
                          DataCell(Text(_dateFormatter.format(household.moveInDate))),
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility, size: 20),
                                color: Theme.of(context).colorScheme.secondary,
                                tooltip: 'View Details',
                                onPressed: () => _navigateToHouseholdDetails(household.id),
                              ),
                            ],
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 