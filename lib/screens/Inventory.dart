import 'package:flutter/material.dart';

class InventoryItem {
  String name;
  int count;
  int initialCount;

  InventoryItem({required this.name, required this.count, required this.initialCount});
}

class InventoryPage extends StatefulWidget {
  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<InventoryItem> inventoryItems = [
    InventoryItem(name: "Screwdriver", count: 50, initialCount: 100),
    InventoryItem(name: "Hammer", count: 30, initialCount: 50),
    InventoryItem(name: "Wrench Set", count: 15, initialCount: 20),
    InventoryItem(name: "Paint Brush", count: 75, initialCount: 100),
    InventoryItem(name: "Safety Goggles", count: 40, initialCount: 60),
  ];

  List<InventoryItem> filteredItems = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController countController = TextEditingController();
  final TextEditingController initialCountController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = inventoryItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF01103B),
        title: Text('Inventory Management', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xBFD0D3E8),
                hintText: 'Search Items',
                hintStyle: TextStyle(color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.black54),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              style: TextStyle(color: Colors.black, fontSize: 14),
              onChanged: (value) {
                setState(() {
                  filteredItems = inventoryItems
                      .where((item) => item.name.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return InventoryItemCard(
                  item: filteredItems[index],
                  onCountChanged: (newCount) {
                    setState(() {
                      filteredItems[index].count = newCount;
                    });
                  },
                  onDelete: () {
                    setState(() {
                      inventoryItems.remove(filteredItems[index]);
                      filteredItems.removeAt(index);
                    });
                  },
                  onEdit: () => _showEditItemDialog(filteredItems[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: Icon(Icons.add, color: Colors.white,),
        backgroundColor: Color(0xFF01103B),
      ),
    );
  }

  void _showAddItemDialog() {
    final formKey = GlobalKey<FormState>();
    final nameFocusNode = FocusNode();
    final countFocusNode = FocusNode();
    final initialCountFocusNode = FocusNode();

    // Reset the controllers
    nameController.clear();
    countController.clear();
    initialCountController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Item'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    focusNode: nameFocusNode,
                    decoration: InputDecoration(labelText: 'Item Name'),
                    validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(countFocusNode),
                  ),
                  TextFormField(
                    controller: countController,
                    focusNode: countFocusNode,
                    decoration: InputDecoration(labelText: 'Count'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter a count';
                      if (int.tryParse(value) == null) return 'Please enter a valid number';
                      if (int.parse(value) <= 0) return 'Count must be greater than zero';
                      return null;
                    },
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(initialCountFocusNode),
                  ),
                  TextFormField(
                    controller: initialCountController,
                    focusNode: initialCountFocusNode,
                    decoration: InputDecoration(labelText: 'Initial Count'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter an initial count';
                      if (int.tryParse(value) == null) return 'Please enter a valid number';
                      if (int.parse(value) <= 0) return 'Initial count must be greater than zero';
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
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    InventoryItem newItem = InventoryItem(
                      name: nameController.text,
                      count: int.parse(countController.text),
                      initialCount: int.parse(initialCountController.text),
                    );
                    inventoryItems.add(newItem);
                    filteredItems = List.from(inventoryItems);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add Item'),
            ),
          ],
        );
      },
    );
  }

  void _showEditItemDialog(InventoryItem item) {
    final formKey = GlobalKey<FormState>();
    final nameFocusNode = FocusNode();
    final countFocusNode = FocusNode();
    final initialCountFocusNode = FocusNode();

    nameController.text = item.name;
    countController.text = item.count.toString();
    initialCountController.text = item.initialCount.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Item'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    focusNode: nameFocusNode,
                    decoration: InputDecoration(labelText: 'Item Name'),
                    validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(countFocusNode),
                  ),
                  TextFormField(
                    controller: countController,
                    focusNode: countFocusNode,
                    decoration: InputDecoration(labelText: 'Count'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter a count';
                      if (int.tryParse(value) == null) return 'Please enter a valid number';
                      if (int.parse(value) <= 0) return 'Count must be greater than zero';
                      return null;
                    },
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(initialCountFocusNode),
                  ),
                  TextFormField(
                    controller: initialCountController,
                    focusNode: initialCountFocusNode,
                    decoration: InputDecoration(labelText: 'Initial Count'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter an initial count';
                      if (int.tryParse(value) == null) return 'Please enter a valid number';
                      if (int.parse(value) <= 0) return 'Initial count must be greater than zero';
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
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    item.name = nameController.text;
                    item.count = int.parse(countController.text);
                    item.initialCount = int.parse(initialCountController.text);
                    filteredItems = List.from(inventoryItems);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }
}

class InventoryItemCard extends StatefulWidget {
  final InventoryItem item;
  final Function(int) onCountChanged;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  InventoryItemCard({
    required this.item,
    required this.onCountChanged,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  _InventoryItemCardState createState() => _InventoryItemCardState();
}

class _InventoryItemCardState extends State<InventoryItemCard> {
  bool isExpanded = false;
  TextEditingController adjustmentController = TextEditingController();
  final FocusNode adjustmentFocusNode = FocusNode();
  String? errorText;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.grey.shade500, width: 2.0),
      ),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.item.name, style: TextStyle(fontWeight: FontWeight.bold)),
                // Text('Initial Count: ${widget.item.initialCount}', style: TextStyle(fontSize: 14, color: Colors.black87)),
              ],
            ),
            subtitle: Text('Initial Count: ${widget.item.initialCount}', style: TextStyle(fontSize: 14, color: Colors.black87)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.item.count}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
          if (isExpanded)
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: adjustmentController,
                          focusNode: adjustmentFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Adjust',
                            border: OutlineInputBorder(),
                            errorText: errorText,
                          ),
                          keyboardType: TextInputType.number,
                          onSubmitted: (_) => _adjustCount(true),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () => _adjustCount(true),
                          child: Icon(Icons.add),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () => _adjustCount(false),
                          child: Icon(Icons.remove),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(width: 3,),
                      Expanded(child: Text('Action: ',style: TextStyle(fontSize: 18),)),
                      IconButton(
                        icon: Icon(Icons.edit, size: 20),
                        onPressed: widget.onEdit,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, size: 20),
                        onPressed: widget.onDelete,
                      ),
                    ],
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     TextButton.icon(
                  //       icon: Icon(Icons.edit, color: Colors.black54),
                  //       label: Text(''),
                  //       onPressed: widget.onEdit,
                  //     ),
                  //     SizedBox(width: 8),
                  //     TextButton.icon(
                  //       icon: Icon(Icons.delete, color: Colors.black54),
                  //       label: Text(''),
                  //       onPressed: widget.onDelete,
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _adjustCount(bool isAdding) {
    setState(() {
      errorText = null;
    });

    if (adjustmentController.text.isEmpty) {
      setState(() {
        errorText = 'Please enter a value';
      });
      return;
    }

    int? adjustment = int.tryParse(adjustmentController.text);
    if (adjustment == null || adjustment <= 0) {
      setState(() {
        errorText = 'Please enter a valid positive number';
      });
      return;
    }

    int newCount = isAdding
        ? widget.item.count + adjustment
        : widget.item.count - adjustment;

    if (newCount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Count cannot be less than zero')),
      );
      return;
    }

    widget.onCountChanged(newCount);
    setState(() {
      adjustmentController.clear();
    });
    adjustmentFocusNode.requestFocus();
  }
}
