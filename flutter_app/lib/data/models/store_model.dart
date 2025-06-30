import 'package:flutter/material.dart';

// Main Store Item Model
class StoreItem {
  final String id;
  final String name;
  final String description;
  final String type;
  final int price;
  final String image;
  final bool isPurchased;

  StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    required this.image,
    this.isPurchased = false,
  });

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      price: (json['price'] ?? 0).toInt(),
      image: json['image']?.toString() ?? '',
      isPurchased: json['isPurchased'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'type': type,
      'price': price,
      'image': image,
      'isPurchased': isPurchased,
    };
  }

  StoreItem copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    int? price,
    String? image,
    bool? isPurchased,
  }) {
    return StoreItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      price: price ?? this.price,
      image: image ?? this.image,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }

  // Helper method to get appropriate icon based on type
  IconData get icon {
    switch (type.toLowerCase()) {
      case 'garden items':
      case 'garden':
        return Icons.local_florist_rounded;
      case 'pets':
      case 'pet':
        return Icons.pets_rounded;
      case 'themes':
      case 'theme':
        return Icons.palette_rounded;
      case 'gifts':
      case 'gift':
        return Icons.card_giftcard_rounded;
      case 'games':
      case 'game':
        return Icons.sports_esports_rounded;
      case 'avatar':
      case 'cosmetic':
        return Icons.checkroom_rounded;
      case 'badge':
      case 'achievement':
        return Icons.shield_rounded;
      case 'boost':
      case 'power-up':
        return Icons.flash_on_rounded;
      case 'reward':
      case 'privilege':
        return Icons.star_rounded;
      default:
        return Icons.shopping_bag_rounded;
    }
  }

  // Helper method to get appropriate color based on type
  Color get color {
    switch (type.toLowerCase()) {
      case 'garden items':
      case 'garden':
        return const Color(0xFF10B981);
      case 'pets':
      case 'pet':
        return const Color(0xFF8B5CF6);
      case 'themes':
      case 'theme':
        return const Color(0xFFE11D48);
      case 'gifts':
      case 'gift':
        return const Color(0xFF0EA5E9);
      case 'games':
      case 'game':
        return const Color(0xFFFF6B9D);
      case 'avatar':
      case 'cosmetic':
        return const Color(0xFFE11D48);
      case 'badge':
      case 'achievement':
        return const Color(0xFF06B6D4);
      case 'boost':
      case 'power-up':
        return const Color(0xFFF59E0B);
      case 'reward':
      case 'privilege':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  String toString() {
    return 'StoreItem(id: $id, name: $name, type: $type, price: $price, isPurchased: $isPurchased)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoreItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Store Filter Enum
enum StoreFilter {
  all,
  gardenItems,
  pets,
  themes,
  gifts,
  games,
  purchased,
}

extension StoreFilterExtension on StoreFilter {
  String get displayName {
    switch (this) {
      case StoreFilter.all:
        return 'All';
      case StoreFilter.gardenItems:
        return 'Garden Items';
      case StoreFilter.pets:
        return 'Pets';
      case StoreFilter.themes:
        return 'Themes';
      case StoreFilter.gifts:
        return 'Gifts';
      case StoreFilter.games:
        return 'Games';
      case StoreFilter.purchased:
        return 'Purchased';
    }
  }

  String get filterValue {
    switch (this) {
      case StoreFilter.all:
        return 'All';
      case StoreFilter.gardenItems:
        return 'Garden Items';
      case StoreFilter.pets:
        return 'Pets';
      case StoreFilter.themes:
        return 'Themes';
      case StoreFilter.gifts:
        return 'Gifts';
      case StoreFilter.games:
        return 'Games';
      case StoreFilter.purchased:
        return 'Purchased';
    }
  }

  // Helper to check if item matches this filter
  bool matches(StoreItem item, List<String> purchasedIds) {
    switch (this) {
      case StoreFilter.all:
        return true;
      case StoreFilter.purchased:
        return purchasedIds.contains(item.id) || item.isPurchased;
      default:
        return item.type.toLowerCase() == filterValue.toLowerCase();
    }
  }
}

// Purchase Result Model
class PurchaseResult {
  final bool success;
  final String message;
  final StoreItem? purchasedItem;
  final int? newCoinBalance;
  final Map<String, dynamic>? additionalData;

  PurchaseResult({
    required this.success,
    required this.message,
    this.purchasedItem,
    this.newCoinBalance,
    this.additionalData,
  });

  factory PurchaseResult.fromJson(Map<String, dynamic> json) {
    return PurchaseResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      purchasedItem: json['item'] != null 
          ? StoreItem.fromJson(json['item']) 
          : null,
      newCoinBalance: json['newCoinBalance']?.toInt(),
      additionalData: json['data'],
    );
  }

  factory PurchaseResult.success({
    required String message,
    StoreItem? item,
    int? newBalance,
    Map<String, dynamic>? data,
  }) {
    return PurchaseResult(
      success: true,
      message: message,
      purchasedItem: item,
      newCoinBalance: newBalance,
      additionalData: data,
    );
  }

  factory PurchaseResult.failure(String message) {
    return PurchaseResult(
      success: false,
      message: message,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'item': purchasedItem?.toJson(),
      'newCoinBalance': newCoinBalance,
      'data': additionalData,
    };
  }
}

// Store Category Model (for organizing items)
class StoreCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<StoreItem> items;
  final bool isEnabled;

  StoreCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.items,
    this.isEnabled = true,
  });

  factory StoreCategory.fromFilter(StoreFilter filter, List<StoreItem> allItems) {
    final filteredItems = allItems.where((item) {
      switch (filter) {
        case StoreFilter.all:
          return true;
        case StoreFilter.purchased:
          return item.isPurchased;
        default:
          return item.type.toLowerCase() == filter.filterValue.toLowerCase();
      }
    }).toList();

    return StoreCategory(
      id: filter.name,
      name: filter.displayName,
      description: _getCategoryDescription(filter),
      icon: _getCategoryIcon(filter),
      color: _getCategoryColor(filter),
      items: filteredItems,
    );
  }

  static String _getCategoryDescription(StoreFilter filter) {
    switch (filter) {
      case StoreFilter.all:
        return 'All available items';
      case StoreFilter.gardenItems:
        return 'Items for your magic garden';
      case StoreFilter.pets:
        return 'Cute virtual pets';
      case StoreFilter.themes:
        return 'Beautiful themes and decorations';
      case StoreFilter.gifts:
        return 'Special gifts and rewards';
      case StoreFilter.games:
        return 'Fun games and activities';
      case StoreFilter.purchased:
        return 'Your purchased items';
    }
  }

  static IconData _getCategoryIcon(StoreFilter filter) {
    switch (filter) {
      case StoreFilter.all:
        return Icons.grid_view_rounded;
      case StoreFilter.gardenItems:
        return Icons.local_florist_rounded;
      case StoreFilter.pets:
        return Icons.pets_rounded;
      case StoreFilter.themes:
        return Icons.palette_rounded;
      case StoreFilter.gifts:
        return Icons.card_giftcard_rounded;
      case StoreFilter.games:
        return Icons.sports_esports_rounded;
      case StoreFilter.purchased:
        return Icons.shopping_bag_rounded;
    }
  }

  static Color _getCategoryColor(StoreFilter filter) {
    switch (filter) {
      case StoreFilter.all:
        return const Color(0xFF64748B);
      case StoreFilter.gardenItems:
        return const Color(0xFF10B981);
      case StoreFilter.pets:
        return const Color(0xFF8B5CF6);
      case StoreFilter.themes:
        return const Color(0xFFE11D48);
      case StoreFilter.gifts:
        return const Color(0xFF0EA5E9);
      case StoreFilter.games:
        return const Color(0xFFFF6B9D);
      case StoreFilter.purchased:
        return const Color(0xFF06B6D4);
    }
  }

  int get itemCount => items.length;
  
  bool get hasItems => items.isNotEmpty;
  
  List<StoreItem> get availableItems => items.where((item) => !item.isPurchased).toList();
  
  List<StoreItem> get purchasedItems => items.where((item) => item.isPurchased).toList();
}

