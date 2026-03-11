import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/marketplace_item.dart';
import '../../data/repositories/marketplace_repository.dart';
import '../../../../core/services/market_api_service.dart';

final selectedLocationProvider = StateProvider<String>((ref) => 'Nairobi, Kenya');
final selectedCropProvider = StateProvider<String>((ref) => 'All Crops');

// Filters
final minPriceProvider = StateProvider<double?>((ref) => null);
final maxPriceProvider = StateProvider<double?>((ref) => null);
final qualityFilterProvider = StateProvider<String?>((ref) => null); // Grade A/B/C
final organicOnlyProvider = StateProvider<bool>((ref) => false);

final sortOptionProvider = StateProvider<String>((ref) => 'Relevance');

final marketplaceItemsProvider = FutureProvider<List<MarketplaceItem>>((ref) async {
  final location = ref.watch(selectedLocationProvider);
  final crop = ref.watch(selectedCropProvider);
  final items = await MarketplaceRepository.getItems(location: location, crop: crop);

  // Apply client-side filters
  final minPrice = ref.watch(minPriceProvider);
  final maxPrice = ref.watch(maxPriceProvider);
  final quality = ref.watch(qualityFilterProvider);
  final organic = ref.watch(organicOnlyProvider);

  List<MarketplaceItem> filtered = items.where((e) {
    final priceOk = (minPrice == null || e.pricePerKg >= minPrice) && (maxPrice == null || e.pricePerKg <= maxPrice);
    final qualityOk = quality == null || e.qualityGrade == quality;
    final organicOk = !organic || e.isOrganic;
    return priceOk && qualityOk && organicOk;
  }).toList();

  // Sort
  final sort = ref.watch(sortOptionProvider);
  int daysSince(DateTime d) => DateTime.now().difference(d).inDays;
  switch (sort) {
    case 'Price ↑':
      filtered.sort((a, b) => a.pricePerKg.compareTo(b.pricePerKg));
      break;
    case 'Price ↓':
      filtered.sort((a, b) => b.pricePerKg.compareTo(a.pricePerKg));
      break;
    case 'Rating':
      filtered.sort((a, b) => b.farmerRating.compareTo(a.farmerRating));
      break;
    case 'Freshness':
      filtered.sort((a, b) => daysSince(a.harvestDate).compareTo(daysSince(b.harvestDate))); // fresher first
      break;
    default:
      break;
  }

  return filtered;
});

// Live price updates (simulated stream). Replace with real WebSocket source.
final livePriceStreamProvider = StreamProvider<double>((ref) {
  // Broadcasts a price every 5 seconds
  final controller = StreamController<double>();
  double base = 45.0;
  Timer? timer;
  timer = Timer.periodic(const Duration(seconds: 5), (_) {
    base += ([-1.2, -0.5, 0.3, 0.7, 1.5]..shuffle()).first;
    controller.add(base);
  });
  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });
  return controller.stream;
});

// Buyers lead provider
final buyersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final location = ref.watch(selectedLocationProvider);
  final crop = ref.watch(selectedCropProvider);
  // Lightweight call via repository's underlying API service
  return await MarketApiService.getBuyers(crop == 'All Crops' ? 'Maize' : crop, location);
});