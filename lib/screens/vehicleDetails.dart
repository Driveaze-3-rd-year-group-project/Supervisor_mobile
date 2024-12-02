import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
        repairHistory.sort((a, b) => a.jobEntryId.compareTo(b.jobEntryId)); // Sort by details or any other criteria
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
    String? technicianError;
    int? selectedTechnician;
    String? inventoryError;

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
                        onChanged: (value) {
                          // Validate input to ensure it's an integer
                          if (value.isNotEmpty && int.tryParse(value) == null) {
                            setState(() {
                              _manHoursError = 'Please enter a valid integer';
                            });
                          } else {
                            setState(() {
                              _manHoursError = null; // Clear error if valid
                            });
                          }
                        },
                      ),
                      SizedBox(height: 8),

                      // Technician Dropdown
                      DropdownButtonFormField<int>(
                        value: selectedTechnician,
                        decoration: InputDecoration(
                          labelText: 'Technician',
                          border: OutlineInputBorder(),
                          errorText: technicianError,
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
                            technicianError = null;
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
                  onPressed: () async {
                    final details = detailsController.text;
                    final manHours = manHoursController.text;
                    setState(() {
                      _detailsError = details.isEmpty ? 'Please enter repair details' : null;
                      _manHoursError = manHours.isEmpty ? 'Please enter man hours' : null;
                      technicianError = selectedTechnician == null ? 'Please select a technician' : null;
                      inventoryError = null;
                    });




                      if (_detailsError == null && _manHoursError == null && technicianError == null) {
                        bool validity = true;
                        for (var selectedItem in selectedInventoryItems) {
                          for (var inventoryItem in inventoryItems) {
                            if (selectedItem['id'] == inventoryItem['itemId']) {
                              if (selectedItem['quantity'] > inventoryItem['count']) {
                                validity = false;
                                // Fluttertoast.showToast(
                                //   msg:'Insufficient inventory items.',
                                //   toastLength: Toast.LENGTH_SHORT,
                                //   gravity: ToastGravity.TOP,
                                //   backgroundColor: Colors.red,
                                //   textColor: Colors.white,
                                //   fontSize: 16.0,
                                // );
                                inventoryError = 'Quantity for ${inventoryItem['name']} exceeds available count';
                                break;
                              }
                            }
                          }
                          if (!validity) break; // Exit loop if invalid
                        }
                        final now = DateTime.now();

                        final payload = {
                        'jobRegistry': widget.vehicle.jobs[0],
                        'details': details,
                        'manHours': manHours,
                        'technicianId': selectedTechnician,
                        'entryDate': now.toIso8601String().split('T')[0].toString(),
                        'time': now.toIso8601String().split('T')[1].split('.')[0].toString(),
                        'inventoryItemList': selectedInventoryItems.map((item) {
                          return {
                            'id': item['id'].toString(), // Convert to String if necessary
                            'quantity': item['quantity'].toString(), // Convert to String if necessary
                          };
                        }).toList(),
                        };
                        print(payload);
                        String? token = await SupervisorService().getToken();
                        final res = await SupervisorService.addEntry(payload, token!);
                        print(res);
                        if (res.data['statusCode'] == 200) {

                          Fluttertoast.showToast(
                            msg: "Repair entry added successfully!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                          setState(() {
                            repairHistory.clear(); // Clear the list
                          });
                          await _fetchJobEntries(widget.vehicle.jobs[0].jobId);
                          Navigator.of(context).pop();
                        }else{
                          Fluttertoast.showToast(
                            msg: res.data['message'] ?? 'An unknown error occurred.',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }

                      // Repair newRepair = Repair(0,details, manHours, selectedTechnician!);
                      // Add logic to handle inventory items if needed
                      // RepairHistory.addRepair(widget.vehicle.vehicleNo, newRepair);
                      // Navigator.of(dialogContext).pop();
                      // this.setState(() {
                      //   // Update repair history if necessary
                      // });
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

  void _showDeleteConfirmationDialog(int jobEntryId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete Repair Entry'),
          content: Text('Are you sure you want to delete this repair entry?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                // Call the method to delete the repair entry
                String? token = await SupervisorService().getToken();
                final res = await SupervisorService.deleteEntry(jobEntryId, token!);
                if(res.data['statusCode']==200){
                  setState(() {
                    repairHistory.clear(); // Clear the list
                  });
                  await _fetchJobEntries(widget.vehicle.jobs[0].jobId);

                  Fluttertoast.showToast(
                    msg: 'Entry delete Successful!!.',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.TOP,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  Navigator.of(dialogContext).pop();
                }else{
                  Fluttertoast.showToast(
                    msg: res.data['message'] ?? 'An unknown error occurred.',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.TOP,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showEntryDetailsDialog(Repair repair) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Repair Entry Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Entry Id: ${repair.jobEntryId}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Entry Date: ${repair.entryDate}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Time: ${repair.time}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Technician Name: ${repair.technician}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Details: ${repair.details}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Man Hours: ${repair.manHours}', style: TextStyle(fontSize: 16)),
                // Add more fields as necessary
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showJobCompleteConfirmationDialog(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Complete Job'),
          content: Text('Are you sure you want to mark this job as completed?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () async {

                final now = DateTime.now();

                Map<String, dynamic> payload = {
                  'jobId': vehicle.jobs[0].jobId,
                  'vehicleId': vehicle.jobs[0].vehicleId,
                  'startedDate': vehicle.jobs[0].startedDate,
                  'startTime': vehicle.jobs[0].startTime,
                  'finishedDate': now.toIso8601String().split('T')[0].toString(),
                  'supervisorId': vehicle.jobs[0].supervisorId,
                  'serviceTypeId': vehicle.jobs[0].serviceTypeId,
                  'vehicleMilage': vehicle.jobs[0].vehicleMilage,
                  'jobStatus': 1,
                  'jobDescription': vehicle.jobs[0].jobDescription,
                };


                String? token = await SupervisorService().getToken();
                final res = await SupervisorService.completeJob(vehicle.jobs[0].jobId, payload,token!);

                if(res.data['statusCode']==200){
                  Navigator.of(context).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }else{
                  Fluttertoast.showToast(
                    msg: res.data['message'] ?? 'An unknown error occurred.',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.TOP,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }

                // Close the dialog

              },
            ),
          ],
        );
      },
    );
  }

  void _showEditRepairDialog(Repair repair) {
    // Create TextEditingControllers and initialize them with the current values
    TextEditingController detailsController = TextEditingController(text: repair.details);
    TextEditingController manHoursController = TextEditingController(text: repair.manHours.toString());

    String? _detailsError;
    String? _manHoursError;
    String? technicianError;
    int? selectedTechnician = repair.technicianId; // Assuming technicianId is part of the Repair model

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Edit Repair'),
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
                        onChanged: (value) {
                          // Validate input to ensure it's an integer
                          if (value.isNotEmpty && int.tryParse(value) == null) {
                            setState(() {
                              _manHoursError = 'Please enter a valid integer';
                            });
                          } else {
                            setState(() {
                              _manHoursError = null; // Clear error if valid
                            });
                          }
                        },
                      ),
                      SizedBox(height: 8),

                      // Technician Dropdown
                      DropdownButtonFormField<int>(
                        value: selectedTechnician,
                        decoration: InputDecoration(
                          labelText: 'Technician',
                          border: OutlineInputBorder(),
                          errorText: technicianError,
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
                            technicianError = null; // Clear error on selection
                          });
                        },
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
                  onPressed: () async {
                    final details = detailsController.text;
                    final manHours = manHoursController.text;

                    // Validate inputs
                    setState(() {
                      _detailsError = details.isEmpty ? 'Please enter repair details' : null;
                      _manHoursError = manHours.isEmpty ? 'Please enter man hours' : null;
                      technicianError = selectedTechnician == null ? 'Please select a technician' : null;
                    });

                    if (_detailsError == null && _manHoursError == null && technicianError == null) {
                      // Create the payload for the update
                      final payload = {
                        'repairId': repair.jobEntryId,
                        'jobRegistry': widget.vehicle.jobs[0],
                        'details': details,
                        'manHours': manHours,
                        'technicianId': selectedTechnician,
                        'entryDate': repair.entryDate,
                        'time': repair.time,
                      };

                      // Call your service to update the repair
                      String? token = await SupervisorService().getToken();
                      final res = await SupervisorService.updateEntry(repair.jobEntryId,payload, token!); // Assuming you have an update method

                      if (res.data['statusCode'] == 200) {
                        setState(() {
                          repairHistory.clear(); // Clear the list
                        });
                        await _fetchJobEntries(widget.vehicle.jobs[0].jobId);
                        Fluttertoast.showToast(
                          msg: "Repair entry updated successfully!!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                        Navigator.of(context).pop(); // Close the dialog
                      } else {
                        Fluttertoast.showToast(
                          msg: res.data['message'] ?? 'An unknown error occurred.',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    }
                  },
                  icon: Icon(Icons.edit),
                  label: Text('Update Repair'),
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
                          onPressed: () {
                            _showEntryDetailsDialog(repair);
                          }
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          alignment: Alignment.center,
                          onPressed:() {
                            _showEditRepairDialog(repair);
                          }
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          alignment: Alignment.center,
                          onPressed:() {
                            _showDeleteConfirmationDialog(repair.jobEntryId);
                          }
                        ),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(repair.entryDate),
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
                  _showJobCompleteConfirmationDialog(widget.vehicle);

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
  final int jobEntryId;
  final String entryDate;
  final String time;
  final int technicianId;
  final String details;
  final double manHours;
  final String technician;

  Repair(this.jobEntryId,this.entryDate,this.time,this.technicianId,this.details, this.manHours, this.technician);
}

class RepairHistory {
  static final Map<String, List<Repair>> _repairHistory = {};

  // Method to get repairs for a specific vehicle number
  static List<Repair> getRepairs(String numberPlate) {
    if (_repairHistory.containsKey(numberPlate)) {
      List<Repair> repairs = List.from(_repairHistory[numberPlate]!);
      repairs.sort((a, b) => b.jobEntryId.compareTo(a.jobEntryId)); // Sort by details or any other criteria
      return repairs;
    } else {
      return [];
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
            jobEntry['jobEntryId'],
            jobEntry['entryDate'],
            jobEntry['time'],
            jobEntry['technicianId'],
            jobEntry['details'],
            jobEntry['manHours'],
            technicianName,
            // technicianName,
          ));
        }

        repairs.sort((a, b) => a.jobEntryId.compareTo(b.jobEntryId)); // Sort by details or any other criteria
        return repairs;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw Exception('Failed to fetch job entries: $e');
    }
  }
}