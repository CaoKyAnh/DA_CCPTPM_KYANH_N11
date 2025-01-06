// ignore_for_file: unused_field, unused_local_variable

import 'package:flutter/material.dart';
import 'package:final_project_rent_moto_fe/services/messages/messages_service.dart';

class MessagesSender extends StatefulWidget {
  final String email;
  final String senderName;
  final String userAEmail;
  final String userBEmail;

  const MessagesSender({
    super.key,
    required this.email,
    required this.senderName,
    required this.userAEmail,
    required this.userBEmail,
  });

  @override
  _MessagesSenderState createState() => _MessagesSenderState();
}

class _MessagesSenderState extends State<MessagesSender> {
  final TextEditingController _textController = TextEditingController();
  final MessageService messageService = MessageService();

  bool _isLoading = false;
  String _statusMessage = '';
  Map<String, String>? _senderDetails; // Cache for sender details
  Stream<List<Map<String, dynamic>>>? _messagesStream;

  @override
  void initState() {
    super.initState();
    _loadSenderDetails();
    _loadMessagesStream();
  }

  Future<void> _loadSenderDetails() async {
    try {
      final details =
          await messageService.fetchSenderDetails(widget.userBEmail);
      setState(() {
        _senderDetails = details;
      });
    } catch (e) {
      setState(() {
        _senderDetails = null; // Handle errors gracefully
      });
    }
  }

  Future<void> _loadMessagesStream() async {
    // Await the Future to resolve to a Stream and assign it to _messagesStream
    final stream = await messageService.fetchMessages(
      widget.userAEmail,
      widget.userBEmail,
    );
    setState(() {
      _messagesStream = stream;
    });
  }

  Future<void> _sendMessage() async {
    if (_isLoading || _textController.text.isEmpty) return;

    setState(() => _isLoading = true);

    final result = await messageService.sendMessage(
      _textController.text,
      widget.email,
      widget.senderName,
      widget.userAEmail,
      widget.userBEmail,
    );

    setState(() {
      _isLoading = false;
      _statusMessage = result;
      if (result == 'Message sent successfully!') {
        _textController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF49C21),
        title: Row(
          children: [
            if (_senderDetails == null)
              const CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 20,
                child: Icon(Icons.error, color: Colors.white),
              )
            else
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: _senderDetails!['avatar']!.isNotEmpty
                        ? NetworkImage(_senderDetails!['avatar']!)
                        : const AssetImage('assets/images/quan1.png')
                            as ImageProvider,
                    radius: 20,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _senderDetails!['name'] ?? 'Unknown',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: _messagesStream == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _messagesStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final messages = snapshot.data ?? [];
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final senderName = message['senderName']!;
                          final text = message['text']!;
                          final isSender = senderName == widget.senderName;

                          return Align(
                            alignment: isSender
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: isSender
                                    ? const Color(0xFFF49C21)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: isSender ? Colors.white : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          // Input area
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "Nhập nội dung chat vào đây...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.send, color: Color(0xFFF49C21)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
