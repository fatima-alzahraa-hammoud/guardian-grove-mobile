import 'package:flutter/material.dart';
import 'package:flutter_app/core/network/store_api_service.dart';
import 'package:flutter_app/data/models/store_model.dart';
import 'package:flutter_app/presentation/bloc/store_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StoreBloc()..add(LoadStoreData()),
      child: const StoreView(),
    );
  }
}

class StoreView extends StatefulWidget {
  const StoreView({super.key});

  @override
  State<StoreView> createState() => _StoreViewState();
}

class _StoreViewState extends State<StoreView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Debug API on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _testStoreAPI();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A202C)),
        ),
        title: const Text(
          'Magic Store',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A202C),
          ),
        ),
        actions: [
          // Debug button
          IconButton(
            onPressed: () => _debugStoreState(context),
            icon: const Icon(Icons.bug_report, color: Color(0xFF1A202C)),
            tooltip: 'Debug Store',
          ),
          // Refresh button
          IconButton(
            onPressed: () => context.read<StoreBloc>().add(RefreshStoreData()),
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1A202C)),
          ),
        ],
      ),
      body: BlocConsumer<StoreBloc, StoreState>(
        listener: (context, state) {
          if (state is StorePurchaseSuccess) {
            _showSuccessMessage(context, state.message);
          } else if (state is StoreError) {
            _showErrorMessage(context, state.message);
          }
        },
        builder: (context, state) {
          debugPrint('🏪 Store State: ${state.runtimeType}');

          if (state is StoreLoading) {
            return _buildLoadingState(state.message);
          } else if (state is StoreLoaded) {
            return _buildStoreContent(context, state, isTablet);
          } else if (state is StorePurchasing) {
            return _buildPurchasingOverlay(context, state);
          } else if (state is StoreError) {
            return _buildErrorState(context, state.message);
          }

          // Default loading state
          return _buildLoadingState('Initializing store...');
        },
      ),
    );
  }

  Widget _buildLoadingState(String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF0EA5E9)),
          const SizedBox(height: 16),
          Text(
            message ?? 'Loading store...',
            style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreContent(
    BuildContext context,
    StoreLoaded state,
    bool isTablet,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<StoreBloc>().add(RefreshStoreData());
      },
      color: const Color(0xFF0EA5E9),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Header section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: _buildHeaderSection(state.userCoins, isTablet),
            ),
          ),

          // Categories section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
              child: _buildCategoriesSection(
                context,
                state.currentFilter,
                isTablet,
              ),
            ),
          ),

          // Items grid
          SliverPadding(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            sliver: _buildItemsSliver(context, state, isTablet),
          ),

          // Bottom padding for safe area
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(int coins, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to your Magic Store',
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Spend your hard-earned coins to customize your Magic Garden!',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.white,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Coin display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC85B),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  color: Color(0xFF1A202C),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '$coins',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'coins',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A202C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(
    BuildContext context,
    StoreFilter currentFilter,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Categories',
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A202C),
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal scrolling categories
        SizedBox(
          height: isTablet ? 50 : 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: StoreFilter.values.length,
            itemBuilder: (context, index) {
              final filter = StoreFilter.values[index];
              final isSelected = filter == currentFilter;

              return Padding(
                padding: EdgeInsets.only(right: 12, left: index == 0 ? 0 : 0),
                child: _buildCategoryChip(
                  context,
                  filter,
                  isSelected,
                  isTablet,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    StoreFilter filter,
    bool isSelected,
    bool isTablet,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.read<StoreBloc>().add(ChangeStoreFilter(filter));
        },
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 14 : 12,
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0EA5E9) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color:
                  isSelected
                      ? const Color(0xFF0EA5E9)
                      : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
          ),
          child: Text(
            filter.displayName,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF1A202C),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemsSliver(
    BuildContext context,
    StoreLoaded state,
    bool isTablet,
  ) {
    if (state.filteredItems.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(state.currentFilter, isTablet),
      );
    }

    // Responsive grid
    int crossAxisCount = 2;
    if (isTablet) {
      crossAxisCount = 3;
    }
    if (MediaQuery.of(context).size.width > 1200) {
      crossAxisCount = 4;
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isTablet ? 0.75 : 0.7, // Make cards taller
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = state.filteredItems[index];
        return _buildStoreItemCard(context, item, state.userCoins, isTablet);
      }, childCount: state.filteredItems.length),
    );
  }

  Widget _buildStoreItemCard(
    BuildContext context,
    StoreItem item,
    int userCoins,
    bool isTablet,
  ) {
    final canAfford = userCoins >= item.price && !item.isPurchased;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image section - LESS SPACE
          Expanded(
            flex: 4, // Changed from 5 to 4 (less space for image)
            child: Container(
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child:
                        item.image.isNotEmpty && item.image.startsWith('http')
                            ? ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Image.network(
                                item.image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                      color: item.color,
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                                errorBuilder:
                                    (context, error, stackTrace) => Icon(
                                      item.icon,
                                      color: item.color,
                                      size:
                                          isTablet
                                              ? 40
                                              : 32, // Balanced icon size
                                    ),
                              ),
                            )
                            : Icon(
                              item.icon,
                              color: item.color,
                              size: isTablet ? 40 : 32, // Balanced icon size
                            ),
                  ),

                  // Purchase status badge
                  if (item.isPurchased)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'OWNED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 10 : 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content section - MORE SPACE
          Expanded(
            flex: 5, // Changed from 4 to 5 (more space for content)
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item name
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A202C),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Type badge
                  if (item.type.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: isTablet ? 9 : 8,
                          fontWeight: FontWeight.w600,
                          color: item.color,
                        ),
                      ),
                    ),

                  const Spacer(), // Push price and button to bottom
                  // Price section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.monetization_on_rounded,
                          color: const Color(0xFFF59E0B),
                          size: isTablet ? 16 : 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.price}',
                          style: TextStyle(
                            fontSize: isTablet ? 15 : 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A202C),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Buy button - PROPERLY SIZED
                  SizedBox(
                    width: double.infinity,
                    height: isTablet ? 36 : 32,
                    child: _buildBuyButton(context, item, canAfford, isTablet),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyButton(
    BuildContext context,
    StoreItem item,
    bool canAfford,
    bool isTablet,
  ) {
    if (item.isPurchased) {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF10B981),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Owned',
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        // SHOW PURCHASE DIALOG INSTEAD OF DIRECT PURCHASE
        onTap: canAfford ? () => _showPurchaseDialog(context, item) : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:
                canAfford ? const Color(0xFF0EA5E9) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            canAfford ? 'Buy Now' : 'Not Enough',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: canAfford ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  // PURCHASE CONFIRMATION DIALOG
  void _showPurchaseDialog(BuildContext context, StoreItem item) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Purchase ${item.name}?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.description.isNotEmpty) ...[
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      color: Color(0xFFF59E0B),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.price} coins',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<StoreBloc>().add(
                  PurchaseItem(
                    itemId: item.id,
                    price: item.price,
                    itemName: item.name,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Buy Now',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(StoreFilter currentFilter, bool isTablet) {
    String title = 'No items available';
    String subtitle = 'Check back later for new items!';
    IconData icon = Icons.store_rounded;

    if (currentFilter == StoreFilter.purchased) {
      title = 'No purchased items yet';
      subtitle = 'Start shopping to see your purchases here!';
      icon = Icons.shopping_bag_outlined;
    } else if (currentFilter != StoreFilter.all) {
      title = 'No ${currentFilter.displayName.toLowerCase()} available';
      subtitle = 'Try browsing other categories or check back later!';
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 48 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isTablet ? 120 : 100,
              color: const Color(0xFFE2E8F0),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A202C),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed:
                  () => context.read<StoreBloc>().add(RefreshStoreData()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Refresh Store',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchasingOverlay(BuildContext context, StorePurchasing state) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF0EA5E9)),
              const SizedBox(height: 16),
              Text(
                'Purchasing ${state.itemName}...',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A202C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we process your order',
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A202C),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<StoreBloc>().add(LoadStoreData()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Debug methods
  void _debugStoreState(BuildContext context) {
    final bloc = context.read<StoreBloc>();
    final state = bloc.state;

    debugPrint('\n🔍 === STORE DEBUG ===');
    debugPrint('Current state: ${state.runtimeType}');

    if (state is StoreLoaded) {
      debugPrint('📊 Store Stats:');
      debugPrint('  All items: ${state.allItems.length}');
      debugPrint('  Filtered items: ${state.filteredItems.length}');
      debugPrint('  User coins: ${state.userCoins}');
      debugPrint('  Purchased IDs: ${state.purchasedItemIds}');
      debugPrint('  Current filter: ${state.currentFilter.displayName}');

      debugPrint('\n🛍️ All Items:');
      for (final item in state.allItems) {
        debugPrint(
          '  - ${item.name} (${item.type}) - ${item.price} coins - Purchased: ${item.isPurchased}',
        );
      }

      debugPrint('\n🔍 Filtered Items:');
      for (final item in state.filteredItems) {
        debugPrint('  - ${item.name} (${item.type}) - ${item.price} coins');
      }

      // Test purchase filter specifically
      if (state.currentFilter == StoreFilter.purchased) {
        debugPrint('\n🛒 Purchase Filter Test:');
        final purchasedItems =
            state.allItems
                .where(
                  (item) =>
                      item.isPurchased ||
                      state.purchasedItemIds.contains(item.id),
                )
                .toList();
        debugPrint('  Manual filter result: ${purchasedItems.length} items');
        for (final item in purchasedItems) {
          debugPrint(
            '    - ${item.name} (isPurchased: ${item.isPurchased}, inList: ${state.purchasedItemIds.contains(item.id)})',
          );
        }
      }
    } else if (state is StoreError) {
      debugPrint('❌ Error: ${state.message}');
      debugPrint('❌ Type: ${state.type}');
    } else if (state is StoreLoading) {
      debugPrint('⏳ Loading: ${state.message}');
    }

    debugPrint('=== END DEBUG ===\n');

    // Show debug info in UI
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Store Debug Info'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('State: ${state.runtimeType}'),
                  if (state is StoreLoaded) ...[
                    Text('Items: ${state.allItems.length}'),
                    Text('Filtered: ${state.filteredItems.length}'),
                    Text('Coins: ${state.userCoins}'),
                    Text('Filter: ${state.currentFilter.displayName}'),
                    Text('Purchased IDs: ${state.purchasedItemIds.join(", ")}'),
                  ],
                  if (state is StoreError) ...[
                    Text('Error: ${state.message}'),
                    Text('Type: ${state.type}'),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _testStoreAPI() async {
    debugPrint('🧪 === MANUAL STORE API TEST ===');

    final storeService = StoreApiService();
    storeService.init();

    try {
      // Test connection
      final isConnected = await storeService.testConnection();
      debugPrint('Connection test: ${isConnected ? '✅' : '❌'}');

      // Test each endpoint
      final items = await storeService.getStoreItems();
      debugPrint('Items test: ✅ ${items.length} items');
      for (final item in items) {
        debugPrint('  - ${item.name} (${item.type}) - ${item.price} coins');
      }

      final coins = await storeService.getUserCoins();
      debugPrint('Coins test: ✅ $coins coins');

      final purchased = await storeService.getPurchasedItems();
      debugPrint('Purchased test: ✅ ${purchased.length} items: $purchased');
    } catch (e) {
      debugPrint('❌ API test failed: $e');
    }

    debugPrint('🧪 === END API TEST ===');
  }
}
