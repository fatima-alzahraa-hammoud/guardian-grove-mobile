import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/network/store_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/store_model.dart';
import '../../data/models/user_model.dart';

// Events
abstract class StoreEvent extends Equatable {
  const StoreEvent();
  @override
  List<Object?> get props => [];
}

class LoadStoreData extends StoreEvent {
  const LoadStoreData();
}

class RefreshStoreData extends StoreEvent {
  const RefreshStoreData();
}

class ChangeStoreFilter extends StoreEvent {
  final StoreFilter filter;
  const ChangeStoreFilter(this.filter);
  @override
  List<Object?> get props => [filter];
}

class PurchaseItem extends StoreEvent {
  final String itemId;
  final int price;
  final String itemName;

  const PurchaseItem({
    required this.itemId,
    required this.price,
    required this.itemName,
  });

  @override
  List<Object?> get props => [itemId, price, itemName];
}

class LoadPurchasedItems extends StoreEvent {
  const LoadPurchasedItems();
}

class TestStoreConnection extends StoreEvent {
  const TestStoreConnection();
}

class ResetStoreError extends StoreEvent {
  const ResetStoreError();
}

// States
abstract class StoreState extends Equatable {
  const StoreState();
  @override
  List<Object?> get props => [];
}

class StoreInitial extends StoreState {
  const StoreInitial();
}

class StoreLoading extends StoreState {
  final String? message;
  const StoreLoading({this.message});
  @override
  List<Object?> get props => [message];
}

class StoreLoaded extends StoreState {
  final List<StoreItem> allItems;
  final List<StoreItem> filteredItems;
  final List<String> purchasedItemIds;
  final StoreFilter currentFilter;
  final int userCoins;
  final StoreStats stats;
  final StoreConfig config;
  final DateTime lastUpdated;

