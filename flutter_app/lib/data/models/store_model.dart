import 'package:flutter/material.dart';

// Enhanced Store Models to match your backend

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
      default:
        return Icons.star_rounded;
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
      default:
        return const Color(0xFF64748B);
    }
  }
}

// Store Filter Types
enum StoreFilter { all, gardenItems, pets, themes, gifts, games, purchased }

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
}

// Purchase Result Model
class PurchaseResult {
  final bool success;
  final String message;
  final StoreItem? purchasedItem;
  final int? newCoinBalance;

  PurchaseResult({
    required this.success,
    required this.message,
    this.purchasedItem,
    this.newCoinBalance,
  });

  factory PurchaseResult.fromJson(Map<String, dynamic> json) {
    return PurchaseResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      purchasedItem:
          json['item'] != null ? StoreItem.fromJson(json['item']) : null,
      newCoinBalance: json['newCoinBalance'],
    );
  }
}
