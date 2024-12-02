import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'CompletedJobDetails.dart';
import 'vehicleDetails.dart';
import '../services/UserServices.dart';
import '../models/models.dart';

class Completedjobs extends StatefulWidget {
  @override
  State<Completedjobs> createState() => _CompletedjobsState();
}

class _CompletedjobsState extends State<Completedjobs> {
  late List<Vehicle> vehicles = [];
  late List<Vehicle> filteredVehicles;
  final SupervisorService _userService = SupervisorService();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredVehicles = vehicles;
    _searchController.addListener(() {
      filterVehicles(_searchController.text);
    });
    fetchVehicles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void filterVehicles(String query) {
    List<Vehicle> searchList = vehicles.where((vehicle) {
      return vehicle.vehicleNo.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      filteredVehicles = searchList;
    });
  }

  Future<void> fetchVehicles() async {
    try{
      final token = await _userService.getToken();
      if (token == null) {
        throw Exception('User  is not logged in.');
      }

      final response = await SupervisorService.getJobs(token);
      print('Response from API: $response');

      setState(() {
        vehicles = (response as List).map<Vehicle>((data) {
          var jobData = data[0];
          var vehicleData = data[1];
          var serviceDta = data[2];
          var modelData = data[3];
          var brandData = data[4];

          Service service = Service(serviceDta['serviceId'], serviceDta['serviceName']);

          Job job = Job(
            jobData['jobId'],
            jobData['vehicleId'],
            jobData['startTime'],
            jobData['supervisorId'],
            jobData['serviceTypeId'],
            jobData['vehicleMilage'],
            jobData['startedDate'],
            jobData['jobStatus'],
            jobData['jobDescription'] ?? 'No description',
          );

          return Vehicle(
            vehicleData['vehicleId'],
            vehicleData['vehicleNo'] as String,
            brandData['brandName'] as String,
            modelData['modelName'] as String,
            jobData['startedDate'],
            [job],
            [service],

          );
        }).toList();
        filteredVehicles = vehicles.where((vehicle) {
          return vehicle.jobs.any((job) => job.jobStatus == 1);
        }).toList();
      });
    } catch (e) {
      print('Error fetching vehicles: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF01103B),
        title: Text('Completed Repairs', style: TextStyle(color: Colors.white)),
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
                  color: Color(0xFF03304C),
                  margin: EdgeInsets.all(10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.white38, width: 2.0),
                  ),
                  child: ListTile(
                    title: Text(vehicle.vehicleNo, style: TextStyle(color: Colors.white70)),
                    subtitle: Text('${vehicle.brand} ${vehicle.model}', style: TextStyle(color: Colors.white70)),
                    trailing: Text(vehicle.startDate, style: TextStyle(color: Colors.white70)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompletedJobDetails(vehicle: vehicle),
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