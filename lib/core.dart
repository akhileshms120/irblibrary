// ... imports ...
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class BorrowFormScreen extends StatefulWidget {
  @override
  _BorrowFormScreenState createState() => _BorrowFormScreenState();
}

class _BorrowFormScreenState extends State<BorrowFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String phone = '';
  String bookName = '';
  String glNo = '';
  DateTime? dateTaken;
  DateTime? dueDate;
  List<Map<String, dynamic>> allEntries = [];
  bool isLoading = false;
  String connectionStatus = 'Not tested';

  @override
  void initState() {
    super.initState();
    _testConnection();
    _loadAllEntries();
  }

  // Test Supabase connection
  Future<void> _testConnection() async {
    setState(() {
      connectionStatus = 'Testing...';
    });

    try {
      // Test 1: Check if we can connect to Supabase
      final client = Supabase.instance.client;
      
      // Test 2: Try to fetch data from the table
      final response = await client
          .from('borrowings')
          .select('count')
          .limit(1);
      
      setState(() {
        connectionStatus = '✅ Connected Successfully!';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Supabase connection successful!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      setState(() {
        connectionStatus = '❌ Connection Failed: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
      print('Supabase connection error: $e');
    }
  }

  Future<void> _loadAllEntries() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final response = await Supabase.instance.client
          .from('borrowings')
          .select()
          .order('created_at', ascending: false);
      
      setState(() {
        allEntries = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading entries: $e')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Check for unique GL No
    final response = await Supabase.instance.client
        .from('borrowings')
        .select()
        .eq('gl_no', glNo)
        .maybeSingle();

    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("GL No already exists!")),
      );
      return;
    }

    // Insert record
    await Supabase.instance.client.from('borrowings').insert({
      'name': name,
      'phone': phone,
      'book_name': bookName,
      'gl_no': glNo,
      'date_taken': dateTaken!.toIso8601String(),
      'due_date': dueDate!.toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Book borrowing recorded successfully!')),
    );
    _formKey.currentState!.reset();
    setState(() {
      dateTaken = null;
      dueDate = null;
    });
    _loadAllEntries(); // Refresh the list
  }

  Future<void> _deleteEntry(String id) async {
    try {
      await Supabase.instance.client
          .from('borrowings')
          .delete()
          .eq('id', id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Entry deleted successfully!')),
      );
      _loadAllEntries(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting entry: $e')),
      );
    }
  }

  Future<void> _editEntry(Map<String, dynamic> entry) async {
    // Show edit dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditEntryDialog(entry: entry),
    );
    
    if (result != null) {
      try {
        await Supabase.instance.client
            .from('borrowings')
            .update(result)
            .eq('id', entry['id']);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Entry updated successfully!')),
        );
        _loadAllEntries(); // Refresh the list
      } catch (e, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating entry: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Borrow Book'),
        actions: [
          // Test Connection Button
          IconButton(
            icon: Icon(Icons.wifi),
            onPressed: _testConnection,
            tooltip: 'Test Connection',
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection Status
          Container(
            padding: EdgeInsets.all(8),
            color: connectionStatus.contains('✅') ? Colors.green.shade50 : Colors.red.shade50,
            child: Row(
              children: [
                Icon(
                  connectionStatus.contains('✅') ? Icons.check_circle : Icons.error,
                  color: connectionStatus.contains('✅') ? Colors.green : Colors.red,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    connectionStatus,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: connectionStatus.contains('✅') ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Form Section
          Expanded(
            flex: 1,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Name *'),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter the borrower\'s name' : null,
                    onSaved: (val) => name = val!,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Phone *'),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter phone number' : null,
                    onSaved: (val) => phone = val!,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Book Name *'),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter book name' : null,
                    onSaved: (val) => bookName = val!,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'GL No *'),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter GL No' : null,
                    onSaved: (val) => glNo = val!,
                  ),
                  SizedBox(height: 16),
                  // Date picker for date taken
                  ListTile(
                    title: Text('Date Taken: ${dateTaken != null ? DateFormat('yyyy-MM-dd').format(dateTaken!) : 'Select Date'}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() {
                          dateTaken = date;
                          dueDate = date.add(Duration(days: 14)); // 2 weeks from date taken
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  // Due date (read-only)
                  if (dueDate != null)
                    ListTile(
                      title: Text('Due Date: ${DateFormat('yyyy-MM-dd').format(dueDate!)}'),
                      subtitle: Text('Auto-calculated (2 weeks from date taken)'),
                    ),
                  SizedBox(height: 16),
                  // Submit Button
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Entries List Section
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Entries',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : allEntries.isEmpty
                            ? Center(child: Text('No entries found'))
                            : ListView.builder(
                                itemCount: allEntries.length,
                                itemBuilder: (context, index) {
                                  final entry = allEntries[index];
                                  final isOverdue = DateTime.now().isAfter(DateTime.parse(entry['due_date']));
                                  
                                  return Card(
                                    margin: EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      title: Text(entry['name']),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Book: ${entry['book_name']}'),
                                          Text('GL No: ${entry['gl_no']}'),
                                          Text(
                                            'Due: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(entry['due_date']))}',
                                            style: TextStyle(
                                              color: isOverdue ? Colors.red : Colors.black,
                                              fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _editEntry(entry),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deleteEntry(entry['id'].toString()),
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
            ),
          ),
        ],
      ),
    );
  }
}

// Edit Entry Dialog
class EditEntryDialog extends StatefulWidget {
  final Map<String, dynamic> entry;
  
  EditEntryDialog({required this.entry});
  
  @override
  _EditEntryDialogState createState() => _EditEntryDialogState();
}

class _EditEntryDialogState extends State<EditEntryDialog> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController bookNameController;
  late TextEditingController glNoController;
  DateTime? dateTaken;
  DateTime? dueDate;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.entry['name']);
    phoneController = TextEditingController(text: widget.entry['phone']);
    bookNameController = TextEditingController(text: widget.entry['book_name']);
    glNoController = TextEditingController(text: widget.entry['gl_no']);
    dateTaken = DateTime.parse(widget.entry['date_taken']);
    dueDate = DateTime.parse(widget.entry['due_date']);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Entry'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: bookNameController,
              decoration: InputDecoration(labelText: 'Book Name'),
            ),
            TextField(
              controller: glNoController,
              decoration: InputDecoration(labelText: 'GL No'),
            ),
            ListTile(
              title: Text('Date Taken: ${dateTaken != null ? DateFormat('yyyy-MM-dd').format(dateTaken!) : 'Select Date'}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: dateTaken ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() {
                    dateTaken = date;
                    dueDate = date.add(Duration(days: 14));
                  });
                }
              },
            ),
            if (dueDate != null)
              ListTile(
                title: Text('Due Date: ${DateFormat('yyyy-MM-dd').format(dueDate!)}'),
                subtitle: Text('Auto-calculated (2 weeks from date taken)'),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedEntry = {
              'name': nameController.text,
              'phone': phoneController.text,
              'book_name': bookNameController.text,
              'gl_no': glNoController.text,
              'date_taken': dateTaken!.toIso8601String(),
              'due_date': dueDate!.toIso8601String(),
            };
            Navigator.of(context).pop(updatedEntry);
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    bookNameController.dispose();
    glNoController.dispose();
    super.dispose();
  }
}