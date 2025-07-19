import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../models/notification.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).fetchNotifications();
    });
  }

  Future<void> _refresh() async {
    await Provider.of<NotificationProvider>(
      context,
      listen: false,
    ).fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notifProvider, _) {
          if (notifProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (notifProvider.error != null) {
            return Center(
              child: Text(
                'Error: ${notifProvider.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (notifProvider.notifications.isEmpty) {
            return const Center(
              child: Text(
                'No notifications yet.',
                style: TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifProvider.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = notifProvider.notifications[index];
                return _NotificationTile(
                  notification: notif,
                  onTap: () async {
                    if (!notif.isRead) {
                      await notifProvider.markAsRead(notif.id);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;
    return Material(
      color: isRead ? Colors.white : const Color(0xFFE3F2FD),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isRead ? Icons.notifications_none : Icons.notifications_active,
                color: isRead ? Colors.grey : const Color(0xFF1565C0),
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        color:
                            isRead ? Colors.grey[800] : const Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: isRead ? Colors.grey[700] : Colors.black,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              if (!isRead)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1565C0),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
