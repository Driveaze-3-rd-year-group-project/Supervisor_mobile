import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Technician {
  String employeeId;
  String fullName;
  String phoneNumber;
  String gender;

  Technician({
    required this.employeeId,
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
  });
}

class TechnicianPage extends StatefulWidget {
  @override
  _TechnicianPageState createState() => _TechnicianPageState();
}

class _TechnicianPageState extends State<TechnicianPage> {
  List<Technician> technicians = [];
  List<Technician> filteredTechnicians = [];
  TextEditingController _searchController = TextEditingController();

  final TextEditingController employeeIdController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  String gender = 'Male';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadInitialTechnicians();
    filteredTechnicians = technicians;
    _searchController.addListener(() {
      filterTechnicians(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    employeeIdController.dispose();
    fullNameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  void _loadInitialTechnicians() {
    setState(() {
      technicians = [
        Technician(employeeId: "T001", fullName: "Robin Greyson", phoneNumber: "1234567890", gender: "Male"),
        Technician(employeeId: "T002", fullName: "Emma Stone", phoneNumber: "0987654321", gender: "Female"),
        Technician(employeeId: "T003", fullName: "Alex Hale", phoneNumber: "5555555555", gender: "Male"),
      ];
    });
  }

  void filterTechnicians(String query) {
    List<Technician> searchList = technicians.where((technician) {
      return technician.fullName.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      filteredTechnicians = searchList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF01103B),
        title: Text('Technicians', style: TextStyle(color: Colors.white)),
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
                hintText: 'Search by technician name',
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
              itemCount: filteredTechnicians.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(10.0),
                  color: Colors.blueAccent.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.grey.shade300, width: 2.0),
                  ),
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(child: Text(filteredTechnicians[index].fullName, style: TextStyle(fontWeight: FontWeight.bold))),
                        Text(filteredTechnicians[index].phoneNumber, style: TextStyle(fontSize: 15)),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(child: Text('ID: ${filteredTechnicians[index].employeeId}', style: TextStyle(fontWeight: FontWeight.w800),)),
                        IconButton(
                          icon: Icon(Icons.edit, size: 20),
                          onPressed: () => _showEditTechnicianDialog(context, index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, size: 20),
                          onPressed: () => _deleteTechnician(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddTechnicianDialog(context),
        backgroundColor: Color(0xFF01103B),
      ),
    );
  }

  void _showAddTechnicianDialog(BuildContext context) {
    _resetForm();
    _showTechnicianDialog(context, isEditing: false);
  }

  void _showEditTechnicianDialog(BuildContext context, int index) {
    _resetForm();
    employeeIdController.text = filteredTechnicians[index].employeeId;
    fullNameController.text = filteredTechnicians[index].fullName;
    phoneNumberController.text = filteredTechnicians[index].phoneNumber;
    gender = filteredTechnicians[index].gender;
    _showTechnicianDialog(context, isEditing: true, editIndex: index);
  }

  void _showTechnicianDialog(BuildContext context, {required bool isEditing, int? editIndex}) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Technician' : 'Add New Technician'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: employeeIdController,
                        decoration: InputDecoration(
                          labelText: 'Employee ID',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Employee ID';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Full Name';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: phoneNumberController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Phone Number';
                          }
                          if (value.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: gender,
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Male', 'Female'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setDialogState(() {
                              gender = newValue;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select Gender';
                          }
                          return null;
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Technician technician = Technician(
                        employeeId: employeeIdController.text,
                        fullName: fullNameController.text,
                        phoneNumber: phoneNumberController.text,
                        gender: gender,
                      );
                      Navigator.of(dialogContext).pop();
                      setState(() {
                        if (isEditing && editIndex != null) {
                          technicians[technicians.indexWhere((t) => t.employeeId == filteredTechnicians[editIndex].employeeId)] = technician;
                          filteredTechnicians[editIndex] = technician;
                        } else {
                          technicians.add(technician);
                          filteredTechnicians.add(technician);
                        }
                      });
                      _resetForm();
                    }
                  },
                  icon: Icon(isEditing ? Icons.save : Icons.add),
                  label: Text(isEditing ? 'Save Changes' : 'Add Technician'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteTechnician(int index) {
    setState(() {
      Technician technicianToRemove = filteredTechnicians[index];
      technicians.removeWhere((t) => t.employeeId == technicianToRemove.employeeId);
      filteredTechnicians.removeAt(index);
    });
  }

  void _resetForm() {
    employeeIdController.clear();
    fullNameController.clear();
    phoneNumberController.clear();
    gender = 'Male';
  }
}