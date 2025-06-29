import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../../data/models/store_model.dart';

class StoreApiService {
  static final StoreApiService _instance = StoreApiService._internal();
  factory StoreApiService() => _instance;
  StoreApiService._internal();

  late Dio _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = StorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  /// Get all store items
  Future<List<StoreItem>> getStoreItems() async {
    try {
      debugPrint('🛒 StoreApiService: Fetching store items...');
      final response = await _dio.get('/store/');
      if (response.statusCode == 200) {
        final List<dynamic> itemsData = response.data;
        final items =
            itemsData.map((item) => StoreItem.fromJson(item)).toList();
        debugPrint('✅ StoreApiService: Fetched \\${items.length} store items');
        return items;
      } else {
        debugPrint(
          '❌ StoreApiService: Failed to fetch store items - Status: \\${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('❌ StoreApiService: Error fetching store items: $e');
      if (e is DioException) {
        debugPrint('❌ DioException details: \\${e.response?.data}');
        debugPrint('❌ Status code: \\${e.response?.statusCode}');
      }
      return [];
    }
  }

  /// Buy an item from the store
  Future<Map<String, dynamic>> buyItem(String itemId) async {
    try {
      debugPrint('💰 StoreApiService: Buying item with ID: $itemId');
      final response = await _dio.post('/store/buy', data: {'itemId': itemId});
      if (response.statusCode == 200) {
        debugPrint('✅ StoreApiService: Item purchased successfully');
        return {
          'success': true,
          'message': response.data['message'] ?? 'Item purchased successfully!',
          'data': response.data,
        };
      } else {
        debugPrint(
          '❌ StoreApiService: Failed to buy item - Status: \\${response.statusCode}',
        );
        return {'success': false, 'message': 'Failed to purchase item'};
      }
    } catch (e) {
      debugPrint('❌ StoreApiService: Error buying item: $e');
      if (e is DioException) {
        debugPrint('❌ DioException details: \\${e.response?.data}');
        debugPrint('❌ Status code: \\${e.response?.statusCode}');
        if (e.response?.statusCode == 400) {
          final errorMsg =
              e.response?.data['message'] ??
              'Insufficient coins or invalid item';
          return {'success': false, 'message': errorMsg};
        } else if (e.response?.statusCode == 404) {
          return {'success': false, 'message': 'Item not found'};
        } else if (e.response?.statusCode == 401) {
          return {'success': false, 'message': 'Please log in again'};
        }
      }
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  /// Create a new store item (admin only)
  Future<Map<String, dynamic>> createItem(Map<String, dynamic> itemData) async {
    try {
      debugPrint('➕ StoreApiService: Creating new store item...');
      debugPrint('📄 Item data: $itemData');
      final response = await _dio.post('/store/', data: itemData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ StoreApiService: Store item created successfully');
        return {
          'success': true,
          'message': 'Store item created successfully!',
          'data': response.data,
        };
      } else {
        debugPrint(
          '❌ StoreApiService: Failed to create item - Status: \\${response.statusCode}',
        );
        return {'success': false, 'message': 'Failed to create store item'};
      }
    } catch (e) {
      debugPrint('❌ StoreApiService: Error creating store item: $e');
      if (e is DioException) {
        debugPrint('❌ DioException details: \\${e.response?.data}');
        debugPrint('❌ Status code: \\${e.response?.statusCode}');
        if (e.response?.statusCode == 403) {
          return {'success': false, 'message': 'Admin access required'};
        } else if (e.response?.statusCode == 400) {
          final errorMsg = e.response?.data['message'] ?? 'Invalid item data';
          return {'success': false, 'message': errorMsg};
        }
      }
      return {'success': false, 'message': 'Failed to create store item'};
    }
  }

  /// Update store item (admin only)
  Future<Map<String, dynamic>> updateItem(Map<String, dynamic> itemData) async {
    try {
      debugPrint('📝 StoreApiService: Updating store item...');
      debugPrint('📄 Item data: $itemData');
      final response = await _dio.put('/store/', data: itemData);
      if (response.statusCode == 200) {
        debugPrint('✅ StoreApiService: Store item updated successfully');
        return {
          'success': true,
          'message': 'Store item updated successfully!',
          'data': response.data,
        };
      } else {
        debugPrint(
          '❌ StoreApiService: Failed to update item - Status: \\${response.statusCode}',
        );
        return {'success': false, 'message': 'Failed to update store item'};
      }
    } catch (e) {
      debugPrint('❌ StoreApiService: Error updating store item: $e');
      if (e is DioException) {
        debugPrint('❌ DioException details: \\${e.response?.data}');
        debugPrint('❌ Status code: \\${e.response?.statusCode}');
        if (e.response?.statusCode == 403) {
          return {'success': false, 'message': 'Admin access required'};
        } else if (e.response?.statusCode == 400) {
          final errorMsg = e.response?.data['message'] ?? 'Invalid item data';
          return {'success': false, 'message': errorMsg};
        }
      }
      return {'success': false, 'message': 'Failed to update store item'};
    }
  }

  /// Delete store item (admin only)
  Future<Map<String, dynamic>> deleteItem(String itemId) async {
    try {
      debugPrint('🗑️ StoreApiService: Deleting store item with ID: $itemId');
      final response = await _dio.delete('/store/$itemId');
      if (response.statusCode == 200) {
        debugPrint('✅ StoreApiService: Store item deleted successfully');
        return {'success': true, 'message': 'Store item deleted successfully!'};
      } else {
        debugPrint(
          '❌ StoreApiService: Failed to delete item - Status: \\${response.statusCode}',
        );
        return {'success': false, 'message': 'Failed to delete store item'};
      }
    } catch (e) {
      debugPrint('❌ StoreApiService: Error deleting store item: $e');
      if (e is DioException) {
        debugPrint('❌ DioException details: \\${e.response?.data}');
        debugPrint('❌ Status code: \\${e.response?.statusCode}');
        if (e.response?.statusCode == 403) {
          return {'success': false, 'message': 'Admin access required'};
        } else if (e.response?.statusCode == 404) {
          return {'success': false, 'message': 'Store item not found'};
        }
      }
      return {'success': false, 'message': 'Failed to delete store item'};
    }
  }

  /// Get user's purchased items
  Future<List<String>> getPurchasedItems() async {
    try {
      debugPrint('🛍️ StoreApiService: Fetching purchased items...');
      final response = await _dio.get('/users/purchasedItems');
      if (response.statusCode == 200) {
        final List<dynamic> purchasedItems =
            response.data['purchasedItems'] ?? [];
        final List<String> itemIds =
            purchasedItems.map((item) => item.toString()).toList();
        debugPrint(
          '✅ StoreApiService: Fetched \\${itemIds.length} purchased items',
        );
        return itemIds;
      } else {
        debugPrint(
          '❌ StoreApiService: Failed to fetch purchased items - Status: \\${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('❌ StoreApiService: Error fetching purchased items: $e');
      if (e is DioException) {
        debugPrint('❌ DioException details: \\${e.response?.data}');
        debugPrint('❌ Status code: \\${e.response?.statusCode}');
      }
      return [];
    }
  }

  /// Get user coins
  Future<int> getUserCoins() async {
    try {
      final response = await _dio.get('/users/coins');
      final coins = response.data['coins'] ?? 0;
      return coins;
    } catch (e) {
      debugPrint('❌ StoreApiService: Error fetching user coins: $e');
      return 0;
    }
  }
}
