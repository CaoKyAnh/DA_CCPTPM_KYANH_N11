import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MotorcycleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> motorcycle;

  const MotorcycleDetailScreen({super.key, required this.motorcycle});

  @override
  Widget build(BuildContext context) {
    var info = motorcycle['informationMoto'] ?? {};
    var address = motorcycle['address'] ?? {};

    // Retrieve current user information
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String email = currentUser?.email ?? 'No email available';
    final String userId = currentUser?.uid ?? 'No user ID available';

    // Retrieve motorcycle ID
    final String motorcycleId =
        motorcycle['id'] ?? 'No motorcycle ID available';

    return Scaffold(
      appBar: AppBar(
        title: Text(info['nameMoto'] ?? 'Motorcycle Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show the first image if available
            info['images'] != null && info['images'].isNotEmpty
                ? Image.network(info['images'][0], fit: BoxFit.cover)
                : const SizedBox(height: 10),

            // Motorcycle name
            Text(
              info['nameMoto'] ?? "Motorcycle",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 10),

            // Price
            Text(
              "Price: ${info['price'] ?? "111.000"} /day",
              style: const TextStyle(
                color: Color.fromARGB(255, 253, 101, 20),
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              info['description'] ?? "No description available.",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Energy
            Text(
              "Energy: ${info['energy'] ?? "Unknown"}",
              style: const TextStyle(fontSize: 16),
            ),

            // Vehicle Mass
            Text(
              "Vehicle Mass: ${info['vehicleMass'] ?? "Unknown"} kg",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Number Plate
            Text(
              "Number Plate: ${motorcycle['numberPlate'] ?? 'Unknown'}",
              style: const TextStyle(fontSize: 16),
            ),

            // Company
            Text(
              "Company: ${motorcycle['companyMoto']?['name'] ?? 'Unknown'}",
              style: const TextStyle(fontSize: 16),
            ),

            // Category
            Text(
              "Category: ${motorcycle['category']?['name'] ?? 'Unknown'}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 10),

            // Address
            Text(
              "Address: ${address['streetName'] ?? 'Unknown'}, "
              "${address['district'] ?? 'Unknown'}, "
              "${address['city'] ?? 'Unknown'}, "
              "${address['country'] ?? 'Unknown'}",
              style: const TextStyle(fontSize: 16),
            ),

            // Email (retrieved from Firebase Auth)
            Text(
              "Email: $email",
              style: const TextStyle(fontSize: 16),
            ),

            // User ID (retrieved from Firebase Auth)
            Text(
              "User ID: $userId",
              style: const TextStyle(fontSize: 16),
            ),

            // Motorcycle ID (retrieved from the motorcycle map)
            Text(
              "Motorcycle ID: $motorcycleId",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
