import 'dart:math';
import 'package:agricultural_platform/core/services/market_api_service.dart';
import 'package:agricultural_platform/core/services/storage_service.dart';
import '../models/marketplace_item.dart';

class MarketplaceRepository {
  static String _cacheKey(String location, String crop) => 'market_items_${location}_$crop';

  // Offline-first fetch
  static Future<List<MarketplaceItem>> getItems({required String location, required String crop}) async {
    final key = _cacheKey(location, crop);

    // 1) Try offline cache
    final cached = StorageService.getOfflineData(key);
    if (cached != null && cached['items'] is List) {
      try {
        final list = (cached['items'] as List)
            .map((e) => MarketplaceItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        if (list.isNotEmpty) return list;
      } catch (_) {}
    }

    // 2) Fetch from remote services (compose synthetic items from buyers/prices)
    final buyers = await MarketApiService.getBuyers(crop == 'All Crops' ? 'Maize' : crop, location);
    final prices = await MarketApiService.getMarketPrices('Kenya');

    final rng = Random(42);
    final result = List.generate(10, (i) {
      final buyer = buyers.isNotEmpty ? buyers[i % buyers.length] : null;
      final priceEntry = prices.isNotEmpty ? prices[i % prices.length] : null;
      final cropType = crop == 'All Crops' ? (priceEntry?['crop']?.toString() ?? 'Maize') : crop;
      final pricePerKg = (priceEntry?['price'] is num) ? (priceEntry['price'] as num).toDouble() : 45.0 + i;
      final quality = ['Grade A', 'Grade B', 'Grade C'][i % 3];
      final qty = ((i + 1) * 25).toString();

      return MarketplaceItem(
        id: 'item_$i',
        cropType: cropType,
        quantity: '$qty kg',
        pricePerKg: pricePerKg,
        location: location,
        farmerName: buyer != null ? buyer['name']?.toString() ?? 'Farmer ${i + 1}' : 'Farmer ${i + 1}',
        farmerRating: 3.5 + (rng.nextDouble() * 1.5),
        imageUrl: 'assets/images/maize.jpg',
        description: 'High quality $cropType from $location. Fresh and ready to ship.',
        harvestDate: DateTime.now().subtract(Duration(days: rng.nextInt(10))),
        qualityGrade: quality,
        isOrganic: i % 2 == 0,
        isCertified: i % 3 == 0,
        certifications: i % 3 == 0 ? ['GlobalG.A.P.'] : [],
      );
    });

    // 3) Save to offline cache
    await StorageService.setOfflineData(key, {
      'items': result.map((e) => e.toJson()).toList(),
    });

    return result;
  }
}