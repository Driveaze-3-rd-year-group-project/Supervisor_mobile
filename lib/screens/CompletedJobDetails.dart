import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/models.dart';
import '../services/UserServices.dart'; // Ensure this path is correct

class CompletedJobDetails extends StatefulWidget {
  final Vehicle vehicle;

  CompletedJobDetails({required this.vehicle});

  @override
  _CompletedJobDetailsState createState() => _CompletedJobDetailsState();
}

class _CompletedJobDetailsState extends State<CompletedJobDetails> {
  late List<Repair> repairHistory = [];
  bool _isDetailsExpanded = false;


  List<dynamic> technicians = [];
  List<dynamic> inventoryItems = [];

  @override
  void initState() {
    super.initState();
    repairHistory = RepairHistory.getRepairs(widget.vehicle.vehicleNo);
    _fetchJobEntries(widget.vehicle.jobs[0].jobId); // Fetch job entries

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
        title: Text('Repair Details', style: TextStyle(color: Colors.white)),
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