import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AIInsightsCard extends ConsumerWidget {
  const AIInsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = [
      {
        'title': 'Optimal Planting Window',
        'description': 'Based on weather patterns, plant your short-season maize between Dec 15-25 for maximum yield.',
        'type': 'weather',
        'priority': 'high',
        'action': 'Plan Planting',
      },
      {
        'title': 'Market Opportunity',
        'description': 'Coffee prices are expected to rise 15% next month. Consider holding your harvest.',
        'type': 'market',
        'priority': 'medium',
        'action': 'View Prices',
      },
      {
        'title': 'Disease Risk Alert',
        'description': 'Bacterial blight risk is high this week. Apply preventive copper-based fungicide.',
        'type': 'disease',
        'priority': 'high',
        'action': 'Get Treatment',
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: Colors.purple.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'AI-Powered Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${insights.length} insights',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...insights.take(2).map((insight) => _buildInsightItem(
                  context,
                  insight['title'] as String,
                  insight['description'] as String,
                  insight['type'] as String,
                  insight['priority'] as String,
                  insight['action'] as String,
                )),
            if (insights.length > 2) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () => _showAllInsights(context, insights),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: Text('View ${insights.length - 2} more insights'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
    BuildContext context,
    String title,
    String description,
    String type,
    String priority,
    String action,
  ) {
    final color = _getInsightColor(type);
    final priorityColor = _getPriorityColor(priority);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: priorityColor.withOpacity(0.3),
          width: priority == 'high' ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getInsightIcon(type),
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  priority.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => _handleInsightAction(context, type, action),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                action,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getInsightColor(String type) {
    switch (type) {
      case 'weather':
        return Colors.blue;
      case 'market':
        return Colors.green;
      case 'disease':
        return Colors.red;
      case 'soil':
        return Colors.brown;
      case 'finance':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getInsightIcon(String type) {
    switch (type) {
      case 'weather':
        return Icons.wb_sunny;
      case 'market':
        return Icons.trending_up;
      case 'disease':
        return Icons.bug_report;
      case 'soil':
        return Icons.landscape;
      case 'finance':
        return Icons.account_balance;
      default:
        return Icons.lightbulb;
    }
  }

  void _handleInsightAction(BuildContext context, String type, String action) {
    // TODO: Navigate to appropriate page based on insight type
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $action for $type insight'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAllInsights(BuildContext context, List<Map<String, String>> insights) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'All AI Insights',
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
                  itemCount: insights.length,
                  itemBuilder: (context, index) {
                    final insight = insights[index];
                    return _buildInsightItem(
                      context,
                      insight['title'] as String,
                      insight['description'] as String,
                      insight['type'] as String,
                      insight['priority'] as String,
                      insight['action'] as String,
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
}