  const StoreLoaded({
    required this.allItems,
    required this.filteredItems,
    required this.purchasedItemIds,
    required this.currentFilter,
    required this.userCoins,
    required this.stats,
    required this.config,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
    allItems,
    filteredItems,
    purchasedItemIds,
    currentFilter,
    userCoins,
    stats,
    config,
    lastUpdated,
  ];

  StoreLoaded copyWith({
    List<StoreItem>? allItems,
    List<StoreItem>? filteredItems,
    List<String>? purchasedItemIds,
    StoreFilter? currentFilter,
    int? userCoins,
    StoreStats? stats,
    StoreConfig? config,
    DateTime? lastUpdated,
  }) {
    return StoreLoaded(
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      purchasedItemIds: purchasedItemIds ?? this.purchasedItemIds,
      currentFilter: currentFilter ?? this.currentFilter,
      userCoins: userCoins ?? this.userCoins,
      stats: stats ?? this.stats,
      config: config ?? this.config,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Helper getters
  bool get hasItems => allItems.isNotEmpty;
  bool get hasFilteredItems => filteredItems.isNotEmpty;
  int get totalItems => allItems.length;
  int get purchasedCount => purchasedItemIds.length;
  double get purchasePercentage =>
      totalItems > 0 ? (purchasedCount / totalItems) * 100 : 0.0;
}

class StorePurchasing extends StoreState {
  final String itemId;
  final String itemName;
  final int itemPrice;

  const StorePurchasing({
    required this.itemId,
    required this.itemName,
    required this.itemPrice,
  });

  @override
  List<Object?> get props => [itemId, itemName, itemPrice];
}

class StorePurchaseSuccess extends StoreState {
  final String message;
  final StoreItem purchasedItem;
  final int newCoinBalance;
  final int coinsSpent;
  final DateTime purchaseTime;

  const StorePurchaseSuccess({
    required this.message,
    required this.purchasedItem,
    required this.newCoinBalance,
    required this.coinsSpent,
    required this.purchaseTime,
  });

  @override
  List<Object?> get props => [
    message,
    purchasedItem,
    newCoinBalance,
    coinsSpent,
    purchaseTime,
  ];
}

class StoreConnectionTested extends StoreState {
  final bool isConnected;
  final Map<String, bool> endpointResults;
  final String message;

  const StoreConnectionTested({
    required this.isConnected,
    required this.endpointResults,
    required this.message,
  });

  @override
  List<Object?> get props => [isConnected, endpointResults, message];
}

class StoreError extends StoreState {
  final String message;
  final String? errorCode;
  final StoreErrorType type;
  final dynamic details;
  final DateTime timestamp;

  const StoreError({
    required this.message,
    this.errorCode,
    required this.type,
    this.details,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [message, errorCode, type, details, timestamp];

  // Factory constructors for different error types
  factory StoreError.network(String message) {
    return StoreError(
      message: message,
      type: StoreErrorType.network,
      timestamp: DateTime.now(),
    );
  }

  factory StoreError.authentication(String message) {
    return StoreError(
      message: message,
      type: StoreErrorType.authentication,
      timestamp: DateTime.now(),
    );
  }

  factory StoreError.server(String message, {String? errorCode}) {
    return StoreError(
      message: message,
      errorCode: errorCode,
      type: StoreErrorType.server,
      timestamp: DateTime.now(),
    );
  }

  factory StoreError.unknown(String message, {dynamic details}) {
    return StoreError(
      message: message,
      type: StoreErrorType.unknown,
      details: details,
      timestamp: DateTime.now(),
    );
  }
}

enum StoreErrorType {
  network,
  authentication,
  server,
  purchase,
  parsing,
  unknown,
}

// Store Bloc
class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final StoreApiService _storeApiService;

  StoreBloc({StoreApiService? storeApiService})
    : _storeApiService = storeApiService ?? StoreApiService(),
      super(const StoreInitial()) {
    // Initialize the API service
    _storeApiService.init();

    // Register event handlers
    on<LoadStoreData>(_onLoadStoreData);
    on<RefreshStoreData>(_onRefreshStoreData);
    on<ChangeStoreFilter>(_onChangeStoreFilter);
    on<PurchaseItem>(_onPurchaseItem);
    on<LoadPurchasedItems>(_onLoadPurchasedItems);
    on<TestStoreConnection>(_onTestStoreConnection);
    on<ResetStoreError>(_onResetStoreError);

    debugPrint('🏪 StoreBloc initialized');
  }

  // Helper method to filter items based on selected filter
  List<StoreItem> _filterItems(
    List<StoreItem> items,
    List<String> purchasedIds,
    StoreFilter filter,
  ) {
    return items.where((item) => filter.matches(item, purchasedIds)).toList();
  }

  Future<void> _onLoadStoreData(
    LoadStoreData event,
    Emitter<StoreState> emit,
  ) async {
    debugPrint('🔄 StoreBloc: Loading store data...');
    emit(const StoreLoading(message: 'Loading store...'));
    try {
      // Initialize with default values
      List<StoreItem> items = [];
      int coins = 0;
      List<String> purchasedIds = [];
      StoreConfig config = StoreConfig();
      // Load each piece of data individually with error handling
      debugPrint('📦 Loading store items...');
      try {
        items = await _storeApiService.getStoreItems();
        debugPrint('✅ Store items loaded: [32m${items.length}[0m');
      } catch (e) {
        debugPrint('❌ Store items failed: $e');
      }
      debugPrint('💰 Loading user coins...');
      try {
        coins = await _storeApiService.getUserCoins();
        debugPrint('✅ User coins loaded: $coins');
      } catch (e) {
        debugPrint('❌ User coins failed: $e');
      }
      debugPrint('🛍️ Loading purchased items...');
      try {
        purchasedIds = await _storeApiService.getPurchasedItems();
        debugPrint('✅ Purchased items loaded: ${purchasedIds.length}');
      } catch (e) {
        debugPrint('❌ Purchased items failed: $e');
      }
      debugPrint('⚙️ Loading store config...');
      try {
        config = await _storeApiService.getStoreConfig();
        debugPrint('✅ Store config loaded');
      } catch (e) {
        debugPrint('❌ Store config failed, using defaults: $e');
      }
      // Mark purchased items in the items list
      final itemsWithPurchaseStatus =
          items
              .map(
                (item) =>
                    item.copyWith(isPurchased: purchasedIds.contains(item.id)),
              )
              .toList();
      // Calculate statistics
      final stats = StoreStats.fromItems(itemsWithPurchaseStatus);
      // Always emit loaded state, even if some data failed to load
      emit(
        StoreLoaded(
          allItems: itemsWithPurchaseStatus,
          filteredItems: itemsWithPurchaseStatus,
          purchasedItemIds: purchasedIds,
          currentFilter: StoreFilter.all,
          userCoins: coins,
          stats: stats,
          config: config,
          lastUpdated: DateTime.now(),
        ),
      );
      debugPrint('✅ StoreBloc: Store data loaded successfully');
      debugPrint('📊 Final summary:');
      debugPrint('   - Items: ${itemsWithPurchaseStatus.length}');
      debugPrint('   - Coins: $coins');
      debugPrint('   - Purchased: ${purchasedIds.length}');
    } catch (e, stackTrace) {
      debugPrint('❌ StoreBloc: Unexpected error during load: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      emit(StoreError.unknown('Failed to load store: $e', details: e));
    }
  }

  Future<void> _onRefreshStoreData(
    RefreshStoreData event,
    Emitter<StoreState> emit,
  ) async {
    debugPrint('🔄 StoreBloc: Refreshing store data...');

    if (state is StoreLoaded) {
      final currentState = state as StoreLoaded;

      // Show loading with current data still visible
      emit(const StoreLoading(message: 'Refreshing...'));

      try {
        // Load fresh data
        final results = await Future.wait([
          _storeApiService.getStoreItems(),
          _storeApiService.getUserCoins(),
          _storeApiService.getPurchasedItems(),
        ]);

        final items = results[0] as List<StoreItem>;
        final coins = results[1] as int;
        final purchasedIds = results[2] as List<String>;

        // Mark purchased items
        final itemsWithPurchaseStatus =
            items
                .map(
                  (item) => item.copyWith(
                    isPurchased: purchasedIds.contains(item.id),
                  ),
                )
                .toList();

        // Apply current filter
        final filteredItems = _filterItems(
          itemsWithPurchaseStatus,
          purchasedIds,
          currentState.currentFilter,
        );

        // Calculate new statistics
        final stats = StoreStats.fromItems(itemsWithPurchaseStatus);

        // Emit updated state
        emit(
          currentState.copyWith(
            allItems: itemsWithPurchaseStatus,
            filteredItems: filteredItems,
            purchasedItemIds: purchasedIds,
            userCoins: coins,
            stats: stats,
            lastUpdated: DateTime.now(),
          ),
        );

        debugPrint('✅ StoreBloc: Store data refreshed successfully');
      } on StoreApiException catch (e) {
        debugPrint(
          '❌ StoreBloc: API error refreshing store data: ${e.message}',
        );
        emit(StoreError.server(e.message, errorCode: e.code));
      } catch (e) {
        debugPrint('❌ StoreBloc: Error refreshing store data: $e');
        emit(StoreError.unknown('Failed to refresh store: $e'));
      }
    } else {
      // If not in loaded state, just do a full load
      add(const LoadStoreData());
    }
  }

  void _onChangeStoreFilter(ChangeStoreFilter event, Emitter<StoreState> emit) {
    debugPrint('🔄 StoreBloc: Changing filter to ${event.filter.displayName}');

    if (state is StoreLoaded) {
      final currentState = state as StoreLoaded;

      final filteredItems = _filterItems(
        currentState.allItems,
        currentState.purchasedItemIds,
        event.filter,
      );

      debugPrint(
        '📊 Filter result: ${filteredItems.length} items for ${event.filter.displayName}',
      );

      emit(
        currentState.copyWith(
          filteredItems: filteredItems,
          currentFilter: event.filter,
        ),
      );
    }
  }

  Future<void> _onPurchaseItem(
    PurchaseItem event,
    Emitter<StoreState> emit,
  ) async {
    debugPrint(
      '💰 StoreBloc: Attempting to purchase ${event.itemName} (${event.itemId})',
    );

    if (state is! StoreLoaded) {
      emit(StoreError.unknown('Cannot purchase: Store not loaded'));
      return;
    }

    final currentState = state as StoreLoaded;

    // Check if user has enough coins
    if (currentState.userCoins < event.price) {
      emit(
        StoreError(
          message:
              'Insufficient coins. You need ${event.price} coins but only have ${currentState.userCoins}.',
          type: StoreErrorType.purchase,
          timestamp: DateTime.now(),
        ),
      );
      return;
    }

    // Find the item being purchased
    late StoreItem item;
    try {
      item = currentState.allItems.firstWhere(
        (item) => item.id == event.itemId,
      );
    } catch (e) {
      emit(StoreError.unknown('Item not found'));
      return;
    }

    // Emit purchasing state
    emit(
      StorePurchasing(
        itemId: event.itemId,
        itemName: event.itemName,
        itemPrice: event.price,
      ),
    );

    try {
      // Make purchase request
      final result = await _storeApiService.buyItem(event.itemId);

      if (result.success) {
        debugPrint('✅ StoreBloc: Purchase successful for ${event.itemName}');

        // Update purchased items list
        final updatedPurchasedIds = [
          ...currentState.purchasedItemIds,
          event.itemId,
        ];

        // Calculate new coin balance
        final newCoinBalance = currentState.userCoins - event.price;

        // FIXED: Update user using existing StorageService methods
        final currentUser = StorageService.getUser();
        if (currentUser != null) {
          try {
            // Create updated user object with new coin balance
            final userMap = currentUser.toJson();
            userMap['coins'] = newCoinBalance;
            final updatedUser = UserModel.fromJson(userMap);
            StorageService.saveUser(updatedUser);
            debugPrint('✅ User coins updated to $newCoinBalance');
          } catch (e) {
            debugPrint('⚠️ Could not update user coins in storage: $e');
            // Continue with purchase anyway
          }
        }

        // Mark item as purchased
        final updatedItems =
            currentState.allItems
                .map(
                  (storeItem) =>
                      storeItem.id == event.itemId
                          ? storeItem.copyWith(isPurchased: true)
                          : storeItem,
                )
                .toList();

        // Apply current filter to updated items
        final filteredItems = _filterItems(
          updatedItems,
          updatedPurchasedIds,
          currentState.currentFilter,
        );

        // Calculate new statistics
        final stats = StoreStats.fromItems(updatedItems);

        // Emit success state
        emit(
          StorePurchaseSuccess(
            message: result.message,
            purchasedItem: item,
            newCoinBalance: newCoinBalance,
            coinsSpent: event.price,
            purchaseTime: DateTime.now(),
          ),
        );

        // Then emit updated store state
        emit(
          currentState.copyWith(
            allItems: updatedItems,
            filteredItems: filteredItems,
            purchasedItemIds: updatedPurchasedIds,
            userCoins: newCoinBalance,
            stats: stats,
            lastUpdated: DateTime.now(),
          ),
        );
      } else {
        debugPrint(
          '❌ StoreBloc: Purchase failed for ${event.itemName}: ${result.message}',
        );
        emit(
          StoreError(
            message: result.message,
            type: StoreErrorType.purchase,
            timestamp: DateTime.now(),
          ),
        );
        // Return to previous state
        emit(currentState);
      }
    } on StoreApiException catch (e) {
      debugPrint('❌ StoreBloc: API error during purchase: ${e.message}');
      emit(StoreError.server(e.message, errorCode: e.code));
      emit(currentState);
    } catch (e) {
      debugPrint('❌ StoreBloc: Unexpected error during purchase: $e');
      emit(StoreError.unknown('Purchase failed: $e'));
      emit(currentState);
    }
  }

  Future<void> _onLoadPurchasedItems(
    LoadPurchasedItems event,
    Emitter<StoreState> emit,
  ) async {
    debugPrint('🔄 StoreBloc: Loading purchased items...');

    final purchasedIds = await _storeApiService.getPurchasedItems();

    if (state is StoreLoaded) {
      final currentState = state as StoreLoaded;

      // Update items with purchase status
      final updatedItems =
          currentState.allItems
              .map(
                (item) =>
                    item.copyWith(isPurchased: purchasedIds.contains(item.id)),
              )
              .toList();

      // Apply current filter
      final filteredItems = _filterItems(
        updatedItems,
        purchasedIds,
        currentState.currentFilter,
      );

      // Calculate new statistics
      final stats = StoreStats.fromItems(updatedItems);

      emit(
        currentState.copyWith(
          allItems: updatedItems,
          filteredItems: filteredItems,
          purchasedItemIds: purchasedIds,
          stats: stats,
          lastUpdated: DateTime.now(),
        ),
      );

      debugPrint('✅ StoreBloc: Purchased items updated');
    }
  }

  Future<void> _onTestStoreConnection(
    TestStoreConnection event,
    Emitter<StoreState> emit,
  ) async {
    debugPrint('🔍 StoreBloc: Testing store connection...');

    try {
      final results = await _storeApiService.testAllEndpoints();
      final isConnected = results.values.any((result) => result);

      final message =
          isConnected
              ? 'Store connection successful'
              : 'Store connection failed';

      emit(
        StoreConnectionTested(
          isConnected: isConnected,
          endpointResults: results,
          message: message,
        ),
      );

      debugPrint('✅ StoreBloc: Connection test completed - $message');
    } catch (e) {
      debugPrint('❌ StoreBloc: Connection test failed: $e');
      emit(
        StoreConnectionTested(
          isConnected: false,
          endpointResults: {},
          message: 'Connection test failed: $e',
        ),
      );
    }
  }

  void _onResetStoreError(ResetStoreError event, Emitter<StoreState> emit) {
    debugPrint('🔄 StoreBloc: Resetting error state');

    if (state is StoreError) {
      emit(const StoreInitial());
    }
  }

  void debugStoreState() {
    debugPrint('🔍 === STORE STATE DEBUG ===');
    debugPrint('Current state: [36m${state.runtimeType}[0m');
    if (state is StoreLoaded) {
      final loadedState = state as StoreLoaded;
      debugPrint('Items: ${loadedState.allItems.length}');
      debugPrint('Filtered: ${loadedState.filteredItems.length}');
      debugPrint('Coins: ${loadedState.userCoins}');
      debugPrint('Purchased: ${loadedState.purchasedItemIds.length}');
      debugPrint('Filter: ${loadedState.currentFilter.displayName}');
    } else if (state is StoreError) {
      final errorState = state as StoreError;
      debugPrint('Error: ${errorState.message}');
      debugPrint('Type: ${errorState.type}');
    } else if (state is StoreLoading) {
      final loadingState = state as StoreLoading;
      debugPrint('Loading: ${loadingState.message}');
    }
    debugPrint('=== END DEBUG ===');
  }

  @override
  Future<void> close() {
    debugPrint('🧹 StoreBloc: Disposing...');
    return super.close();
  }
}
