import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/staff_model.dart';
import '../screens/staff_form_view.dart';
import '../screens/main_layout.dart';
import '../services/staff_service.dart';

class StaffListView extends StatefulWidget {
  static const String routeName = '/staff';
  const StaffListView({super.key});

  @override
  State<StaffListView> createState() => _StaffListViewState();
}

class _StaffListViewState extends State<StaffListView>
    with TickerProviderStateMixin {
  List<Staff> _staff = [];
  List<Staff> _filteredStaff = [];
  bool _isLoading = true;
  String? _errorMessage;
  final StaffService _staffService = StaffService();

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
    _fetchStaff();
    _searchController.addListener(_filterStaff);
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

  Future<void> _fetchStaff() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      _staff = await _staffService.fetchStaff(
        status: _selectedStatus,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
      );
      _filteredStaff = List.from(_staff);
      _filterStaff();
      
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
          _errorMessage = e.toString().replaceFirst("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  void _filterStaff() {
    List<Staff> filtered = List.from(_staff);
    
    // Filter by search text
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((staff) {
        return staff.fullName.toLowerCase().contains(searchTerm) ||
               staff.email.toLowerCase().contains(searchTerm) ||
               (staff.phoneNumber?.toLowerCase().contains(searchTerm) ?? false);
      }).toList();
    }
    
    // Filter by status
    if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
      filtered = filtered.where((staff) => staff.status == _selectedStatus).toList();
    }
    
    setState(() {
      _filteredStaff = filtered;
    });
  }

  void _sortStaff(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      
      _filteredStaff.sort((a, b) {
        dynamic aValue, bValue;
        
        switch (columnIndex) {
          case 0: // ID
            aValue = a.id;
            bValue = b.id;
            break;
          case 1: // Full Name
            aValue = a.fullName;
            bValue = b.fullName;
            break;
          case 2: // Email
            aValue = a.email;
            bValue = b.email;
            break;
          case 3: // Phone
            aValue = a.phoneNumber ?? '';
            bValue = b.phoneNumber ?? '';
            break;
          case 4: // Status
            aValue = a.status;
            bValue = b.status;
            break;
          case 5: // Created At
            aValue = a.createdAt ?? DateTime(1970);
            bValue = b.createdAt ?? DateTime(1970);
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

  Future<void> _toggleStaffStatus(Staff staff) async {
    final newStatus = staff.status == StaffStatus.active 
        ? StaffStatus.inactive 
        : StaffStatus.active;
    
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                newStatus == StaffStatus.active ? Icons.check_circle : Icons.block,
                color: newStatus == StaffStatus.active ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(newStatus == StaffStatus.active ? 'Kích hoạt nhân viên' : 'Vô hiệu hóa nhân viên'),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn ${newStatus == StaffStatus.active ? 'kích hoạt' : 'vô hiệu hóa'} nhân viên ${staff.fullName}?'
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: newStatus == StaffStatus.active ? Colors.green : Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text(newStatus == StaffStatus.active ? 'Kích hoạt' : 'Vô hiệu hóa'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() { _isLoading = true; });
      try {
        await _staffService.updateStaffStatus(staff.id, newStatus);
        await _fetchStaff();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Trạng thái nhân viên đã được cập nhật'),
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
                  Expanded(child: Text('Lỗi khi cập nhật: ${e.toString().replaceFirst("Exception: ", "")}')),
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

  Future<void> _resetPassword(Staff staff) async {
    final TextEditingController passwordController = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.lock_reset, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text('Đặt lại mật khẩu'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Đặt lại mật khẩu cho nhân viên: ${staff.fullName}'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu mới',
                  border: OutlineInputBorder(),
                  helperText: 'Tối thiểu 8 ký tự',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('Đặt lại'),
              onPressed: () {
                if (passwordController.text.length >= 8) {
                  Navigator.of(context).pop(true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mật khẩu phải có ít nhất 8 ký tự')),
                  );
                }
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true && passwordController.text.isNotEmpty) {
      setState(() { _isLoading = true; });
      try {
        await _staffService.resetStaffPassword(staff.id, passwordController.text);
        await _fetchStaff();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Mật khẩu đã được đặt lại thành công'),
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
                  Expanded(child: Text('Lỗi khi đặt lại mật khẩu: ${e.toString().replaceFirst("Exception: ", "")}')),
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

  void _navigateToAddStaff() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MainLayout(
          currentRoute: '/staff/new',
          child: StaffFormView(),
        ),
      ),
    ).then((result) {
      if (result == true) _fetchStaff();
    });
  }

  void _navigateToEditStaff(Staff staff) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainLayout(
          currentRoute: '/staff/edit/${staff.id}',
          child: StaffFormView(staff: staff),
        ),
      ),
    ).then((result) {
      if (result == true) _fetchStaff();
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
                      labelText: 'Tìm kiếm nhân viên...',
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
                      ...StaffStatus.all.map(
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
                      _fetchStaff();
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
                    _fetchStaff();
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
      case StaffStatus.active:
        return 'Hoạt động';
      case StaffStatus.inactive:
        return 'Không hoạt động';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case StaffStatus.active:
        return Colors.green;
      case StaffStatus.inactive:
        return Colors.red;
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
            if (constraints.maxWidth < 900) {
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
                'ID',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) => _sortStaff(columnIndex, ascending),
            ),
            DataColumn(
              label: const Text(
                'Họ và tên',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) => _sortStaff(columnIndex, ascending),
            ),
            DataColumn(
              label: const Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) => _sortStaff(columnIndex, ascending),
            ),
            DataColumn(
              label: const Text(
                'Số điện thoại',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) => _sortStaff(columnIndex, ascending),
            ),
            DataColumn(
              label: const Text(
                'Trạng thái',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) => _sortStaff(columnIndex, ascending),
            ),
            DataColumn(
              label: const Text(
                'Ngày tạo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: (columnIndex, ascending) => _sortStaff(columnIndex, ascending),
            ),
            const DataColumn(
              label: Text(
                'Thao tác',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: _filteredStaff.asMap().entries.map((entry) {
            final index = entry.key;
            final staff = entry.value;
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
                        staff.id.length > 6 ? staff.id.substring(0, 6) + '...' : staff.id,
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
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            staff.fullName.isNotEmpty ? staff.fullName[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            staff.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
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
                      staff.email,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      staff.phoneNumber ?? 'N/A',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
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
                        color: _getStatusColor(staff.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getStatusColor(staff.status).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        staff.statusDisplayName,
                        style: TextStyle(
                          color: _getStatusColor(staff.status),
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
                    child: Text(
                      staff.formattedCreatedDate,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
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
                          onPressed: () => _navigateToEditStaff(staff),
                        ),
                        const SizedBox(width: 4),
                        IconButton.filledTonal(
                          icon: Icon(
                            staff.status == StaffStatus.active ? Icons.block : Icons.check_circle,
                            size: 18,
                          ),
                          tooltip: staff.status == StaffStatus.active ? 'Vô hiệu hóa' : 'Kích hoạt',
                          style: IconButton.styleFrom(
                            backgroundColor: staff.status == StaffStatus.active 
                                ? Theme.of(context).colorScheme.errorContainer
                                : Theme.of(context).colorScheme.primaryContainer,
                            foregroundColor: staff.status == StaffStatus.active 
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () => _toggleStaffStatus(staff),
                        ),
                        const SizedBox(width: 4),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.lock_reset, size: 18),
                          tooltip: 'Đặt lại mật khẩu',
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                          onPressed: () => _resetPassword(staff),
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
      itemCount: _filteredStaff.length,
      itemBuilder: (context, index) {
        final staff = _filteredStaff[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(staff.status).withValues(alpha: 0.2),
              child: Text(
                staff.fullName.isNotEmpty ? staff.fullName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: _getStatusColor(staff.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              staff.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(staff.email),
                Text(
                  staff.statusDisplayName,
                  style: TextStyle(
                    color: _getStatusColor(staff.status),
                    fontWeight: FontWeight.w500,
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
                    _buildStaffInfoRow(Icons.phone, 'Số điện thoại', staff.phoneNumber ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildStaffInfoRow(Icons.calendar_today, 'Ngày tạo', staff.formattedCreatedDate),
                    const SizedBox(height: 8),
                    _buildStaffInfoRow(Icons.info_outline, 'ID', staff.id),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Sửa'),
                          onPressed: () => _navigateToEditStaff(staff),
                        ),
                        ElevatedButton.icon(
                          icon: Icon(
                            staff.status == StaffStatus.active ? Icons.block : Icons.check_circle,
                            size: 16,
                          ),
                          label: Text(staff.status == StaffStatus.active ? 'Vô hiệu' : 'Kích hoạt'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: staff.status == StaffStatus.active 
                                ? Theme.of(context).colorScheme.error
                                : Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _toggleStaffStatus(staff),
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

  Widget _buildStaffInfoRow(IconData icon, String label, String value) {
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
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
                    'Quản lý Nhân viên',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    '${_filteredStaff.length} nhân viên',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                onPressed: _navigateToAddStaff,
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
                              onPressed: _fetchStaff,
                            ),
                          ],
                        ),
                      )
                    : _filteredStaff.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _staff.isEmpty 
                                      ? 'Chưa có nhân viên nào'
                                      : 'Không tìm thấy nhân viên phù hợp',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _staff.isEmpty
                                      ? 'Hãy thêm nhân viên đầu tiên!'
                                      : 'Thử thay đổi bộ lọc tìm kiếm',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                                if (_staff.isEmpty) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.add),
                                    label: const Text('Thêm nhân viên'),
                                    onPressed: _navigateToAddStaff,
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
                                onRefresh: _fetchStaff,
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