// Store Statistics Model
class StoreStats {
  final int totalItems;
  final int purchasedItems;
  final int availableItems;
  final int totalCoinsSpent;
  final int averageItemPrice;
  final String favoriteCategory;
  final Map<String, int> categoryBreakdown;

  StoreStats({
    required this.totalItems,
    required this.purchasedItems,
    required this.availableItems,
    required this.totalCoinsSpent,
    required this.averageItemPrice,
    required this.favoriteCategory,
    required this.categoryBreakdown,
  });

  factory StoreStats.fromItems(List<StoreItem> items) {
    final purchased = items.where((item) => item.isPurchased).toList();
    final available = items.where((item) => !item.isPurchased).toList();
    
    final totalSpent = purchased.fold<int>(0, (sum, item) => sum + item.price);
    final avgPrice = items.isNotEmpty 
        ? items.fold<int>(0, (sum, item) => sum + item.price) ~/ items.length 
        : 0;

    // Category breakdown
    final categoryCount = <String, int>{};
    for (final item in items) {
      categoryCount[item.type] = (categoryCount[item.type] ?? 0) + 1;
    }

    final favoriteCategory = categoryCount.entries
        .fold<MapEntry<String, int>?>(
          null,
          (prev, current) => prev == null || current.value > prev.value ? current : prev,
        )?.key ?? 'None';

    return StoreStats(
      totalItems: items.length,
      purchasedItems: purchased.length,
      availableItems: available.length,
      totalCoinsSpent: totalSpent,
      averageItemPrice: avgPrice,
      favoriteCategory: favoriteCategory,
      categoryBreakdown: categoryCount,
    );
  }

