import 'package:flutter/material.dart';
import '../models/apartment_model.dart';
import '../screens/apartment_form_view.dart';
import '../screens/main_layout.dart'; // For consistent navigation context
import '../services/apartment_service.dart'; // Import ApartmentService
import './main_layout.dart';

class ApartmentListView extends StatefulWidget {
  static const String routeName = '/apartments'; // Added routeName
  const ApartmentListView({super.key});

  @override
  State<ApartmentListView> createState() => _ApartmentListViewState();
}

class _ApartmentListViewState extends State<ApartmentListView> {
  List<Apartment> _apartments = [];
  bool _isLoading = true;
  String? _errorMessage;
  final ApartmentService _apartmentService = ApartmentService(); // Instantiate service

  @override
  void initState() {
    super.initState();
    _fetchApartments();
  }

  Future<void> _fetchApartments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _apartments = await _apartmentService.fetchApartments();
      if (mounted) {
        setState(() {
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

  Future<void> _deleteApartment(String apartmentId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this apartment?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() { _isLoading = true; }); // Indicate loading during delete
      try {
        await _apartmentService.deleteApartment(apartmentId);
        // Refresh list after successful deletion
        await _fetchApartments(); 
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Apartment deleted successfully'), backgroundColor: Colors.green),
            );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete apartment: ${e.toString()}'), backgroundColor: Theme.of(context).colorScheme.error),
          );
           setState(() { _isLoading = false; }); // Stop loading on error
        }
      }
      // No need to manually set _isLoading to false if _fetchApartments is called and handles it.
    }
  }

  void _navigateToAddApartment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainLayout(
          currentRoute: '/apartments/new', 
          child: ApartmentFormView(),
        ),
      ),
    ).then((result) {
      // If the form was successfully submitted, ApartmentFormView pops with true
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
                'Quản lý Căn hộ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add New'),
                onPressed: _navigateToAddApartment,
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage != null)
            Expanded(child: Center(child: Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 16))))
          else if (_apartments.isEmpty)
            const Expanded(child: Center(child: Text('No apartments found. Add a new one!', style: TextStyle(fontSize: 16))))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchApartments, // Allow pull-to-refresh
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(), // Ensure scrollability for RefreshIndicator
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Số Căn hộ')),
                      DataColumn(label: Text('Diện tích (m²)')),
                      DataColumn(label: Text('Trạng thái')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: _apartments.map((Apartment apartment) {
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(apartment.apartmentNumber)),
                          DataCell(Text(apartment.area.toStringAsFixed(1))),
                          DataCell(Text(apartment.status)),
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                color: Theme.of(context).colorScheme.secondary,
                                tooltip: 'Edit',
                                onPressed: () => _navigateToEditApartment(apartment),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                color: Theme.of(context).colorScheme.error,
                                tooltip: 'Delete',
                                onPressed: () => _deleteApartment(apartment.id),
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

// Note: For ApartmentFormView to receive initialApartment, its constructor needs to be updated:
// final String? apartmentId;
// final Apartment? initialApartment;
// const ApartmentFormView({super.key, this.apartmentId, this.initialApartment}); 