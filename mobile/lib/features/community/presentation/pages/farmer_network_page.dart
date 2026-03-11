import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/farmer_post.dart';
import '../../data/models/expert_consultation.dart';
import '../providers/community_provider.dart';
import '../widgets/farmer_post_card.dart';
import '../widgets/expert_card.dart';
import '../widgets/success_story_card.dart';

class FarmerNetworkPage extends ConsumerStatefulWidget {
  const FarmerNetworkPage({super.key});

  @override
  ConsumerState<FarmerNetworkPage> createState() => _FarmerNetworkPageState();
}

class _FarmerNetworkPageState extends ConsumerState<FarmerNetworkPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedCategory = 'All';
  String selectedLanguage = 'All Languages';

  final List<String> categories = [
    'All',
    'Crop Management',
    'Livestock',
    'Market Updates',
    'Weather Alerts',
    'Equipment Sharing',
    'Success Stories',
    'Ask Expert',
  ];

  final List<String> languages = [
    'All Languages',
    'English',
    'Swahili',
    'Amharic',
    'French',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final communityState = ref.watch(communityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Network'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Feed', icon: Icon(Icons.home)),
            Tab(text: 'Experts', icon: Icon(Icons.school)),
            Tab(text: 'Stories', icon: Icon(Icons.star)),
            Tab(text: 'Groups', icon: Icon(Icons.group)),
            Tab(text: 'Events', icon: Icon(Icons.event)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildLanguageSelector(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFeedTab(communityState),
                _buildExpertsTab(communityState),
                _buildSuccessStoriesTab(communityState),
                _buildGroupsTab(communityState),
                _buildEventsTab(communityState),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createPost(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.language, size: 20),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: selectedLanguage,
            underline: const SizedBox(),
            items: languages.map((language) {
              return DropdownMenuItem(
                value: language,
                child: Text(language, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => selectedLanguage = value!);
              _filterByLanguage(value!);
            },
          ),
          const Spacer(),
          Wrap(
            spacing: 8,
            children: categories.take(4).map((category) {
              final isSelected = category == selectedCategory;
              return FilterChip(
                label: Text(
                  category,
                  style: TextStyle(fontSize: 12),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => selectedCategory = category);
                  _filterByCategory(category);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedTab(CommunityState communityState) {
    return RefreshIndicator(
      onRefresh: () => _refreshFeed(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: communityState.posts.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCreatePostCard();
          }
          
          final post = communityState.posts[index - 1];
          return FarmerPostCard(
            post: post,
            onLike: () => _likePost(post.id),
            onComment: () => _showComments(post),
            onShare: () => _sharePost(post),
            onTranslate: () => _translatePost(post),
          );
        },
      ),
    );
  }

  Widget _buildCreatePostCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share with the community',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _createPost(),
                    icon: const Icon(Icons.camera_alt, size: 20),
                    label: const Text('Share Update'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _askQuestion(),
                    icon: const Icon(Icons.help_outline, size: 20),
                    label: const Text('Ask Question'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildQuickActionChip('Crop Disease', Icons.bug_report, Colors.red),
                _buildQuickActionChip('Market Price', Icons.trending_up, Colors.green),
                _buildQuickActionChip('Weather Alert', Icons.wb_sunny, Colors.orange),
                _buildQuickActionChip('Equipment Share', Icons.build, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(String label, IconData icon, Color color) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () => _createPostWithCategory(label),
    );
  }

  Widget _buildExpertsTab(CommunityState communityState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExpertServicesCard(),
          const SizedBox(height: 16),
          const Text(
            'Available Agricultural Experts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...communityState.experts.map((expert) => ExpertCard(
                expert: expert,
                onConsult: () => _consultExpert(expert),
                onViewProfile: () => _viewExpertProfile(expert),
              )),
          if (communityState.experts.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No experts available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Check back later for expert consultations',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpertServicesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.support_agent, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Expert Consultation Services',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Get professional advice from agricultural extension officers and certified experts.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildServiceItem(
                    'Free Consultation',
                    'Basic farming advice',
                    Icons.free_breakfast,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildServiceItem(
                    'Video Call',
                    'Premium consultation',
                    Icons.video_call,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildServiceItem(
                    'Field Visit',
                    'On-farm consultation',
                    Icons.location_on,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildServiceItem(
                    '24/7 Hotline',
                    'Emergency support',
                    Icons.phone,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(String title, String subtitle, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuccessStoriesTab(CommunityState communityState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSuccessStoriesHeader(),
          const SizedBox(height: 16),
          ...communityState.successStories.map((story) => SuccessStoryCard(
                story: story,
                onShare: () => _shareSuccessStory(story),
                onReadMore: () => _viewFullStory(story),
              )),
          if (communityState.successStories.isEmpty)
            _buildEmptySuccessStories(),
        ],
      ),
    );
  }

  Widget _buildSuccessStoriesHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Success Stories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Learn from fellow farmers who have achieved remarkable results using modern agricultural practices.',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _shareMyStory(),
                icon: const Icon(Icons.share),
                label: const Text('Share Your Success Story'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySuccessStories() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.star_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No success stories yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to share your farming success!',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _shareMyStory(),
              child: const Text('Share Your Story'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsTab(CommunityState communityState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCooperativeManagementCard(),
          const SizedBox(height: 16),
          _buildMyGroupsSection(),
          const SizedBox(height: 16),
          _buildAvailableGroupsSection(),
        ],
      ),
    );
  }

  Widget _buildCooperativeManagementCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.group_work, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Cooperative Management',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Manage your farming cooperatives, share resources, and coordinate group activities.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _createGroup(),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Group'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _findGroups(),
                    icon: const Icon(Icons.search),
                    label: const Text('Find Groups'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyGroupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Groups',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildGroupCard(
          'Kiambu Coffee Farmers',
          '45 members',
          'Active discussion about harvest season',
          Icons.coffee,
          Colors.brown,
        ),
        _buildGroupCard(
          'Maize Growers Association',
          '128 members',
          'Planning bulk seed purchase',
          Icons.agriculture,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildAvailableGroupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended Groups',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildGroupCard(
          'Organic Farming Network',
          '267 members',
          'Join to learn about organic certification',
          Icons.eco,
          Colors.green,
          isJoined: false,
        ),
        _buildGroupCard(
          'Dairy Farmers Union',
          '89 members',
          'Share best practices for dairy farming',
          Icons.local_drink,
          Colors.blue,
          isJoined: false,
        ),
      ],
    );
  }

  Widget _buildGroupCard(
    String name,
    String memberCount,
    String description,
    IconData icon,
    Color color, {
    bool isJoined = true,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    memberCount,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: isJoined ? () => _viewGroup(name) : () => _joinGroup(name),
              child: Text(isJoined ? 'View' : 'Join'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsTab(CommunityState communityState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUpcomingEventsSection(),
          const SizedBox(height: 16),
          _buildTrainingEventsSection(),
          const SizedBox(height: 16),
          _buildMarketEventsSection(),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Events',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildEventCard(
          'Coffee Harvest Festival',
          'Dec 15, 2024',
          'Kiambu County',
          'Celebrate the coffee harvest season with fellow farmers',
          Icons.celebration,
          Colors.brown,
        ),
        _buildEventCard(
          'Modern Farming Techniques Workshop',
          'Dec 20, 2024',
          'Nairobi',
          'Learn about precision agriculture and smart farming',
          Icons.school,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildTrainingEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Training & Workshops',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildEventCard(
          'Crop Disease Management',
          'Dec 18, 2024',
          'Online',
          'Free training on identifying and treating crop diseases',
          Icons.medical_services,
          Colors.red,
        ),
        _buildEventCard(
          'Financial Literacy for Farmers',
          'Dec 22, 2024',
          'Mombasa',
          'Learn about agricultural loans and insurance',
          Icons.account_balance,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildMarketEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Market Events',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildEventCard(
          'Agricultural Trade Fair',
          'Jan 5-7, 2025',
          'Nakuru',
          'Connect with buyers and suppliers',
          Icons.store,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildEventCard(
    String title,
    String date,
    String location,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(location, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _shareEvent(title),
                    child: const Text('Share'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _registerForEvent(title),
                    child: const Text('Register'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Event handlers
  void _showFilterDialog() {
    // TODO: Implement filter dialog
  }

  void _showSearchDialog() {
    // TODO: Implement search dialog
  }

  void _createPost() {
    // TODO: Navigate to create post page
  }

  void _createPostWithCategory(String category) {
    // TODO: Navigate to create post page with category
  }

  void _askQuestion() {
    // TODO: Navigate to ask question page
  }

  Future<void> _refreshFeed() async {
    await ref.read(communityProvider.notifier).refreshFeed();
  }

  void _filterByLanguage(String language) {
    ref.read(communityProvider.notifier).filterByLanguage(language);
  }

  void _filterByCategory(String category) {
    ref.read(communityProvider.notifier).filterByCategory(category);
  }

  void _likePost(String postId) {
    ref.read(communityProvider.notifier).likePost(postId);
  }

  void _showComments(FarmerPost post) {
    // TODO: Show comments dialog
  }

  void _sharePost(FarmerPost post) {
    // TODO: Implement share functionality
  }

  void _translatePost(FarmerPost post) {
    // TODO: Implement translation
  }

  void _consultExpert(dynamic expert) {
    // TODO: Navigate to expert consultation page
  }

  void _viewExpertProfile(dynamic expert) {
    // TODO: Navigate to expert profile page
  }

  void _shareSuccessStory(dynamic story) {
    // TODO: Implement share functionality
  }

  void _viewFullStory(dynamic story) {
    // TODO: Navigate to full story page
  }

  void _shareMyStory() {
    // TODO: Navigate to share story page
  }

  void _createGroup() {
    // TODO: Navigate to create group page
  }

  void _findGroups() {
    // TODO: Navigate to find groups page
  }

  void _viewGroup(String groupName) {
    // TODO: Navigate to group page
  }

  void _joinGroup(String groupName) {
    // TODO: Join group functionality
  }

  void _shareEvent(String eventTitle) {
    // TODO: Implement share event
  }

  void _registerForEvent(String eventTitle) {
    // TODO: Navigate to event registration
  }
}