  double get purchasePercentage => 
      totalItems > 0 ? (purchasedItems / totalItems) * 100 : 0.0;

  bool get hasActivity => purchasedItems > 0;
}

// Store Configuration Model
class StoreConfig {
  final bool isEnabled;
  final String welcomeMessage;
  final String emptyStateMessage;
  final int maxItemsPerPage;
  final bool showPurchaseConfirmation;
  final bool enableFilters;
  final List<StoreFilter> availableFilters;
  final Map<String, dynamic> customSettings;

  StoreConfig({
    this.isEnabled = true,
    this.welcomeMessage = 'Welcome to your Magic Store',
    this.emptyStateMessage = 'No items available',
    this.maxItemsPerPage = 20,
    this.showPurchaseConfirmation = true,
    this.enableFilters = true,
    this.availableFilters = const [
      StoreFilter.all,
      StoreFilter.gardenItems,
      StoreFilter.pets,
      StoreFilter.themes,
      StoreFilter.gifts,
      StoreFilter.games,
      StoreFilter.purchased,
    ],
    this.customSettings = const {},
  });

  factory StoreConfig.fromJson(Map<String, dynamic> json) {
    return StoreConfig(
      isEnabled: json['isEnabled'] ?? true,
      welcomeMessage: json['welcomeMessage'] ?? 'Welcome to your Magic Store',
      emptyStateMessage: json['emptyStateMessage'] ?? 'No items available',
      maxItemsPerPage: json['maxItemsPerPage'] ?? 20,
      showPurchaseConfirmation: json['showPurchaseConfirmation'] ?? true,
      enableFilters: json['enableFilters'] ?? true,
      customSettings: json['customSettings'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'welcomeMessage': welcomeMessage,
      'emptyStateMessage': emptyStateMessage,
      'maxItemsPerPage': maxItemsPerPage,
      'showPurchaseConfirmation': showPurchaseConfirmation,
      'enableFilters': enableFilters,
      'customSettings': customSettings,
    };
  }
}