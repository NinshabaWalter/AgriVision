import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/marketplace_item.dart';
import '../widgets/crop_listing_card.dart';
import '../widgets/buyer_connection_card.dart';
import '../widgets/price_trend_chart.dart';
import '../providers/marketplace_providers.dart';
import 'marketplace_item_details_page.dart';
import 'create_listing_dialog.dart';

class MarketplacePage extends ConsumerStatefulWidget {
  const MarketplacePage({super.key});

  @override
  ConsumerState<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends ConsumerState<MarketplacePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedLocation = 'Nairobi, Kenya';
  String selectedCrop = 'All Crops';

  final List<String> locations = [
    'Nairobi, Kenya',
    'Kampala, Uganda',
    'Dar es Salaam, Tanzania',
    'Addis Ababa, Ethiopia',
    'Kigali, Rwanda',
  ];

  final List<String> crops = [
    'All Crops',
    'Maize',
    'Beans',
    'Coffee',
    'Tea',
    'Bananas',
    'Cassava',
    'Sweet Potatoes',
    'Rice',
  ];

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
        title: const Text('Marketplace'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Buy', icon: Icon(Icons.shopping_cart)),
            Tab(text: 'Sell', icon: Icon(Icons.store)),
            Tab(text: 'Prices', icon: Icon(Icons.trending_up)),
            Tab(text: 'Transport', icon: Icon(Icons.local_shipping)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          _buildLocationAndCropSelector(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBuyTab(),
                _buildSellTab(),
                _buildPricesTab(),
                _buildTransportTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateListingDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLocationAndCropSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
              value: selectedLocation,
              decoration: const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(Icons.location_on),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: locations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedLocation = value);
                  ref.read(selectedLocationProvider.notifier).state = value;
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedCrop,
              decoration: const InputDecoration(
                labelText: 'Crop',
                prefixIcon: Icon(Icons.agriculture),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: crops.map((crop) {
                return DropdownMenuItem(
                  value: crop,
                  child: Text(crop),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedCrop = value);
                  ref.read(selectedCropProvider.notifier).state = value;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyTab() {
    final asyncItems = ref.watch(marketplaceItemsProvider);
    return asyncItems.when(
      data: (items) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return CropListingCard(
            item: item,
            onTap: () => _showItemDetails(index),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off),
            const SizedBox(height: 8),
            Text('Failed to load listings'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.invalidate(marketplaceItemsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Active Listings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildMyListingItem('Maize', '50 kg', 'KES 2,250'),
                  _buildMyListingItem('Beans', '25 kg', 'KES 3,750'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showCreateListingDialog(),
                      child: const Text('Create New Listing'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quality Grading Assistant',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Get your produce graded to meet export standards and get better prices.',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _showGradingAssistant(),
                      child: const Text('Start Quality Assessment'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price Trends - Last 30 Days',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: Column(
                      children: [
                        Expanded(
                          child: PriceTrendChart(
                            cropType: selectedCrop,
                            location: selectedLocation,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Consumer(builder: (context, ref, _) {
                            final live = ref.watch(livePriceStreamProvider);
                            return live.when(
                              data: (v) => Text('Live price: KES ${v.toStringAsFixed(1)}/kg', style: const TextStyle(fontSize: 12)),
                              loading: () => const Text('Live price: ...', style: TextStyle(fontSize: 12)),
                              error: (_, __) => const Text('Live price unavailable', style: TextStyle(fontSize: 12)),
                            );
                          }),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceComparisonCard(),
          const SizedBox(height: 16),
          _buildBuyerLeadsCard(),
          const SizedBox(height: 16),
          _buildMarketInsightsCard(),
        ],
      ),
    );
  }

  Widget _buildTransportTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transport Coordination',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTransportOption('Shared Truck', 'KES 500 per 50kg bag'),
                _buildTransportOption('Express Delivery', 'KES 1,200 per 50kg bag'),
                _buildTransportOption('Cooperative Transport', 'KES 350 per 50kg bag'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cold Storage Options',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('Keep your produce fresh during transport and storage.'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Find Cold Storage'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyListingItem(String crop, String quantity, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$crop - $quantity'),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPriceComparisonCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Prices (per kg)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPriceRow('Maize', 'KES 45', '+5%', Colors.green),
            _buildPriceRow('Beans', 'KES 150', '-2%', Colors.red),
            _buildPriceRow('Coffee', 'KES 280', '+12%', Colors.green),
            _buildPriceRow('Tea', 'KES 320', 'No change', Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String crop, String price, String change, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(crop),
          Row(
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text(change, style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerLeadsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buyer Leads',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Consumer(builder: (context, ref, _) {
              final asyncBuyers = ref.watch(buyersProvider);
              return asyncBuyers.when(
                data: (buyers) => Column(
                  children: buyers.take(3).map((b) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: BuyerConnectionCard(
                        name: b['name']?.toString() ?? 'Buyer',
                        contact: b['contact']?.toString() ?? '',
                        location: b['location']?.toString() ?? '',
                        crops: (b['crops'] as List?)?.map((e) => e.toString()).toList() ?? const [],
                        rating: (b['rating'] is num) ? (b['rating'] as num).toDouble() : 0.0,
                        verified: b['verified'] == true,
                        onContact: () {},
                      ),
                    );
                  }).toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => const Text('Failed to load buyers'),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketInsightsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Market Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              Icons.trending_up,
              'High Demand',
              'Maize prices expected to rise due to drought in neighboring regions',
            ),
            _buildInsightItem(
              Icons.local_shipping,
              'Export Opportunity',
              'European buyers seeking organic coffee beans - premium pricing available',
            ),
            _buildInsightItem(
              Icons.weather_snowy,
              'Weather Alert',
              'Rain expected next week - good time to plant short-season crops',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportOption(String type, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(type),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        final minPrice = ref.read(minPriceProvider);
        final maxPrice = ref.read(maxPriceProvider);
        final quality = ref.read(qualityFilterProvider);
        final organic = ref.read(organicOnlyProvider);
        final minController = TextEditingController(text: minPrice?.toStringAsFixed(0) ?? '');
        final maxController = TextEditingController(text: maxPrice?.toStringAsFixed(0) ?? '');
        String? localQuality = quality;
        bool localOrganic = organic;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setStateModal) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: minController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Min Price (KES/kg)')
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: maxController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Max Price (KES/kg)')
                      ),
                    )
                  ]),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: localQuality,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Quality Grade'),
                    items: const [null, 'Grade A', 'Grade B', 'Grade C']
                        .map((e) => DropdownMenuItem<String?>(value: e, child: Text(e ?? 'Any'))) 
                        .cast<DropdownMenuItem<String>>()
                        .toList(),
                    onChanged: (v) => setStateModal(() => localQuality = v),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Organic only'),
                    value: localOrganic,
                    onChanged: (v) => setStateModal(() => localOrganic = v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ref.read(minPriceProvider.notifier).state = null;
                            ref.read(maxPriceProvider.notifier).state = null;
                            ref.read(qualityFilterProvider.notifier).state = null;
                            ref.read(organicOnlyProvider.notifier).state = false;
                            Navigator.pop(context);
                          },
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final min = double.tryParse(minController.text);
                            final max = double.tryParse(maxController.text);
                            ref.read(minPriceProvider.notifier).state = min;
                            ref.read(maxPriceProvider.notifier).state = max;
                            ref.read(qualityFilterProvider.notifier).state = localQuality;
                            ref.read(organicOnlyProvider.notifier).state = localOrganic;
                            Navigator.pop(context);
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCreateListingDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const CreateListingDialog(),
    );
    if (result != null) {
      // TODO: Send to backend and refresh list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing created (mock). Syncing...')),
      );
      ref.invalidate(marketplaceItemsProvider);
    }
  }

  void _showItemDetails(int index) {
    final asyncItems = ref.read(marketplaceItemsProvider);
    asyncItems.whenData((items) {
      final item = items[index];
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MarketplaceItemDetailsPage(item: item),
        ),
      );
    });
  }

  void _showGradingAssistant() {
    // TODO: Navigate to quality grading page
  }
}