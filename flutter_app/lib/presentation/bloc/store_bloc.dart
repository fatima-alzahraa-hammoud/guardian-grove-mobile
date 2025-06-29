import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/store_api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../data/models/store_model.dart';

// Events
abstract class StoreEvent extends Equatable {
  const StoreEvent();
  @override
  List<Object?> get props => [];
}

class LoadStoreData extends StoreEvent {}

class RefreshStoreData extends StoreEvent {}

class ChangeStoreFilter extends StoreEvent {
  final StoreFilter filter;
  const ChangeStoreFilter(this.filter);
  @override
  List<Object?> get props => [filter];
}

class PurchaseItem extends StoreEvent {
  final String itemId;
  final int price;
  const PurchaseItem(this.itemId, this.price);
  @override
  List<Object?> get props => [itemId, price];
}

class LoadPurchasedItems extends StoreEvent {}

// States
abstract class StoreState extends Equatable {
  const StoreState();
  @override
  List<Object?> get props => [];
}

class StoreInitial extends StoreState {}

class StoreLoading extends StoreState {}

class StoreLoaded extends StoreState {
  final List<StoreItem> allItems;
  final List<StoreItem> filteredItems;
  final List<String> purchasedItemIds;
  final StoreFilter currentFilter;
  final int userCoins;

  const StoreLoaded({
    required this.allItems,
    required this.filteredItems,
    required this.purchasedItemIds,
    required this.currentFilter,
    required this.userCoins,
  });

  @override
  List<Object?> get props => [
    allItems,
    filteredItems,
    purchasedItemIds,
    currentFilter,
    userCoins,
  ];

  StoreLoaded copyWith({
    List<StoreItem>? allItems,
    List<StoreItem>? filteredItems,
    List<String>? purchasedItemIds,
    StoreFilter? currentFilter,
    int? userCoins,
  }) {
    return StoreLoaded(
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      purchasedItemIds: purchasedItemIds ?? this.purchasedItemIds,
      currentFilter: currentFilter ?? this.currentFilter,
      userCoins: userCoins ?? this.userCoins,
    );
  }
}

class StorePurchasing extends StoreState {
  final String itemId;
  const StorePurchasing(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

class StorePurchaseSuccess extends StoreState {
  final String message;
  final StoreItem purchasedItem;
  final int newCoinBalance;

  const StorePurchaseSuccess({
    required this.message,
    required this.purchasedItem,
    required this.newCoinBalance,
  });

  @override
  List<Object?> get props => [message, purchasedItem, newCoinBalance];
}

class StoreError extends StoreState {
  final String message;
  const StoreError(this.message);
  @override
  List<Object?> get props => [message];
}

// Store Bloc
class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final StoreApiService _storeApiService;

  StoreBloc({StoreApiService? storeApiService})
    : _storeApiService = storeApiService ?? StoreApiService(),
      super(StoreInitial()) {
    _storeApiService.init();

    on<LoadStoreData>(_onLoadStoreData);
    on<RefreshStoreData>(_onRefreshStoreData);
    on<ChangeStoreFilter>(_onChangeStoreFilter);
    on<PurchaseItem>(_onPurchaseItem);
    on<LoadPurchasedItems>(_onLoadPurchasedItems);
  }

  Future<void> _onLoadStoreData(
    LoadStoreData event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoreLoading());
    try {
      // Load store items, user coins, and purchased items separately
      final items = await _storeApiService.getStoreItems();
      final coins = await _storeApiService.getUserCoins();
      final purchasedIds = await _loadPurchasedItems();

      // Mark purchased items
      final itemsWithPurchaseStatus =
          items
              .map(
                (item) =>
                    item.copyWith(isPurchased: purchasedIds.contains(item.id)),
              )
              .toList();

      emit(
        StoreLoaded(
          allItems: itemsWithPurchaseStatus,
          filteredItems: itemsWithPurchaseStatus,
          purchasedItemIds: purchasedIds,
          currentFilter: StoreFilter.all,
          userCoins: coins,
        ),
      );
    } catch (e) {
      debugPrint('❌ StoreBloc: Error loading store data: $e');
      emit(StoreError('Failed to load store data: $e'));
    }
  }

