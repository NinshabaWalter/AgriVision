import 'package:flutter/material.dart';

class ExpertConsultationPage extends StatefulWidget {
  const ExpertConsultationPage({super.key});

  @override
  State<ExpertConsultationPage> createState() => _ExpertConsultationPageState();
}

class _ExpertConsultationPageState extends State<ExpertConsultationPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  String _selectedLanguage = 'English';

  final List<String> _categories = ['All', 'Crop Diseases', 'Soil Health', 'Pest Control', 'Market Advice', 'Financial'];
  final List<String> _languages = ['English', 'Swahili', 'Amharic', 'French'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expert Consultation'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: _scheduleVideoCall,
          ),
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: _callHelpline,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Experts', icon: Icon(Icons.person)),
            Tab(text: 'Q&A', icon: Icon(Icons.question_answer)),
            Tab(text: 'Sessions', icon: Icon(Icons.video_call)),
            Tab(text: 'Resources', icon: Icon(Icons.library_books)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExpertsTab(),
                _buildQATab(),
                _buildSessionsTab(),
                _buildResourcesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _askQuestion,
        icon: const Icon(Icons.help),
        label: const Text('Ask Question'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _categories.map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              )).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: const InputDecoration(
                labelText: 'Language',
                prefixIcon: Icon(Icons.language),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _languages.map((language) => DropdownMenuItem(
                value: language,
                child: Text(language),
              )).toList(),
              onChanged: (value) => setState(() => _selectedLanguage = value!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertsTab() {
    final experts = _getExperts();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: experts.length,
      itemBuilder: (context, index) {
        final expert = experts[index];
        return _buildExpertCard(expert);
      },
    );
  }

  Widget _buildExpertCard(Map<String, dynamic> expert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.teal.shade100,
                  child: Text(
                    expert['name'][0],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expert['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        expert['title'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        expert['organization'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          expert['rating'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      '${expert['consultations']} sessions',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              expert['bio'],
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: expert['specialties'].map<Widget>((specialty) => Chip(
                label: Text(
                  specialty,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.teal.shade50,
                labelStyle: TextStyle(color: Colors.teal.shade700),
              )).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _sendMessage(expert),
                    icon: const Icon(Icons.message, size: 16),
                    label: const Text('Message'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _bookConsultation(expert),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: const Text('Book Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (expert['availability'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.green.shade700, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Available: ${expert['availability']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQATab() {
    final questions = _getQuestions();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        return _buildQuestionCard(question);
      },
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    question['askedBy'][0],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question['askedBy'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        question['date'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(question['category']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    question['category'],
                    style: TextStyle(
                      fontSize: 10,
                      color: _getCategoryColor(question['category']),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question['title'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              question['description'],
              style: const TextStyle(fontSize: 14),
            ),
            if (question['images'] != null && question['images'].isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: question['images'].length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.image,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.thumb_up, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  question['likes'].toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.comment, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${question['answers']} answers',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _viewQuestion(question),
                  child: const Text('View Answers'),
                ),
              ],
            ),
            if (question['expertAnswer'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified, color: Colors.green.shade700, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Expert Answer by ${question['expertAnswer']['expert']}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question['expertAnswer']['answer'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsTab() {
    final sessions = _getSessions();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _buildSessionCard(session);
      },
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final isUpcoming = session['status'] == 'upcoming';
    final statusColor = _getStatusColor(session['status']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getSessionIcon(session['type']),
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'with ${session['expert']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    session['status'].toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  session['date'],
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  session['time'],
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 16),
                Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  '${session['duration']} min',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            if (session['topic'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Topic: ${session['topic']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (isUpcoming) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rescheduleSession(session),
                      icon: const Icon(Icons.schedule, size: 16),
                      label: const Text('Reschedule'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _joinSession(session),
                      icon: const Icon(Icons.video_call, size: 16),
                      label: const Text('Join'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewSessionNotes(session),
                      icon: const Icon(Icons.notes, size: 16),
                      label: const Text('View Notes'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rateSession(session),
                      icon: const Icon(Icons.star, size: 16),
                      label: const Text('Rate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesTab() {
    final resources = _getResources();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return _buildResourceCard(resource);
      },
    );
  }

  Widget _buildResourceCard(Map<String, dynamic> resource) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: resource['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                resource['icon'],
                color: resource['color'],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    resource['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.download, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${resource['downloads']} downloads',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        resource['rating'].toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () => _downloadResource(resource),
                  icon: const Icon(Icons.download),
                  color: Colors.teal,
                ),
                Text(
                  resource['size'],
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'crop diseases':
        return Colors.red;
      case 'soil health':
        return Colors.brown;
      case 'pest control':
        return Colors.orange;
      case 'market advice':
        return Colors.green;
      case 'financial':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getSessionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.video_call;
      case 'phone':
        return Icons.phone;
      case 'chat':
        return Icons.chat;
      default:
        return Icons.help;
    }
  }

  List<Map<String, dynamic>> _getExperts() {
    return [
      {
        'name': 'Dr. Sarah Wanjiku',
        'title': 'Senior Agricultural Extension Officer',
        'organization': 'Kenya Agricultural Research Institute',
        'rating': 4.9,
        'consultations': 245,
        'bio': 'Specialist in crop diseases and sustainable farming practices with 15 years of experience in East African agriculture.',
        'specialties': ['Crop Diseases', 'Organic Farming', 'Soil Health'],
        'availability': 'Mon-Fri 9AM-5PM',
      },
      {
        'name': 'Prof. John Mwangi',
        'title': 'Agricultural Economist',
        'organization': 'University of Nairobi',
        'rating': 4.8,
        'consultations': 189,
        'bio': 'Expert in agricultural markets, value chains, and financial planning for smallholder farmers.',
        'specialties': ['Market Analysis', 'Financial Planning', 'Value Chains'],
        'availability': 'Tue, Thu 2PM-6PM',
      },
      {
        'name': 'Dr. Amina Hassan',
        'title': 'Soil Scientist',
        'organization': 'International Centre for Tropical Agriculture',
        'rating': 4.7,
        'consultations': 156,
        'bio': 'Soil fertility and nutrient management specialist focusing on sustainable intensification.',
        'specialties': ['Soil Testing', 'Fertilizer Management', 'Climate Adaptation'],
        'availability': 'Wed, Fri 10AM-4PM',
      },
    ];
  }

  List<Map<String, dynamic>> _getQuestions() {
    return [
      {
        'title': 'Black spots on my maize leaves - what could this be?',
        'description': 'I noticed black spots appearing on the leaves of my maize crop. The spots are small and circular. What disease could this be and how should I treat it?',
        'askedBy': 'Peter Kimani',
        'date': '2 hours ago',
        'category': 'Crop Diseases',
        'likes': 12,
        'answers': 3,
        'images': ['image1.jpg', 'image2.jpg'],
        'expertAnswer': {
          'expert': 'Dr. Sarah Wanjiku',
          'answer': 'Based on your description, this appears to be Northern Corn Leaf Blight. Apply a copper-based fungicide and ensure proper spacing for air circulation.',
        },
      },
      {
        'title': 'Best time to plant coffee in Central Kenya?',
        'description': 'I want to establish a new coffee plantation. When is the optimal planting time considering the current weather patterns?',
        'askedBy': 'Mary Njeri',
        'date': '1 day ago',
        'category': 'Market Advice',
        'likes': 8,
        'answers': 5,
        'images': null,
        'expertAnswer': null,
      },
      {
        'title': 'Soil pH too low - how to improve it naturally?',
        'description': 'My soil test shows pH of 4.5. What natural methods can I use to raise the pH for better crop growth?',
        'askedBy': 'James Ochieng',
        'date': '3 days ago',
        'category': 'Soil Health',
        'likes': 15,
        'answers': 7,
        'images': ['soil_test.jpg'],
        'expertAnswer': {
          'expert': 'Dr. Amina Hassan',
          'answer': 'Apply agricultural lime at 2-3 tons per hectare. Also consider adding organic matter like compost to gradually improve soil pH.',
        },
      },
    ];
  }

  List<Map<String, dynamic>> _getSessions() {
    return [
      {
        'title': 'Crop Disease Diagnosis',
        'expert': 'Dr. Sarah Wanjiku',
        'date': 'Dec 18, 2024',
        'time': '2:00 PM',
        'duration': 30,
        'type': 'video',
        'status': 'upcoming',
        'topic': 'Identifying and treating maize diseases',
      },
      {
        'title': 'Market Price Analysis',
        'expert': 'Prof. John Mwangi',
        'date': 'Dec 15, 2024',
        'time': '10:00 AM',
        'duration': 45,
        'type': 'video',
        'status': 'completed',
        'topic': 'Coffee market trends and pricing strategies',
      },
      {
        'title': 'Soil Testing Results Review',
        'expert': 'Dr. Amina Hassan',
        'date': 'Dec 12, 2024',
        'time': '3:30 PM',
        'duration': 30,
        'type': 'phone',
        'status': 'completed',
        'topic': 'Interpreting soil test results and recommendations',
      },
    ];
  }

  List<Map<String, dynamic>> _getResources() {
    return [
      {
        'title': 'Crop Disease Identification Guide',
        'description': 'Comprehensive guide with photos of common East African crop diseases',
        'downloads': 1250,
        'rating': 4.8,
        'size': '15 MB',
        'icon': Icons.book,
        'color': Colors.red,
      },
      {
        'title': 'Soil Testing Manual',
        'description': 'Step-by-step guide for soil sampling and interpretation',
        'downloads': 890,
        'rating': 4.6,
        'size': '8 MB',
        'icon': Icons.science,
        'color': Colors.brown,
      },
      {
        'title': 'Market Price Calendar',
        'description': 'Seasonal price patterns for major crops in East Africa',
        'downloads': 2100,
        'rating': 4.9,
        'size': '3 MB',
        'icon': Icons.calendar_today,
        'color': Colors.green,
      },
      {
        'title': 'Organic Farming Practices',
        'description': 'Best practices for sustainable and organic farming',
        'downloads': 1680,
        'rating': 4.7,
        'size': '12 MB',
        'icon': Icons.eco,
        'color': Colors.green,
      },
    ];
  }

  void _scheduleVideoCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening video call scheduler...'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _callHelpline() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calling agricultural helpline...'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _askQuestion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ask a Question'),
        content: const Text('Question submission form would be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _sendMessage(Map<String, dynamic> expert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with ${expert['name']}...'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _bookConsultation(Map<String, dynamic> expert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking consultation with ${expert['name']}...'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _viewQuestion(Map<String, dynamic> question) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening question: ${question['title']}'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _rescheduleSession(Map<String, dynamic> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rescheduling session: ${session['title']}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _joinSession(Map<String, dynamic> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joining session: ${session['title']}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _viewSessionNotes(Map<String, dynamic> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing notes for: ${session['title']}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _rateSession(Map<String, dynamic> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rating session: ${session['title']}'),
        backgroundColor: Colors.amber,
      ),
    );
  }

  void _downloadResource(Map<String, dynamic> resource) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading: ${resource['title']}'),
        backgroundColor: Colors.teal,
      ),
    );
  }
}