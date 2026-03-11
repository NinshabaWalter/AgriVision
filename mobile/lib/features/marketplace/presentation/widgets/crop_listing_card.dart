import 'package:flutter/material.dart';
import '../../../data/models/marketplace_item.dart';

class CropListingCard extends StatelessWidget {
  final MarketplaceItem item;
  final VoidCallback? onTap;

  const CropListingCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            _buildImage(context),
            Expanded(child: _buildInfo(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final placeholder = Container(
      width: 110,
      height: 110,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: const Icon(Icons.agriculture, size: 36),
    );

    if (item.imageUrl.startsWith('http')) {
      return SizedBox(
        width: 110,
        height: 110,
        child: Image.network(
          item.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return placeholder;
          },
        ),
      );
    }

    return SizedBox(
      width: 110,
      height: 110,
      child: Image.asset(
        item.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.cropType,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildRating(),
            ],
          ),
          const SizedBox(height: 6),
          Text('${item.quantity} • ${item.qualityGrade}${item.isOrganic ? ' • Organic' : ''}',
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('KES ${item.pricePerKg.toStringAsFixed(0)}/kg',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(item.location, style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 16),
        const SizedBox(width: 4),
        Text(item.farmerRating.toStringAsFixed(1)),
      ],
    );
  }
}