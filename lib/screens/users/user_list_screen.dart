// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'email': doc['email'] ?? 'No email',
          'information': doc['information'] ?? {},
          'role': doc['role'] ?? 'No role',
          'phoneNumber': doc['phoneNumber'] ?? 'No phone',
          'isActive': doc['isActive'] ?? true,
        };
      }).toList();
    } catch (error) {
      print("Error fetching users: $error");
      return [];
    }
  }

  void _showEditDialog(Map<String, dynamic> user) {
    final TextEditingController nameController =
        TextEditingController(text: user['information']['name'] ?? '');
    final TextEditingController dobController =
        TextEditingController(text: user['information']['dayOfBirth'] ?? '');
    final TextEditingController gplxController =
        TextEditingController(text: user['information']['gplx'] ?? '');
    final TextEditingController roleController =
        TextEditingController(text: user['role'] ?? '');
    final TextEditingController phoneController =
        TextEditingController(text: user['phoneNumber'] ?? '');

    bool isActive = user['isActive'];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit User Details'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Is Active'),
                        Switch(
                          value: isActive,
                          onChanged: (value) {
                            setDialogState(() {
                              isActive = value;
                            });
                          },
                        ),
                      ],
                    ),
                    if (isActive) ...[
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      TextField(
                        controller: dobController,
                        decoration:
                            const InputDecoration(labelText: 'Date of Birth'),
                      ),
                      TextField(
                        controller: gplxController,
                        decoration: const InputDecoration(labelText: 'GPLX'),
                      ),
                      TextField(
                        controller: roleController,
                        decoration: const InputDecoration(labelText: 'Role'),
                      ),
                      TextField(
                        controller: phoneController,
                        decoration:
                            const InputDecoration(labelText: 'Phone Number'),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user['id'])
                          .update({
                        'isActive': isActive,
                        if (isActive) ...{
                          'information.name': nameController.text,
                          'information.dayOfBirth': dobController.text,
                          'information.gplx': gplxController.text,
                          'role': roleController.text,
                          'phoneNumber': phoneController.text,
                        },
                      });
                      Navigator.pop(context);
                      setState(() {
                        _usersFuture = _fetchUsers();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User details updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      print("Error updating user: $e");
                    }
                  },
                  child: const Text('Save'),
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
        title: const Text(
          'User List',
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No users available.',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  }

                  final users = snapshot.data!;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (ctx, index) {
                      final user = users[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          title: Text(
                            user['information']['name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['email']),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(user),
                          ),
                        ),
                      );
                    },
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
