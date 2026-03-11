import 'package:flutter/material.dart';
import '../../data/models/marketplace_item.dart';
import 'chat_page.dart';

class MarketplaceItemDetailsPage extends StatelessWidget {
  final MarketplaceItem item;
  const MarketplaceItemDetailsPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.cropType)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16/9,
            child: item.imageUrl.startsWith('http')
                ? Image.network(item.imageUrl, fit: BoxFit.cover)
                : Image.asset(item.imageUrl, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${item.quantity} • ${item.qualityGrade}', style: const TextStyle(fontSize: 16)),
              _SuggestedPriceTag(base: item.pricePerKg, freshness: item.freshness),
            ],
          ),
          const SizedBox(height: 8),
          Text('KES ${item.pricePerKg.toStringAsFixed(0)}/kg', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, size: 16),
              const SizedBox(width: 4),
              Text(item.farmerName),
              const SizedBox(width: 16),
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 4),
              Text(item.location),
            ],
          ),
          const SizedBox(height: 12),
          Text(item.description),
          const SizedBox(height: 12),
          Text('Freshness: ${item.freshness}'),
          const SizedBox(height: 12),
          if (item.certifications.isNotEmpty) ...[
            const Text('Certifications', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: item.certifications.map((c) => Chip(label: Text(c))).toList(),
            )
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatPage(peerName: item.farmerName),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat with Seller'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showOfferSheet(context, item);
                  },
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: const Text('Make Offer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOfferSheet(BuildContext context, MarketplaceItem item) {
    final qtyController = TextEditingController(text: item.quantity);
    final priceController = TextEditingController(text: item.pricePerKg.toStringAsFixed(0));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Make an Offer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: qtyController,
                decoration: const InputDecoration(labelText: 'Quantity (e.g., 100 kg)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price per kg (KES)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Offer submitted (mock). Await seller response.')),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Submit Offer'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}

class _SuggestedPriceTag extends StatelessWidget {
  final double base; // base price per kg
  final String freshness; // Very Fresh / Fresh / Good / Consider pricing adjustment
  const _SuggestedPriceTag({required this.base, required this.freshness});

  @override
  Widget build(BuildContext context) {
    final factor = switch (freshness) {
      'Very Fresh' => 1.10,
      'Fresh' => 1.05,
      'Good' => 1.00,
      _ => 0.95,
    };
    final suggested = (base * factor).clamp(base * 0.8, base * 1.2);
    return Chip(
      avatar: const Icon(Icons.lightbulb, size: 16),
      label: Text('Suggest: KES ${suggested.toStringAsFixed(0)}/kg'),
    );
  }
}