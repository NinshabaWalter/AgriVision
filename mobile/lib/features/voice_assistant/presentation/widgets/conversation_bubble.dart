import 'package:flutter/material.dart';
import '../pages/voice_assistant_page.dart';

class ConversationBubble extends StatelessWidget {
  final VoiceCommand command;

  const ConversationBubble({
    super.key,
    required this.command,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            command.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!command.isUser) _buildAvatar(context),
          if (!command.isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: command.isUser
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16).copyWith(
                  topLeft: command.isUser ? const Radius.circular(16) : const Radius.circular(4),
                  topRight: command.isUser ? const Radius.circular(4) : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    command.text,
                    style: TextStyle(
                      color: command.isUser
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getLanguageIcon(command.language),
                        size: 12,
                        color: command.isUser
                            ? Colors.white.withOpacity(0.7)
                            : Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(command.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: command.isUser
                              ? Colors.white.withOpacity(0.7)
                              : Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (command.isUser) const SizedBox(width: 8),
          if (command.isUser) _buildUserAvatar(context),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      child: Icon(
        Icons.support_agent,
        size: 20,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).primaryColor,
      ),
      child: const Icon(
        Icons.person,
        size: 20,
        color: Colors.white,
      ),
    );
  }

  IconData _getLanguageIcon(String language) {
    switch (language) {
      case 'sw-TZ':
        return Icons.translate;
      case 'am-ET':
        return Icons.translate;
      case 'fr-FR':
        return Icons.translate;
      default:
        return Icons.language;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}