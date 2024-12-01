import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../models/models.dart';
import '../services/UserServices.dart'; // Ensure this path is correct

class VehicleDetailPage extends StatefulWidget {
  final Vehicle vehicle;

  VehicleDetailPage({required this.vehicle});

  @override
  _VehicleDetailPageState createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  late List<Repair> repairHistory = [];
  bool _isDetailsExpanded = false;
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController manHoursController = TextEditingController();
  String? _detailsError;
  String? _manHoursError;

  List<dynamic> technicians = [];
  List<dynamic> inventoryItems = [];

  @override
  void initState() {
    super.initState();
    repairHistory = RepairHistory.getRepairs(widget.vehicle.vehicleNo);
    _fetchJobEntries(widget.vehicle.jobs[0].jobId); // Fetch job entries
    _fetchTechniciansAndInventory(); // Fetch technicians and inventory items
  }

  Future<void> _fetchTechniciansAndInventory() async {
    String? token = await SupervisorService().getToken(); // Get the token
    try {
      List<dynamic> fetchedTechnicians = await SupervisorService.getAllTechnician(token!);
      print(fetchedTechnicians);
      List<dynamic> fetchedInventoryItems = await SupervisorService.getAllInventory(token);

      setState(() {
        technicians = fetchedTechnicians;
        inventoryItems = fetchedInventoryItems;
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> _fetchJobEntries(int jobId) async {
    String? token = await SupervisorService().getToken(); // Get the token
    try {
      List<Repair> jobEntries = await RepairHistory.fetchJobEntries(jobId, token!);
      setState(() {
        repairHistory.addAll(jobEntries); // Add job entries to the repair history
        repairHistory.sort((a, b) => a.details.compareTo(b.details)); // Sort by details or any other criteria
      });
    } catch (error) {
      print(error);
    }
  }

  void _showAddRepairDialog() {
    detailsController.clear();
    manHoursController.clear();
    _detailsError = null;
    _manHoursError = null;
    int? selectedTechnician;

    List<Map<String, dynamic>> selectedInventoryItems = []; // For inventory items

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Repair'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Details Field
                      TextField(
                        controller: detailsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Repair Details',
                          border: OutlineInputBorder(),
                          errorText: _detailsError,
                        ),
                      ),
                      SizedBox(height: 8),

                      // Man Hours Field
                      TextField(
                        controller: manHoursController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Man Hours',
                          border: OutlineInputBorder(),
                          errorText: _manHoursError,
                        ),
                      ),
                      SizedBox(height: 8),

                      // Technician Dropdown
                      DropdownButtonFormField<int>(
                        value: selectedTechnician,
                        decoration: InputDecoration(
                          labelText: 'Technician',
                          border: OutlineInputBorder(),
                        ),
                        items: technicians.map((technician) {
                          return DropdownMenuItem<int>(
                            value: technician['id'],
                            child: Text(technician['name']),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedTechnician = newValue;
                          });
                        },
                      ),
                      SizedBox(height: 20),

                      // Inventory Items Section
                      Text('Used Inventory Items', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 8),
                      Column(
                        children: selectedInventoryItems.map((item) {
                          return Row(
                            children: [
                          Expanded(
                          child: DropdownButtonFormField<int>(
                            value: item['id'],
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                            hintText: 'Select Item',
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          ),
                          items: inventoryItems.map((inventoryItem) {
                            return DropdownMenuItem<int>(
                              value: inventoryItem['itemId'], // Assuming 'itemId' is the field you want to use
                              child: Text(inventoryItem['name']),
                            );
                          }).toList(),
                            onChanged: (value) {
                              setState(() {
                                item['id'] = value;
                              });
                            },
                            ),
                          ),
                          SizedBox(width: 8),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Qty',
                                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  item['quantity'] = int.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                selectedInventoryItems.remove(item);
                              });
                            },
                          ),
                          ],
                          );
                        }).toList(),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedInventoryItems.add({'id': null, 'quantity': 0});
                          });
                        },
                        child: Text('Add Inventory Item'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final details = detailsController.text;
                    final manHours = manHoursController.text;
                    setState(() {
                      _detailsError = details.isEmpty ? 'Please enter repair details' : null;
                      _manHoursError = manHours.isEmpty ? 'Please enter man hours' : null;
                    });
                    if (_detailsError == null && _manHoursError == null && selectedTechnician != null) {
                      Repair newRepair = Repair(details, manHours, selectedTechnician!);
                      // Add logic to handle inventory items if needed
                      RepairHistory.addRepair(widget.vehicle.vehicleNo, newRepair);
                      Navigator.of(dialogContext).pop();
                      this.setState(() {
                        // Update repair history if necessary
                      });
                    }
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add Repair'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String getJobStatus(int status) {
    switch (status) {
      case 0:
        return 'Ongoing';
      case 1:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Color(0xFF01103B),
        title: Text('Update Repairs', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Job Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(_isDetailsExpanded ? Ionicons.caret_up : Ionicons.caret_down),
                  onPressed: () {
                    setState(() {
                      _isDetailsExpanded = !_isDetailsExpanded;
                    });
                  },
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
              ],
            ),
            if (_isDetailsExpanded) ...[
              SizedBox(height: 8),
              Text('Vehicle No: ${widget.vehicle.vehicleNo}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Vehicle Model: ${widget.vehicle.brand + " " + widget.vehicle.model}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Job Started Date: ${widget.vehicle.jobs[0].startedDate}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Service Type: ${widget.vehicle.service[0].serviceName}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Status: ${getJobStatus (widget.vehicle.jobs[0].jobStatus)}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
            ],
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Repair Updates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.add_box_rounded),
                  alignment: Alignment.center,
                  onPressed: _showAddRepairDialog,
                ),
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: repairHistory.length,
                itemBuilder: (context, index) {
                  final repair = repairHistory[index];
                  return ListTile(
                    title: Text(repair.details),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_red_eye_rounded),
                          alignment: Alignment.center,
                          onPressed: _showAddRepairDialog,
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          alignment: Alignment.center,
                          onPressed: _showAddRepairDialog,
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          alignment: Alignment.center,
                          onPressed: _showAddRepairDialog,
                        ),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(repair.manHours),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: ElevatedButton(
                child: Text('Complete', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF01103B),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Repair {
  final String details;
  final String manHours;
  final int technician;

  Repair(this.details, this.manHours, this.technician);
}

class RepairHistory {
  static final Map<String, List<Repair>> _repairHistory = {};

  // Method to get repairs for a specific vehicle number
  static List<Repair> getRepairs(String numberPlate) {
    if (_repairHistory.containsKey(numberPlate)) {
      List<Repair> repairs = List.from(_repairHistory[numberPlate]!);
      repairs.sort((a, b) => b.details.compareTo(a.details)); // Sort by details or any other criteria
      return repairs;
    } else {
      return [];
    }
  }

  // Method to add a repair for a specific vehicle number
  static void addRepair(String numberPlate, Repair repair) {
    if (_repairHistory.containsKey(numberPlate)) {
      _repairHistory[numberPlate]!.add(repair);
    } else {
      _repairHistory[numberPlate] = [repair];
    }
  }

  // Method to fetch job entries
  static Future<List<Repair>> fetchJobEntries(int jobId, String token) async {
    try {
      final response = await SupervisorService.getAllEntriesOfJob(jobId, token);

      if (response.data['statusCode'] == 200) {
        List<Repair> repairs = [];

        for (var entry in response.data['details']) {
          var jobEntry = entry[0]; // Job entry details
          var technicianName = entry[1]; // Technician name

          repairs.add(Repair(
            jobEntry['details'],
            jobEntry['entryDate'].toString(),
            technicianName,
          ));
        }

        repairs.sort((a, b) => a.details.compareTo(b.details)); // Sort by details or any other criteria
        return repairs;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw Exception('Failed to fetch job entries: $e');
    }
  }
}