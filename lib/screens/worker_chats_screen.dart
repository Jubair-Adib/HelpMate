import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'chat_screen.dart';

class WorkerChatsScreen extends StatefulWidget {
  const WorkerChatsScreen({Key? key}) : super(key: key);

  @override
  State<WorkerChatsScreen> createState() => _WorkerChatsScreenState();
}

class _WorkerChatsScreenState extends State<WorkerChatsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _chats = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final chats = await _apiService.getWorkerChats();
      setState(() {
        _chats = chats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats with Clients')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : _chats.isEmpty
              ? const Center(child: Text('No chats found'))
              : ListView.separated(
                itemCount: _chats.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  final user = chat['user'];
                  final lastMessage = chat['last_message'];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text((user?['full_name'] ?? 'U')[0]),
                    ),
                    title: Text(user?['full_name'] ?? 'Unknown User'),
                    subtitle:
                        lastMessage != null
                            ? Text(lastMessage['content'] ?? '')
                            : const Text('No messages yet'),
                    trailing:
                        chat['unread_count'] > 0
                            ? CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Text(
                                chat['unread_count'].toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            )
                            : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ChatScreen(
                                chatId: chat['id'],
                                workerName: user?['full_name'] ?? 'User',
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
