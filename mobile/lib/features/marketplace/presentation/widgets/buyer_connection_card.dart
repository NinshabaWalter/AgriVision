import 'package:flutter/material.dart';

class BuyerConnectionCard extends StatelessWidget {
  final String name;
  final String contact;
  final String location;
  final List<String> crops;
  final double rating;
  final bool verified;
  final VoidCallback? onContact;

  const BuyerConnectionCard({
    super.key,
    required this.name,
    required this.contact,
    required this.location,
    required this.crops,
    this.rating = 0,
    this.verified = false,
    this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                if (verified)
                  const Icon(Icons.verified, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(rating.toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 6),
            Text(location, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: -8,
              children: crops
                  .take(4)
                  .map((c) => Chip(label: Text(c), visualDensity: VisualDensity.compact))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onContact,
                  icon: const Icon(Icons.call),
                  label: const Text('Contact'),
                ),
                const SizedBox(width: 8),
                Text(contact, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}