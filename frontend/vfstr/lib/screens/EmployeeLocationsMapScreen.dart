import 'package:flutter/material.dart'; 
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:vfstr/constants/serverurl.dart';

class EmployeeLocationMapScreen extends StatefulWidget {
  final String filterType; 
  final String? employeeId;
  final String? selectedDate;

  EmployeeLocationMapScreen({
    this.filterType = 'all',
    this.employeeId,
    this.selectedDate,
  });

  @override
  _EmployeeLocationMapScreenState createState() => _EmployeeLocationMapScreenState();
}

class _EmployeeLocationMapScreenState extends State<EmployeeLocationMapScreen> {
  List<dynamic> employeeLocations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEmployeeLocations();
  }

  Future<void> fetchEmployeeLocations() async {
    setState(() {
      isLoading = true;
    });

    try {
      Uri url;

      // Choose endpoint based on filterType
      if (widget.filterType == 'byEmployeeId') {
        url = Uri.parse('$serverurl/api/employee-locations/by-employee-id/${widget.employeeId}');
      } else if (widget.filterType == 'byDate') {
        url = Uri.parse('$serverurl/api/employee-locations/by-date/${widget.selectedDate}');
      } else {
        url = Uri.parse('$serverurl/api/employee-locations/');
      }

      var response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          employeeLocations = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        showError('Failed to load locations');
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  void showError(String message) {
    setState(() {
      isLoading = false;
    });
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Locations'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : employeeLocations.isEmpty
              ? Center(child: Text('No locations found'))
              : FlutterMap(
                  options: MapOptions(
                    center: employeeLocations.isNotEmpty
                        ? LatLng(
                            employeeLocations[0]['latitude'],
                            employeeLocations[0]['longitude'],
                          )
                        : LatLng(16.23286980, 80.55047660), // Default center
                    zoom: 16.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: employeeLocations.map((location) {
                        return Marker(
                          width: 80.0,
                          height: 80.0,
                          point: LatLng(location['latitude'], location['longitude']),
                          builder: (ctx) => Column(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                              Text(
                                location['name'],
                                style: TextStyle(
                                  color: Colors.black,
                                  backgroundColor: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
    );
  }
}
