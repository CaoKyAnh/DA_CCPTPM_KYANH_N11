// lib/services/message_service.dart

// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class MessageService {
  // Function to send message to backend
  Future<String> sendMessage(
    String text,
    String email,
    String senderName,
    String userAEmail,
    String userBEmail,
  ) async {
    try {
      // Message data to be sent to the backend
      final Map<String, String> messageData = {
        'text': text,
        'email': email,
        'senderName': senderName,
        'userAEmail': userAEmail,
        'userBEmail': userBEmail,
      };

      // Sending POST request to the backend
      final response = await http.post(
        Uri.parse(
            'http://10.0.2.2:3000/api/messages'), // Replace with your actual backend URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(messageData), // Encode message data to JSON
      );

      // Handling the response from the backend
      if (response.statusCode == 200) {
        return 'Message sent successfully!';
      } else {
        return 'Failed to send message. Please try again.';
      }
    } catch (error) {
      return 'Error: $error';
    }
  }

  Future<Stream<List<Map<String, dynamic>>>> fetchMessages(
      String userAEmail, String userBEmail) async {
    List<String> emails = [userAEmail, userBEmail];
    emails.sort(); // Sorts the emails alphabetically
    String chatId = emails.join('_');

    return FirebaseFirestore.instance
        .collection('chats') // The 'chats' collection
        .doc(chatId) // The document for the specific conversation
        .collection('messages') // The subcollection containing messages
        .orderBy('timestamp') // Sort messages by timestamp
        .snapshots() // Real-time updates from Firestore
        .map((querySnapshot) {
      // Map over the documents and extract the data
      return querySnapshot.docs.map((doc) {
        return {
          'text': doc['text'],
          'senderEmail': doc['senderEmail'],
          'senderName': doc['senderName'],
          'timestamp': doc['timestamp'].toDate(),
          'read': doc['read'],
        };
      }).toList();
    });
  }

  Future<Map<String, String>> fetchSenderDetails(String userEmail) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: userEmail)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final userData = userDoc.data();

        return {
          'name': userData['information']['name'] ?? 'Unknown',
          'avatar': userData['information']['avatar'] ?? '',
        };
      } else {
        return {'name': 'Unknown User', 'avatar': ''}; // Fallback
      }
    } catch (e) {
      print('Error fetching sender details: $e');
      return {'name': 'Unknown User', 'avatar': ''};
    }
  }
}
