import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'vehicles.dart';

class VehicleDetailPage extends StatefulWidget {
  final Vehicle vehicle;

  VehicleDetailPage({required this.vehicle});

  @override
  _VehicleDetailPageState createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  late List<Repair> repairHistory;
  bool _isDetailsExpanded = false;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  String? _dateError;
  String? _detailsError;

  @override
  void initState() {
    super.initState();
    repairHistory = RepairHistory.getRepairs(widget.vehicle.numberPlate);
  }

  void _showAddRepairDialog() {
    dateController.clear();
    detailsController.clear();
    _dateError = null;
    _detailsError = null;
    String? selectedTechnician;

    List<String> technicians = ['Ruwan Pathirana', 'Mahesh Senanayake', 'Maleesha Wickramasinghe'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Repair'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.99,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: dateController,
                      decoration: InputDecoration(
                        labelText: 'Repair Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Ionicons.calendar_sharp),
                        errorText: _dateError,
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            dateController.text = pickedDate.toLocal().toString().split(' ')[0];
                            _dateError = null;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: detailsController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Repair Details',
                        border: OutlineInputBorder(),
                        errorText: _detailsError,
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedTechnician,
                      decoration: InputDecoration(
                        labelText: 'Technician',
                        border: OutlineInputBorder(),
                      ),
                      items: technicians.map((String technician) {
                        return DropdownMenuItem<String>(
                          value: technician,
                          child: Text(technician),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedTechnician = newValue;
                        });
                      },
                    ),
                  ],
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
                    final date = dateController.text;
                    final details = detailsController.text;
                    setState(() {
                      _dateError = date.isEmpty ? 'Please select a date' : null;
                      _detailsError = details.isEmpty ? 'Please enter repair details' : null;
                    });
                    if (_dateError == null && _detailsError == null && selectedTechnician != null) {
                      Repair newRepair = Repair(date, details, selectedTechnician!);
                      RepairHistory.addRepair(widget.vehicle.numberPlate, newRepair);
                      Navigator.of(dialogContext).pop();
                      this.setState(() {
                        repairHistory = RepairHistory.getRepairs(widget.vehicle.numberPlate);
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Color(0xFF01103B),
        title: Text('Update Repairs', style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Vehicle Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              Text('Type: ${widget.vehicle.type}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text('Number Plate: ${widget.vehicle.numberPlate}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text('Owner: ${widget.vehicle.owner}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text('Model: ${widget.vehicle.details}', style: TextStyle(fontSize: 18)),
            ],
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Repair History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(repair.date),
                        Text(repair.technician),
                      ],
                    ),                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: ElevatedButton(
                child: Text('Complete',style: TextStyle(color: Colors.white),),
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
  final String date;
  final String details;
  final String technician;

  Repair(this.date, this.details, this.technician);
}

class RepairHistory {
  static final Map<String, List<Repair>> _repairHistory = {
    'ABC123': [
      Repair('2023-01-10', 'Oil change', 'Ruwan Pathirana'),
      Repair('2023-03-15', 'Brake replacement','Mahesh Senanayake' ),
    ],
    'XYZ789': [
      Repair('2023-02-20', 'Tire replacement', 'Mahesh Senanayake'),
      Repair('2023-04-22', 'Battery replacement', 'Mahesh Senanayake'),
    ],
  };

  static List<Repair> getRepairs(String numberPlate) {
    if (_repairHistory.containsKey(numberPlate)) {
      List<Repair> repairs = List.from(_repairHistory[numberPlate]!);
      repairs.sort((a, b) => b.date.compareTo(a.date));
      return repairs;
    } else {
      return [];
    }
  }

  static void addRepair(String numberPlate, Repair repair) {
    if (_repairHistory.containsKey(numberPlate)) {
      _repairHistory[numberPlate]!.add(repair);
    } else {
      _repairHistory[numberPlate] = [repair];
    }
  }
}

