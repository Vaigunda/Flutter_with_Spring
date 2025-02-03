import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';
import '../../shared/models/chat.model.dart';

class ChatBox {
  static OverlayEntry? _chatOverlay;
  final List<ChatMessage> _messages = [];
  late String userType;
  late String usertoken;
  var provider;

  static bool isChatBoxOpen = false;

  TextEditingController? _chatController;
  ScrollController? _scrollController;

  void openChatBox(BuildContext context, int userId, int mentorId, List<ChatMessage> messages, List<ChatMessage> unreadMessages) {
    if (_chatOverlay != null) return;

    isChatBoxOpen = true;

    provider = context.read<UserDataProvider>();
    userType = provider.usertype;
    usertoken = provider.usertoken;

    _messages.addAll(messages);

    _chatController = TextEditingController();
    _scrollController = ScrollController();

    _chatOverlay = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Positioned(
          right: 20,
          bottom: 50,
          child: _buildChatPanel(userId, mentorId, setState),
        ),
      ),
    );

    Overlay.of(context).insert(_chatOverlay!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    for (var message in unreadMessages) {
      markMessagesAsRead(message.senderId, message.recipientId);
    }
  }

  Widget _buildChatPanel(int userId, int mentorId, void Function(void Function()) setState) {
    final FocusNode rawKeyboardFocusNode = FocusNode();
    final FocusNode textFieldFocusNode = FocusNode();

    Future<void> handleEnterKey(RawKeyEvent event) async {
      if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
        await _sendMessage(_chatController!.text, userId, mentorId, () {
          if (_chatOverlay != null) {
            setState(() {});
          }
        });
        _chatController!.clear();
        _scrollToBottom();
        textFieldFocusNode.requestFocus();
      }
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Chat", style: TextStyle(color: Colors.white, fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: closeChatBox,
                  ),
                ],
              ),
            ),

            // Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  bool isSender = (userType == "Mentor")
                      ? _messages[index].senderId == mentorId
                      : _messages[index].senderId == userId;

                  return _chatBubble(_messages[index].content, isSender);
                },
              ),
            ),

            // Message Input Field
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: RawKeyboardListener(
                focusNode: rawKeyboardFocusNode,
                onKey: handleEnterKey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        focusNode: textFieldFocusNode,
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.black),
                      onPressed: () async {
                        await _sendMessage(_chatController!.text, userId, mentorId, () {
                          if (_chatOverlay != null) {
                            setState(() {});
                          }
                        });
                        _chatController!.clear();
                        _scrollToBottom();
                      },
                      tooltip: 'Send Message',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Smooth Scrolling to Bottom
  void _scrollToBottom() {
    if (_scrollController?.hasClients ?? false) {
      _scrollController!.animateTo(
        _scrollController!.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Chat Bubble Widget
  Widget _chatBubble(String message, bool isSender) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSender ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isSender ? const Radius.circular(12) : const Radius.circular(0),
            bottomRight: isSender ? const Radius.circular(0) : const Radius.circular(12),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(color: isSender ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  // Send Message with `mounted` check
  Future<void> _sendMessage(String chatMessage, int userId, int mentorId, VoidCallback updateUI) async {
    if (chatMessage.isEmpty) return;

    final requestBody = jsonEncode({
      'senderId': (userType == 'Mentor') ? mentorId : userId,
      'recipientId': (userType == 'Mentor') ? userId : mentorId,
      'content': chatMessage,
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/chat/send'),
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer $usertoken',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        var parsed = jsonDecode(response.body);
        _messages.add(ChatMessage(
          id: parsed['id'],
          senderId: parsed['senderId'],
          recipientId: parsed['recipientId'],
          content: parsed['content'],
          read: parsed['read'],
          timestamp: parsed['timestamp'],
        ));

        if (_chatOverlay != null) {
          updateUI();
        }
      }
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  // Close Chat Box
  void closeChatBox() {
    _chatOverlay?.remove();
    _chatOverlay = null;
    _chatController?.dispose();
    _scrollController?.dispose();

    isChatBoxOpen = false;
  }

  // Mark Messages as Read
  Future<void> markMessagesAsRead(int senderId, int recipientId) async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/chat/markAsRead/$senderId/$recipientId'),
      headers: {
        'Authorization': 'Bearer $usertoken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to mark messages as read");
    }
  }
}
