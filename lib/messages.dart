import 'dart:async';  // For Timer
import 'dart:convert';
import 'package:flutter/foundation.dart'; // for mapEquals if needed later
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';    // Your constants file with baseUrl
import 'user_session.dart'; // Your user session handler

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  List<dynamic> _allUsers = [];
  List<dynamic> _filteredUsers = [];
  bool _isLoading = true;
  String? _error;
  String _searchTerm = '';

  final TextEditingController _searchController = TextEditingController();

  Map<int, int> _unreadCounts = {}; // userId -> unread count

  Timer? _unreadTimer;

  @override
  void initState() {
    super.initState();
    fetchUsers().then((_) {
      fetchUnreadCounts(); // fetch unread counts after users loaded
    });

    // Fetch unread counts every 5 seconds
    _unreadTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchUnreadCounts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _unreadTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_users.php'));
      if (response.statusCode == 200) {
        _allUsers = jsonDecode(response.body);
        _applySearch();
        setState(() => _isLoading = false);
      } else {
        setState(() {
          _error = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load users';
        _isLoading = false;
      });
    }
  }

  void _applySearch() {
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final fullname = (user['fullname'] ?? '').toString().toLowerCase();
        final phone = (user['phone'] ?? '').toString().toLowerCase();
        return fullname.contains(_searchTerm) || phone.contains(_searchTerm);
      }).toList();
    });
  }

  void _onSearchChanged(String value) {
    _searchTerm = value.trim().toLowerCase();
    _applySearch();
  }

  Future<void> fetchUnreadCounts() async {
    final session = UserSession();
    await session.loadFromPrefs();
    final currentUserId = session.userId;
    if (currentUserId == null) return;

    try {
      final response = await http.get(Uri.parse('$baseUrl/get_unread_counts.php?user_id=$currentUserId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final newCounts = data.map<int, int>((key, value) =>
            MapEntry(int.parse(key), int.parse(value.toString())));

        // Optional: only update state if counts changed
        if (!mapEquals(_unreadCounts, newCounts)) {
          setState(() {
            _unreadCounts = newCounts;
          });
        }
      }
    } catch (e) {
      // Could log or ignore errors silently
    }
  }

  void _openChat(dynamic user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(user: user),
      ),
    );
    // After returning from chat, refresh unread counts from server
    fetchUnreadCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2B6D),
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: const Color(0xFF1E2B6D),
        foregroundColor: const Color(0xFFF65A06),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search users by name or phone',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
              child:
              CircularProgressIndicator(color: Color(0xFFF65A06)),
            )
                : _error != null
                ? Center(
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.white),
              ),
            )
                : _filteredUsers.isEmpty
                ? const Center(
              child: Text(
                'No users found',
                style: TextStyle(color: Colors.white70),
              ),
            )
                : ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                final unreadCount =
                    _unreadCounts[user['id']] ?? 0;
                return Card(
                  color: const Color(0xFF2C3E91),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFF65A06)
                              .withOpacity(0.15),
                          child: Text(
                            (user['fullname'] != null &&
                                user['fullname'].isNotEmpty)
                                ? user['fullname'][0]
                                .toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: Colors.white),
                          ),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF2C3E91),
                                  width: 2,
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 22,
                                minHeight: 22,
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                      ],
                    ),
                    title: Text(
                      user['fullname'] ?? '',
                      style:
                      const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      user['phone'] ?? '',
                      style: const TextStyle(
                          color: Colors.white70),
                    ),
                    onTap: () => _openChat(user),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final dynamic user;
  const ChatPage({super.key, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  String? _error;

  int? currentUserId;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchMessages();

    markMessagesRead();

    // Auto-refresh every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchMessages();
    });
  }

  Future<void> _loadUserAndFetchMessages() async {
    final session = UserSession();
    await session.loadFromPrefs();

    if (!mounted) return;
    setState(() {
      currentUserId = session.userId;
    });

    if (currentUserId != null) {
      await fetchMessages();
    } else {
      setState(() {
        _error = 'User not logged in';
        _isLoading = false;
      });
    }
  }

  Future<void> fetchMessages() async {
    if (currentUserId == null) return;

    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/get_messages.php?user1=$currentUserId&user2=${widget.user['id']}'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final messages = data.map<Map<String, dynamic>>((msg) {
          return {
            'sender_id': int.parse(msg['from_id'].toString()),
            'receiver_id': int.parse(msg['to_id'].toString()),
            'text': msg['message'].toString(),
            'timestamp': msg['timestamp'].toString(),
          };
        }).toList();

        messages.sort((a, b) =>
            DateTime.parse(a['timestamp']).compareTo(DateTime.parse(b['timestamp'])));

        setState(() {
          _messages = messages;
          _isLoading = false;
          _error = null;
        });

        _scrollToBottom();
      } else {
        setState(() {
          _error = 'Error loading messages: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load messages: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> markMessagesRead() async {
    final session = UserSession();
    await session.loadFromPrefs();
    final currentUserId = session.userId;
    if (currentUserId == null) return;

    try {
      await http.post(
        Uri.parse('$baseUrl/mark_read.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user1': currentUserId,
          'user2': widget.user['id'],
        }),
      );
    } catch (e) {
      // ignore errors silently
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || currentUserId == null) return;

    final senderId = currentUserId!;
    final receiverId = widget.user['id'];

    final body = jsonEncode({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': text,
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send_message.php'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          _messages.add({
            'sender_id': senderId,
            'text': text,
            'timestamp': DateTime.now().toIso8601String(),
          });
          _messageController.clear();
        });

        _scrollToBottom();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sending message')),
      );
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isMe = msg['sender_id'] == currentUserId;
    final timestamp = msg['timestamp'];

    String formattedDateTime = '';
    try {
      final dt = DateTime.parse(timestamp);
      final now = DateTime.now();

      bool sameDay = dt.year == now.year && dt.month == now.month && dt.day == now.day;

      String timeString =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

      if (sameDay) {
        formattedDateTime = timeString;
      } else {
        String dateString =
            '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
        formattedDateTime = '$dateString, $timeString';
      }
    } catch (e) {
      formattedDateTime = '';
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: EdgeInsets.only(
          top: 6,
          bottom: 6,
          left: isMe ? 40 : 12,
          right: isMe ? 12 : 40,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFFF65A06)
              : const Color(0xFF2C3E91),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg['text'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              formattedDateTime,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user['fullname'] ?? 'Chat'),
        backgroundColor: const Color(0xFF1E2B6D),
        foregroundColor: const Color(0xFFF65A06),
      ),
      backgroundColor: const Color(0xFF1E2B6D),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF65A06)),
            )
                : _error != null
                ? Center(
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.white),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          Container(
            color: const Color(0xFF2C3E91),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFFF65A06)),
                    onPressed: _sendMessage,
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