  Future<void> _onRefreshStoreData(
    RefreshStoreData event,
    Emitter<StoreState> emit,
  ) async {
    if (state is StoreLoaded) {
      final currentState = state as StoreLoaded;

      try {
        // Refresh data while keeping current filter - load separately
        final items = await _storeApiService.getStoreItems();
        final coins = await _storeApiService.getUserCoins();
        final purchasedIds = await _loadPurchasedItems();

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

        emit(
          StoreLoaded(
            allItems: itemsWithPurchaseStatus,
            filteredItems: filteredItems,
            purchasedItemIds: purchasedIds,
            currentFilter: currentState.currentFilter,
            userCoins: coins,
          ),
        );
      } catch (e) {
        emit(StoreError('Failed to refresh store data: $e'));
      }
    }
  }

  void _onChangeStoreFilter(ChangeStoreFilter event, Emitter<StoreState> emit) {
    if (state is StoreLoaded) {
      final currentState = state as StoreLoaded;
      final filteredItems = _filterItems(
        currentState.allItems,
        currentState.purchasedItemIds,
        event.filter,
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
    if (state is StoreLoaded) {
      final currentState = state as StoreLoaded;

      // Emit purchasing state
      emit(StorePurchasing(event.itemId));

      try {
        final result = await _storeApiService.buyItem(event.itemId);

        if (result['success'] == true) {
          // Find the purchased item
          final purchasedItem = currentState.allItems.firstWhere(
            (item) => item.id == event.itemId,
          );

          // Update purchased items list
          final updatedPurchasedIds = [
            ...currentState.purchasedItemIds,
            event.itemId,
          ];

          // Update user coins
          final newCoinBalance = currentState.userCoins - event.price;

          // Update user data in storage
          final currentUser = StorageService.getUser();
          if (currentUser != null) {
            final updatedUser = currentUser.copyWith(coins: newCoinBalance);
            StorageService.saveUser(updatedUser);
          }

          // Mark item as purchased
          final updatedItems =
              currentState.allItems
                  .map(
                    (item) =>
                        item.id == event.itemId
                            ? item.copyWith(isPurchased: true)
                            : item,
                  )
                  .toList();

          // Apply current filter to updated items
          final filteredItems = _filterItems(
            updatedItems,
            updatedPurchasedIds,
            currentState.currentFilter,
          );

          // Emit success state first
          emit(
            StorePurchaseSuccess(
              message:
                  result['message'] ??
                  'Successfully purchased ${purchasedItem.name}!',
              purchasedItem: purchasedItem,
              newCoinBalance: newCoinBalance,
            ),
          );

          // Then emit updated store state
          emit(
            StoreLoaded(
              allItems: updatedItems,
              filteredItems: filteredItems,
              purchasedItemIds: updatedPurchasedIds,
              currentFilter: currentState.currentFilter,
              userCoins: newCoinBalance,
            ),
          );
        } else {
          emit(StoreError(result['message'] ?? 'Failed to purchase item'));
          // Return to previous state
          emit(currentState);
        }
      } catch (e) {
        emit(StoreError('Purchase failed: $e'));
        // Return to previous state
        emit(currentState);
      }
    }
  }

  Future<void> _onLoadPurchasedItems(
    LoadPurchasedItems event,
    Emitter<StoreState> emit,
  ) async {
    try {
      final purchasedIds = await _loadPurchasedItems();

      if (state is StoreLoaded) {
        final currentState = state as StoreLoaded;

        // Update items with purchase status
        final updatedItems =
            currentState.allItems
                .map(
                  (item) => item.copyWith(
                    isPurchased: purchasedIds.contains(item.id),
                  ),
                )
                .toList();

        // Apply current filter
        final filteredItems = _filterItems(
          updatedItems,
          purchasedIds,
          currentState.currentFilter,
        );

        emit(
          currentState.copyWith(
            allItems: updatedItems,
            filteredItems: filteredItems,
            purchasedItemIds: purchasedIds,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ StoreBloc: Error loading purchased items: $e');
    }
  }

  // Helper method to filter items based on selected filter
  List<StoreItem> _filterItems(
    List<StoreItem> items,
    List<String> purchasedIds,
    StoreFilter filter,
  ) {
    switch (filter) {
      case StoreFilter.purchased:
        return items.where((item) => purchasedIds.contains(item.id)).toList();
      case StoreFilter.all:
        return items;
      default:
        return items
            .where(
              (item) =>
                  item.type.toLowerCase() == filter.filterValue.toLowerCase(),
            )
            .toList();
    }
  }

  // Helper method to load purchased items from API
  Future<List<String>> _loadPurchasedItems() async {
    try {
      return await _storeApiService.getPurchasedItems();
    } catch (e) {
      debugPrint('❌ StoreBloc: Error loading purchased items: $e');
      return [];
    }
  }
}
