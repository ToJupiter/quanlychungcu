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

class _HouseholdListViewState extends State<HouseholdListView>
    with TickerProviderStateMixin {
  List<Household> _households = [];
  List<Household> _filteredHouseholds = [];
  bool _isLoading = true;
  String? _errorMessage;
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  final HouseholdService _householdService = HouseholdService(); // Instantiate service

  // Search and filter controllers
  final TextEditingController _searchController = TextEditingController();
  String? _selectedApartmentStatus;
  
  // Sorting
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchHouseholds();
    _searchController.addListener(_filterHouseholds);
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterHouseholds);
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _fetchHouseholds() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _households = await _householdService.fetchHouseholds();
      _filteredHouseholds = List.from(_households);
      _filterHouseholds();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _fadeController.forward();
        _slideController.forward();
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
    List<Household> filtered = List.from(_households);
    
    // Filter by search text
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((household) {
        final apartmentNumberMatch = household.apartmentNumber.toLowerCase().contains(query);
        final headResidentNameMatch = household.headResidentName.toLowerCase().contains(query);
        final idMatch = household.id.toLowerCase().contains(query);
        return apartmentNumberMatch || headResidentNameMatch || idMatch;
      }).toList();
    }
    
    // Filter by apartment status
    if (_selectedApartmentStatus != null && _selectedApartmentStatus!.isNotEmpty) {
      filtered = filtered.where((household) => household.apartmentStatus == _selectedApartmentStatus).toList();
    }
    
    setState(() {
      _filteredHouseholds = filtered;
    });
  }

  void _sortHouseholds(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      
      _filteredHouseholds.sort((a, b) {
        dynamic aValue, bValue;
        
        switch (columnIndex) {
          case 0: // ID
            aValue = a.id;
            bValue = b.id;
            break;
          case 1: // Apartment Number
            aValue = a.apartmentNumber;
            bValue = b.apartmentNumber;
            break;
          case 2: // Head Resident Name
            aValue = a.headResidentName;
            bValue = b.headResidentName;
            break;
          case 3: // Move In Date
            aValue = a.moveInDate;
            bValue = b.moveInDate;
            break;
          case 4: // Apartment Area
            aValue = a.apartmentArea;
            bValue = b.apartmentArea;
            break;
          default:
            return 0;
        }
        
        if (ascending) {
          return Comparable.compare(aValue, bValue);
        } else {
          return Comparable.compare(bValue, aValue);
        }
      });
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

  Widget _buildFilterBar() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Tìm kiếm theo ID, căn hộ, chủ hộ...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Trạng thái căn hộ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    value: _selectedApartmentStatus,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Tất cả'),
                      ),
                      ...['occupied', 'vacant', 'maintenance'].map(
                        (status) => DropdownMenuItem<String>(
                          value: status,
                          child: Text(_getStatusDisplayName(status)),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedApartmentStatus = value;
                      });
                      _filterHouseholds();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton.filledTonal(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _selectedApartmentStatus = null;
                    });
                    _filterHouseholds();
                  },
                  icon: const Icon(Icons.clear_all),
                  tooltip: 'Xóa bộ lọc',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'occupied':
        return 'Đã có người ở';
      case 'vacant':
        return 'Trống';
      case 'maintenance':
        return 'Bảo trì';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'occupied':
        return Colors.green;
      case 'vacant':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDataTable() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 800) {
              return _buildMobileView();
            } else {
              return _buildDesktopTable();
            }
          },
        ),
      ),
    );
  }

  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          headingRowColor: WidgetStateProperty.all(
            Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          ),
          headingRowHeight: 56,
          dataRowMaxHeight: 72,
          columnSpacing: 16,
          horizontalMargin: 24,
          columns: [
            DataColumn(
              label: const Text(
                'ID Hộ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) => _sortHouseholds(columnIndex, ascending),
            ),
            DataColumn(
              label: const Text(
                'Số căn hộ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) => _sortHouseholds(columnIndex, ascending),
            ),
            DataColumn(
              label: const Text(
                'Chủ hộ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) => _sortHouseholds(columnIndex, ascending),
            ),
            DataColumn(
              label: const Text(
                'Ngày chuyển đến',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) => _sortHouseholds(columnIndex, ascending),
            ),
            DataColumn(
              label: const Text(
                'Diện tích (m²)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              numeric: true,
              onSort: (columnIndex, ascending) => _sortHouseholds(columnIndex, ascending),
            ),
            const DataColumn(
              label: Text(
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
          rows: _filteredHouseholds.asMap().entries.map((entry) {
            final index = entry.key;
            final household = entry.value;
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
                        household.id.length > 8 ? household.id.substring(0, 8) + '...' : household.id,
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
                          household.apartmentNumber,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
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
                          household.headResidentName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        if (household.headResidentCccd != null)
                          Text(
                            'CCCD: ${household.headResidentCccd}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                      ],
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
                          _dateFormatter.format(household.moveInDate),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          _getDaysLived(household.moveInDate),
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                      household.apartmentArea.toStringAsFixed(1),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
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
                        color: _getStatusColor(household.apartmentStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getStatusColor(household.apartmentStatus).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _getStatusDisplayName(household.apartmentStatus),
                        style: TextStyle(
                          color: _getStatusColor(household.apartmentStatus),
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
                          icon: const Icon(Icons.visibility, size: 18),
                          tooltip: 'Xem chi tiết',
                          onPressed: () => _navigateToHouseholdDetails(household.id),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.people, size: 18),
                          tooltip: 'Quản lý thành viên',
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                          onPressed: () => _navigateToHouseholdDetails(household.id),
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

  Widget _buildMobileView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredHouseholds.length,
      itemBuilder: (context, index) {
        final household = _filteredHouseholds[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                household.apartmentNumber.substring(0, 1),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              'Căn hộ ${household.apartmentNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chủ hộ: ${household.headResidentName}'),
                Text(
                  'ID: ${household.id.length > 8 ? household.id.substring(0, 8) + '...' : household.id}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                    _buildInfoRow(Icons.calendar_today, 'Ngày chuyển đến', _dateFormatter.format(household.moveInDate)),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.square_foot, 'Diện tích', '${household.apartmentArea.toStringAsFixed(1)} m²'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.info_outline, 'Trạng thái', _getStatusDisplayName(household.apartmentStatus)),
                    if (household.headResidentCccd != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.credit_card, 'CCCD chủ hộ', household.headResidentCccd!),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('Chi tiết'),
                          onPressed: () => _navigateToHouseholdDetails(household.id),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.people, size: 16),
                          label: const Text('Thành viên'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                          onPressed: () => _navigateToHouseholdDetails(household.id),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
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

  String _getDaysLived(DateTime moveInDate) {
    final days = DateTime.now().difference(moveInDate).inDays;
    if (days < 30) {
      return '$days ngày';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return '$months tháng';
    } else {
      final years = (days / 365).floor();
      final remainingMonths = ((days % 365) / 30).floor();
      return '$years năm ${remainingMonths > 0 ? '$remainingMonths tháng' : ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quản lý Hộ gia đình',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    '${_filteredHouseholds.length} hộ gia đình',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm mới'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _navigateToAddHousehold,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Filter bar
          _buildFilterBar(),
          const SizedBox(height: 24),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Đã xảy ra lỗi',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Thử lại'),
                              onPressed: _fetchHouseholds,
                            ),
                          ],
                        ),
                      )
                    : _filteredHouseholds.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.family_restroom,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _households.isEmpty 
                                      ? 'Chưa có hộ gia đình nào'
                                      : 'Không tìm thấy hộ gia đình phù hợp',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _households.isEmpty
                                      ? 'Hãy thêm hộ gia đình đầu tiên!'
                                      : 'Thử thay đổi bộ lọc tìm kiếm',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                if (_households.isEmpty) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.add),
                                    label: const Text('Thêm hộ gia đình'),
                                    onPressed: _navigateToAddHousehold,
                                  ),
                                ],
                              ],
                            ),
                          )
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: RefreshIndicator(
                                onRefresh: _fetchHouseholds,
                                child: SingleChildScrollView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  child: _buildDataTable(),
                                ),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
} 