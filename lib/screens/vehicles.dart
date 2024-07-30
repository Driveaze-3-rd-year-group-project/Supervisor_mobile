import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import 'vehicleDetails.dart';

class Vehicle {
  final String type;
  final String numberPlate;
  final String owner;
  final String details;

  Vehicle(this.type, this.numberPlate, this.owner, this.details);
}

class Vehicles extends StatefulWidget {
  @override
  State<Vehicles> createState() => _VehiclesState();
}

class _VehiclesState extends State<Vehicles> {
  final List<Vehicle> vehicles = [
    Vehicle('Car', 'ABC123', 'John Hunter', 'Honda Vezel 2015 '),
    Vehicle('Van', 'XYZ789', 'Jane Smith', 'Details about Jane\'s van'),
  ];
  late List<Vehicle> filteredVehicles;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredVehicles = vehicles;
    _searchController.addListener(() {
      filterVehicles(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void filterVehicles(String query) {
    List<Vehicle> searchList = vehicles.where((vehicle) {
      return vehicle.numberPlate.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      filteredVehicles = searchList;
    });
  }

  Widget _getVehicleIcon(String type) {
    switch (type) {
      case 'Car':
        return Icon(MaterialCommunityIcons.car_side);
      case 'Van':
        return Icon(MaterialCommunityIcons.van_passenger);
      default:
        return Icon(MaterialCommunityIcons.car_cog);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF01103B),
        title: Text('Vehicle List', style: TextStyle(color: Colors.white),),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xBFD0D3E8),
                hintText: 'Search by number plate',
                hintStyle: TextStyle(color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                prefixIcon: Icon(Icons.search, color: Colors.black54),
              ),
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredVehicles.length,
              itemBuilder: (context, index) {
                final vehicle = filteredVehicles[index];
                return Card(
                  color: Color(0xFF01103B),
                  margin: EdgeInsets.all(10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.white38, width: 2.0),
                  ),
                  child: ListTile(
                    title: Text(vehicle.numberPlate, style: TextStyle(color: Colors.white70),),
                    subtitle: Text(vehicle.owner, style: TextStyle(color: Colors.white70),),
                    trailing: IconTheme(
                      data: IconThemeData(color: Colors.white),
                      child: _getVehicleIcon(vehicle.type),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VehicleDetailPage(vehicle: vehicle),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// class DetailPage extends StatelessWidget {
//   final Vehicle vehicle;
//
//   DetailPage({required this.vehicle});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Vehicle Details'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Type: ${vehicle.type}', style: TextStyle(fontSize: 18)),
//             SizedBox(height: 8),
//             Text('Number Plate: ${vehicle.numberPlate}', style: TextStyle(fontSize: 18)),
//             SizedBox(height: 8),
//             Text('Owner: ${vehicle.owner}', style: TextStyle(fontSize: 18)),
//             SizedBox(height: 8),
//             Text('Details: ${vehicle.details}', style: TextStyle(fontSize: 18)),
//           ],
//         ),
//       ),
//     );
//   }
// }

