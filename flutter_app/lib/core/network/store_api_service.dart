import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/services/storage_service.dart';
import '../constants/app_constants.dart';
import '../../data/models/store_model.dart';

class StoreApiService {
  static final StoreApiService _instance = StoreApiService._internal();
  factory StoreApiService() => _instance;
  StoreApiService._internal();

  late Dio _dio;
  bool _isInitialized = false;

  void init() {
    if (_isInitialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add comprehensive interceptors
    _dio.interceptors.add(_createAuthInterceptor());
    _dio.interceptors.add(_createLoggingInterceptor());
    _dio.interceptors.add(_createErrorInterceptor());

    _isInitialized = true;
    debugPrint(
      '✅ StoreApiService initialized with base URL: ${AppConstants.baseUrl}',
    );
  }

  // Auth Interceptor
  InterceptorsWrapper _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = StorageService.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint('🔐 Added auth token to request');
        } else {
          debugPrint('⚠️ No auth token available');
        }
        handler.next(options);
      },
    );
  }

  // Logging Interceptor
  InterceptorsWrapper _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint(
          '🚀 REQUEST: ${options.method} ${options.baseUrl}${options.path}',
        );
        if (options.queryParameters.isNotEmpty) {
          debugPrint('📊 Query Parameters: ${options.queryParameters}');
        }
        if (options.data != null) {
          debugPrint('📦 Request Data: ${options.data}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint(
          '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}',
        );
        debugPrint('📦 Response Type: ${response.data.runtimeType}');
        if (response.data is Map || response.data is List) {
          debugPrint(
            '📦 Response Length: ${response.data.toString().length} chars',
          );
        }
        handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('❌ ERROR: ${error.type} ${error.requestOptions.path}');
        debugPrint('❌ Message: ${error.message}');
        if (error.response != null) {
          debugPrint('❌ Status: ${error.response!.statusCode}');
          debugPrint('❌ Response: ${error.response!.data}');
        }
        handler.next(error);
      },
    );
  }

  // Error Handling Interceptor
  InterceptorsWrapper _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          debugPrint(
            '🔐 Token expired or invalid - may need to re-authenticate',
          );
          // Note: Don't automatically logout here, let the app handle it
        } else if (error.response?.statusCode == 403) {
          debugPrint('🚫 Access forbidden - insufficient permissions');
        } else if (error.response?.statusCode == 429) {
          debugPrint('⏰ Rate limited - too many requests');
        }
        handler.next(error);
      },
    );
  }

  /// Test store endpoint connectivity
  Future<bool> testConnection() async {
    try {
      debugPrint('🔍 Testing store endpoint connectivity...');
      final response = await _dio.get(
        '/store/',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      debugPrint('📡 Connection test response: ${response.statusCode}');
      final isConnected =
          response.statusCode == 200 || response.statusCode == 400;
      debugPrint(
        isConnected
            ? '✅ Store endpoint is reachable'
            : '❌ Store endpoint returned ${response.statusCode}',
      );
      return isConnected;
    } on DioException catch (e) {
      debugPrint('❌ Connection test failed: ${e.type}');
      debugPrint('❌ Response: ${e.response?.statusCode} - ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('❌ Connection test error: $e');
      return false;
    }
  }

  /// Get all store items with comprehensive error handling and data parsing
  Future<List<StoreItem>> getStoreItems() async {
    debugPrint('🛒 Fetching store items...');
    try {
      final response = await _dio.get('/store/');
      debugPrint('📦 Store response status: [32m${response.statusCode}[0m');
      debugPrint('📦 Store response data: ${response.data}');
      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;
          if (responseMap.containsKey('items') &&
              responseMap['items'] is List) {
            final itemsData = responseMap['items'] as List;
            debugPrint('✅ Found ${itemsData.length} items in response');
            final items = <StoreItem>[];
            for (int i = 0; i < itemsData.length; i++) {
              try {
                if (itemsData[i] is Map<String, dynamic>) {
                  final item = StoreItem.fromJson(itemsData[i]);
                  items.add(item);
                  debugPrint(
                    '   ✅ Parsed item: ${item.name} (${item.price} coins)',
                  );
                }
              } catch (e) {
                debugPrint('   ❌ Failed to parse item at index $i: $e');
              }
            }
            debugPrint('✅ Successfully parsed ${items.length} store items');
            return items;
          } else {
            debugPrint(
              '❌ Response missing items array. Keys: ${responseMap.keys.toList()}',
            );
            return [];
          }
        } else {
          debugPrint(
            '❌ Unexpected response format: ${response.data.runtimeType}',
          );
          return [];
        }
      } else {
        debugPrint('❌ Store API returned status: ${response.statusCode}');
        return [];
      }
    } on DioException catch (e) {
      debugPrint('🌐 Network error fetching store items: ${e.type}');
      if (e.response?.statusCode == 400) {
        debugPrint('📝 No items found (400 response), returning empty list');
        return [];
      }
      debugPrint('🌐 Response data: ${e.response?.data}');
      throw _handleDioException(e, 'Failed to fetch store items');
    } catch (e) {
      debugPrint('❌ Unexpected error fetching store items: $e');
      throw StoreApiException('Unexpected error: $e');
    }
  }

  /// Get user's current coin balance
  Future<int> getUserCoins() async {
    debugPrint('🪙 Fetching user coins...');
    try {
      final response = await _dio.get('/users/coins');
      debugPrint('💰 Coins response status: ${response.statusCode}');
      debugPrint('💰 Coins response data: ${response.data}');
      if (response.statusCode == 200) {
        final responseData = response.data;
        int coins = 0;
        if (responseData is Map<String, dynamic>) {
          coins =
              (responseData['coins'] ??
                      responseData['userCoins'] ??
                      responseData['balance'] ??
                      responseData['data']?['coins'] ??
                      0)
                  as int;
        } else if (responseData is int) {
          coins = responseData;
        } else if (responseData is String) {
          coins = int.tryParse(responseData) ?? 0;
        } else {
          debugPrint(
            '⚠️ Unexpected coins response format: ${responseData.runtimeType}',
          );
          coins = 0;
        }
        debugPrint('✅ User has $coins coins');
        return coins;
      } else {
        debugPrint('❌ Coins API returned status: ${response.statusCode}');
        return 0;
      }
    } on DioException catch (e) {
      debugPrint('🌐 Network error fetching coins: ${e.type}');
      debugPrint('🌐 Response: ${e.response?.data}');
      return 0;
    } catch (e) {
      debugPrint('❌ Unexpected error fetching coins: $e');
      return 0;
    }
  }

  /// Get user's purchased items
  Future<List<String>> getPurchasedItems() async {
    debugPrint('🛍️ Fetching purchased items...');
    try {
      final response = await _dio.get('/users/purchasedItems');
      debugPrint('🛍️ Purchased items response status: ${response.statusCode}');
      debugPrint('🛍️ Purchased items response data: ${response.data}');
      if (response.statusCode == 200) {
        final responseData = response.data;
        List<String> purchasedIds = [];
        if (responseData is Map<String, dynamic>) {
          final purchasedItems =
              responseData['purchasedItems'] ??
              responseData['items'] ??
              responseData['data'];
          if (purchasedItems is List) {
            purchasedIds =
                purchasedItems.map((item) {
                  if (item is Map && item.containsKey('itemId')) {
                    return item['itemId'].toString();
                  }
                  return item.toString();
                }).toList();
          }
        } else if (responseData is List) {
          purchasedIds =
              responseData.map((item) {
                if (item is Map && item.containsKey('itemId')) {
                  return item['itemId'].toString();
                }
                return item.toString();
              }).toList();
        }
        debugPrint('✅ User has ${purchasedIds.length} purchased items');
        return purchasedIds;
      } else {
        debugPrint(
          '❌ Purchased items API returned status: ${response.statusCode}',
        );
        return [];
      }
    } on DioException catch (e) {
      debugPrint('🌐 Network error fetching purchased items: ${e.type}');
      debugPrint('🌐 Response: ${e.response?.data}');
      return [];
    } catch (e) {
      debugPrint('❌ Unexpected error fetching purchased items: $e');
      return [];
    }
  }

  /// Purchase an item from the store
  Future<PurchaseResult> buyItem(String itemId) async {
    debugPrint('💰 Attempting to purchase item: $itemId');

    try {
      final response = await _dio.post('/store/buy', data: {'itemId': itemId});

      if (response.statusCode == 200) {
        debugPrint('✅ Purchase successful for item: $itemId');

        final responseData = response.data as Map<String, dynamic>;
        return PurchaseResult.success(
          message: responseData['message'] ?? 'Item purchased successfully!',
          newBalance: responseData['newBalance'] ?? responseData['coins'],
          data: responseData,
        );
      } else {
        debugPrint('❌ Purchase failed with status: ${response.statusCode}');
        return PurchaseResult.failure(
          'Purchase failed with status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('🌐 Network error during purchase: ${e.type}');

      if (e.response?.statusCode == 400) {
        final errorMsg =
            e.response?.data['message'] ?? 'Insufficient coins or invalid item';
        return PurchaseResult.failure(errorMsg);
      } else if (e.response?.statusCode == 404) {
        return PurchaseResult.failure('Item not found');
      } else if (e.response?.statusCode == 401) {
        return PurchaseResult.failure('Please log in again');
      } else if (e.response?.statusCode == 403) {
        return PurchaseResult.failure('Access denied');
      } else {
        return PurchaseResult.failure('Network error occurred');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error during purchase: $e');
      return PurchaseResult.failure('Unexpected error: $e');
    }
  }

  /// Create a new store item (admin only)
  Future<PurchaseResult> createStoreItem(Map<String, dynamic> itemData) async {
    debugPrint('➕ Creating new store item...');

    try {
      final response = await _dio.post('/store/', data: itemData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Store item created successfully');
        return PurchaseResult.success(
          message: 'Store item created successfully!',
          data: response.data,
        );
      } else {
        return PurchaseResult.failure('Failed to create item');
      }
    } on DioException catch (e) {
      debugPrint('🌐 Network error creating item: ${e.type}');

      if (e.response?.statusCode == 403) {
        return PurchaseResult.failure('Admin access required');
      } else if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data['message'] ?? 'Invalid item data';
        return PurchaseResult.failure(errorMsg);
      } else {
        return PurchaseResult.failure('Failed to create store item');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error creating item: $e');
      return PurchaseResult.failure('Unexpected error: $e');
    }
  }

  /// Update store item (admin only)
  Future<PurchaseResult> updateStoreItem(
    String itemId,
    Map<String, dynamic> itemData,
  ) async {
    debugPrint('📝 Updating store item: $itemId');

    try {
      final response = await _dio.put(
        '/store/',
        data: {...itemData, 'itemId': itemId},
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Store item updated successfully');
        return PurchaseResult.success(
          message: 'Store item updated successfully!',
          data: response.data,
        );
      } else {
        return PurchaseResult.failure('Failed to update item');
      }
    } on DioException catch (e) {
      debugPrint('🌐 Network error updating item: ${e.type}');

      if (e.response?.statusCode == 403) {
        return PurchaseResult.failure('Admin access required');
      } else if (e.response?.statusCode == 404) {
        return PurchaseResult.failure('Item not found');
      } else if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data['message'] ?? 'Invalid item data';
        return PurchaseResult.failure(errorMsg);
      } else {
        return PurchaseResult.failure('Failed to update store item');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error updating item: $e');
      return PurchaseResult.failure('Unexpected error: $e');
    }
  }

  /// Delete store item (admin only)
  Future<PurchaseResult> deleteStoreItem(String itemId) async {
    debugPrint('🗑️ Deleting store item: $itemId');

    try {
      final response = await _dio.delete('/store/$itemId');

      if (response.statusCode == 200) {
        debugPrint('✅ Store item deleted successfully');
        return PurchaseResult.success(
          message: 'Store item deleted successfully!',
        );
      } else {
        return PurchaseResult.failure('Failed to delete item');
      }
    } on DioException catch (e) {
      debugPrint('🌐 Network error deleting item: ${e.type}');

      if (e.response?.statusCode == 403) {
        return PurchaseResult.failure('Admin access required');
      } else if (e.response?.statusCode == 404) {
        return PurchaseResult.failure('Item not found');
      } else {
        return PurchaseResult.failure('Failed to delete store item');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error deleting item: $e');
      return PurchaseResult.failure('Unexpected error: $e');
    }
  }

  /// Get store configuration
  Future<StoreConfig> getStoreConfig() async {
    debugPrint('⚙️ Fetching store configuration...');

    try {
      final response = await _dio.get('/store/config');

      if (response.statusCode == 200) {
        debugPrint('✅ Store config fetched successfully');
        return StoreConfig.fromJson(response.data);
      } else {
        debugPrint('⚠️ Store config not available, using defaults');
        return StoreConfig();
      }
    } catch (e) {
      debugPrint('⚠️ Could not fetch store config, using defaults: $e');
      return StoreConfig();
    }
  }

  /// Get store statistics
  Future<StoreStats> getStoreStats() async {
    debugPrint('📊 Fetching store statistics...');

    try {
      // Fetch all items to calculate statistics
      final items = await getStoreItems();
      final purchasedIds = await getPurchasedItems();

      // Mark purchased items
      final itemsWithPurchaseStatus =
          items
              .map(
                (item) =>
                    item.copyWith(isPurchased: purchasedIds.contains(item.id)),
              )
              .toList();

      final stats = StoreStats.fromItems(itemsWithPurchaseStatus);
      debugPrint('✅ Store statistics calculated successfully');
      return stats;
    } catch (e) {
      debugPrint('❌ Error calculating store statistics: $e');
      // Return empty stats as fallback
      return StoreStats.fromItems([]);
    }
  }

  /// Handle Dio exceptions with appropriate error messages
  StoreApiException _handleDioException(DioException e, String defaultMessage) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return StoreApiException(
          'Connection timeout. Check your internet connection.',
        );
      case DioExceptionType.sendTimeout:
        return StoreApiException('Request timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return StoreApiException('Response timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return StoreApiException(
            'Authentication required. Please log in again.',
          );
        } else if (statusCode == 403) {
          return StoreApiException('Access denied. Insufficient permissions.');
        } else if (statusCode == 404) {
          return StoreApiException('Store not found. Please contact support.');
        } else if (statusCode == 429) {
          return StoreApiException(
            'Too many requests. Please wait and try again.',
          );
        } else if (statusCode != null && statusCode >= 500) {
          return StoreApiException('Server error. Please try again later.');
        } else {
          return StoreApiException('$defaultMessage (Status: $statusCode)');
        }
      case DioExceptionType.cancel:
        return StoreApiException('Request was cancelled.');
      case DioExceptionType.connectionError:
        return StoreApiException(
          'No internet connection. Please check your network.',
        );
      default:
        return StoreApiException('$defaultMessage: ${e.message}');
    }
  }

  /// Clean up resources
  void dispose() {
    if (_isInitialized) {
      _dio.close();
      _isInitialized = false;
      debugPrint('🧹 StoreApiService disposed');
    }
  }
}

/// Custom exception for Store API errors
class StoreApiException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  StoreApiException(this.message, {this.code, this.details});

  @override
  String toString() => 'StoreApiException: $message';
}

/// Extension for additional debugging capabilities
extension StoreApiServiceDebug on StoreApiService {
  /// Test all store endpoints for debugging
  Future<Map<String, bool>> testAllEndpoints() async {
    final results = <String, bool>{};

    try {
      // Test store items endpoint
      results['GET /store/'] = await testConnection();

      // Test coins endpoint
      try {
        await getUserCoins();
        results['GET /users/coins'] = true;
      } catch (e) {
        results['GET /users/coins'] = false;
      }

      // Test purchased items endpoint
      try {
        await getPurchasedItems();
        results['GET /users/purchasedItems'] = true;
      } catch (e) {
        results['GET /users/purchasedItems'] = false;
      }

      debugPrint('🔍 Endpoint test results: $results');
      return results;
    } catch (e) {
      debugPrint('❌ Error testing endpoints: $e');
      return results;
    }
  }
}
