import 'package:flutter/material.dart';

class NotificationsWidget extends StatelessWidget {
  const NotificationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Weather Alert',
        'message': 'Heavy rains expected tomorrow. Postpone spraying activities.',
        'type': 'warning',
        'time': '10 minutes ago',
        'isUrgent': true,
      },
      {
        'title': 'Market Update',
        'message': 'Coffee prices increased by 12% - good time to sell',
        'type': 'info',
        'time': '2 hours ago',
        'isUrgent': false,
      },
      {
        'title': 'Payment Reminder',
        'message': 'Loan payment due in 3 days - KES 15,000',
        'type': 'reminder',
        'time': '1 day ago',
        'isUrgent': false,
      },
    ];

    final urgentNotifications = notifications.where((n) => n['isUrgent'] == true).toList();
    final regularNotifications = notifications.where((n) => n['isUrgent'] != true).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Urgent notifications
        if (urgentNotifications.isNotEmpty) ...[
          ...urgentNotifications.map((notification) => _buildUrgentNotification(
                context,
                notification['title'] as String,
                notification['message'] as String,
                notification['type'] as String,
                notification['time'] as String,
              )),
          const SizedBox(height: 12),
        ],
        
        // Regular notifications summary
        if (regularNotifications.isNotEmpty)
          _buildNotificationsSummary(context, regularNotifications),
      ],
    );
  }

  Widget _buildUrgentNotification(
    BuildContext context,
    String title,
    String message,
    String type,
    String time,
  ) {
    final color = _getNotificationColor(type);
    final icon = _getNotificationIcon(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'URGENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _dismissNotification(context, title),
            icon: Icon(
              Icons.close,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSummary(
    BuildContext context,
    List<Map<String, dynamic>> notifications,
  ) {
    return Card(
      child: InkWell(
        onTap: () => _showAllNotifications(context, notifications),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  Icon(
                    Icons.notifications,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  if (notifications.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          notifications.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${notifications.length} notifications',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Market updates, reminders, and more',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'warning':
        return Colors.amber;
      case 'error':
        return Colors.red;
      case 'success':
        return Colors.green;
      case 'info':
        return Colors.blue;
      case 'reminder':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'success':
        return Icons.check_circle;
      case 'info':
        return Icons.info;
      case 'reminder':
        return Icons.schedule;
      default:
        return Icons.notifications;
    }
  }

  void _dismissNotification(BuildContext context, String title) {
    // TODO: Implement notification dismissal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dismissed: $title'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAllNotifications(
    BuildContext context,
    List<Map<String, dynamic>> notifications,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'All Notifications',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationItem(
                      notification['title'] as String,
                      notification['message'] as String,
                      notification['type'] as String,
                      notification['time'] as String,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String message,
    String type,
    String time,
  ) {
    final color = _getNotificationColor(type);
    final icon = _getNotificationIcon(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}