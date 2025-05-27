import 'package:flutter/material.dart';
import '../models/apartment_model.dart';
import '../screens/apartment_form_view.dart';
import '../screens/main_layout.dart'; // For consistent navigation context
import '../services/apartment_service.dart'; // Import ApartmentService

class ApartmentListView extends StatefulWidget {
  static const String routeName = '/apartments'; // Added routeName
  const ApartmentListView({super.key});

  @override
  State<ApartmentListView> createState() => _ApartmentListViewState();
}

class _ApartmentListViewState extends State<ApartmentListView>
    with TickerProviderStateMixin {
  List<Apartment> _apartments = [];
  List<Apartment> _filteredApartments = [];
  bool _isLoading = true;
  String? _errorMessage;
  final ApartmentService _apartmentService = ApartmentService(); // Instantiate service
  
  // Search and filter controllers
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  
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
    _fetchApartments();
    _searchController.addListener(_filterApartments);
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
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _fetchApartments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      _apartments = await _apartmentService.fetchApartments();
      _filteredApartments = List.from(_apartments);
      _filterApartments();
      
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

  void _filterApartments() {
    List<Apartment> filtered = List.from(_apartments);
    
    // Filter by search text
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((apartment) {
        return apartment.apartmentNumber.toLowerCase().contains(searchTerm) ||
               apartment.status.toLowerCase().contains(searchTerm);
      }).toList();
    }
    
    // Filter by status
    if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
      filtered = filtered.where((apartment) => apartment.status == _selectedStatus).toList();
    }
    
    setState(() {
      _filteredApartments = filtered;
    });
  }

  void _sortApartments(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      
      _filteredApartments.sort((a, b) {
        dynamic aValue, bValue;
        
        switch (columnIndex) {
          case 0: // Apartment Number
            aValue = a.apartmentNumber;
            bValue = b.apartmentNumber;
            break;
          case 1: // Area
            aValue = a.area;
            bValue = b.area;
            break;
          case 2: // Status
            aValue = a.status;
            bValue = b.status;
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

  Future<void> _deleteApartment(String apartmentId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
              const SizedBox(width: 8),
              const Text('Xác nhận xóa'),
            ],
          ),
          content: const Text('Bạn có chắc chắn muốn xóa căn hộ này không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xóa'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() { _isLoading = true; });
      try {
        await _apartmentService.deleteApartment(apartmentId);
        await _fetchApartments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Căn hộ đã được xóa thành công'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Lỗi khi xóa: ${e.toString()}')),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
          setState(() { _isLoading = false; });
        }
      }
    }
  }

  void _navigateToAddApartment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainLayout(
          currentRoute: '/apartments/new',
          child: const ApartmentFormView(),
        ),
      ),
    ).then((result) {
      if (result == true) _fetchApartments();
    });
  }

  void _navigateToEditApartment(Apartment apartment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainLayout(
          currentRoute: '/apartments/edit/${apartment.id}',
          child: ApartmentFormView(apartmentId: apartment.id, initialApartment: apartment),
        ),
      ),
    ).then((result) {
      if (result == true) _fetchApartments();
    });
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
                      labelText: 'Tìm kiếm căn hộ...',
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
                      labelText: 'Trạng thái',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    value: _selectedStatus,
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
                        _selectedStatus = value;
                      });
                      _filterApartments();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton.filledTonal(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _selectedStatus = null;
                    });
                    _filterApartments();
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
            if (constraints.maxWidth < 600) {
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
        width: MediaQuery.of(context).size.width * 0.9,
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          headingRowColor: WidgetStateProperty.all(
            Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          ),
          headingRowHeight: 56,
          dataRowMaxHeight: 64,
          columnSpacing: 24,
          horizontalMargin: 24,
          columns: [
            DataColumn(
              label: const Text(
                'Số căn hộ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) => _sortApartments(columnIndex, ascending),
            ),
            DataColumn(
              label: const Text(
                'Diện tích (m²)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              numeric: true,
              onSort: (columnIndex, ascending) => _sortApartments(columnIndex, ascending),
            ),
            DataColumn(
              label: const Text(
                'Trạng thái',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) => _sortApartments(columnIndex, ascending),
            ),
            const DataColumn(
              label: Text(
                'Thao tác',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: _filteredApartments.asMap().entries.map((entry) {
            final index = entry.key;
            final apartment = entry.value;
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
                    child: Text(
                      apartment.apartmentNumber,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      apartment.area.toStringAsFixed(1),
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
                        color: _getStatusColor(apartment.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getStatusColor(apartment.status).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _getStatusDisplayName(apartment.status),
                        style: TextStyle(
                          color: _getStatusColor(apartment.status),
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
                          tooltip: 'Chỉnh sửa',
                          onPressed: () => _navigateToEditApartment(apartment),
                        ),
                        const SizedBox(width: 4),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.delete, size: 18),
                          tooltip: 'Xóa',
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.errorContainer,
                            foregroundColor: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _deleteApartment(apartment.id),
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
      itemCount: _filteredApartments.length,
      itemBuilder: (context, index) {
        final apartment = _filteredApartments[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(apartment.status).withOpacity(0.2),
              child: Text(
                apartment.apartmentNumber.substring(0, 1),
                style: TextStyle(
                  color: _getStatusColor(apartment.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              'Căn hộ ${apartment.apartmentNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${apartment.area.toStringAsFixed(1)} m²'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16),
                        const SizedBox(width: 8),
                        Text('Trạng thái: ${_getStatusDisplayName(apartment.status)}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Sửa'),
                          onPressed: () => _navigateToEditApartment(apartment),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Xóa'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _deleteApartment(apartment.id),
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
                    'Quản lý Căn hộ',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    '${_filteredApartments.length} căn hộ',
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
                onPressed: _navigateToAddApartment,
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
                              onPressed: _fetchApartments,
                            ),
                          ],
                        ),
                      )
                    : _filteredApartments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.apartment,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _apartments.isEmpty 
                                      ? 'Chưa có căn hộ nào'
                                      : 'Không tìm thấy căn hộ phù hợp',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _apartments.isEmpty
                                      ? 'Hãy thêm căn hộ đầu tiên!'
                                      : 'Thử thay đổi bộ lọc tìm kiếm',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                if (_apartments.isEmpty) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.add),
                                    label: const Text('Thêm căn hộ'),
                                    onPressed: _navigateToAddApartment,
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
                                onRefresh: _fetchApartments,
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

// Note: For ApartmentFormView to receive initialApartment, its constructor needs to be updated:
// final String? apartmentId;
// final Apartment? initialApartment;
// const ApartmentFormView({super.key, this.apartmentId, this.initialApartment}); 