import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grocery_price_scanner/features/stores/presentation/pages/store_products_page.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/store.dart';
import '../bloc/store_bloc.dart';
import '../bloc/store_event.dart';
import '../bloc/store_state.dart';

class StoresPage extends StatelessWidget {
  const StoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StoreBloc>()..add(LoadStores()),
      child: const _StoresView(),
    );
  }
}

class _StoresView extends StatelessWidget {
  const _StoresView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nearby Stores'),
            Text(
              'Find the best prices near you',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
        actions: [
          _AppBarIconButton(
            icon: Icons.location_on_outlined,
            onTap: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<StoreBloc, StoreState>(
        builder: (context, state) {
          if (state is StoreLoading) {
            return Center(
                child: CircularProgressIndicator(color: colorScheme.primary));
          }
          if (state is StoreError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: colorScheme.onSurface.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(state.message,
                      style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6))),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<StoreBloc>().add(LoadStores()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is StoreLoaded) {
            if (state.stores.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store_outlined,
                        size: 64,
                        color: colorScheme.onSurface.withOpacity(0.25)),
                    const SizedBox(height: 16),
                    Text('No stores available',
                        style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.5))),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: state.stores.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) {
                return _StoreCard(store: state.stores[index])
                    .animate(delay: Duration(milliseconds: index * 60))
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: 0.05);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final Store store;
  const _StoreCard({required this.store});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showStoreDetailsBottomSheet(context, store),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.onSurface.withOpacity(isDark ? 0.1 : 0.08),
            width: 0.5,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: store.logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(store.logoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _StoreInitial(name: store.name)),
                  )
                : _StoreInitial(name: store.name),
          ),
          title: Text(store.name,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (store.city != null)
                Text(store.city!,
                    style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 13)),
              if (store.website != null)
                Text(store.website!,
                    style: TextStyle(color: colorScheme.primary, fontSize: 12)),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: store.isActive
                  ? colorScheme.primary.withOpacity(0.12)
                  : colorScheme.onSurface.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              store.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: store.isActive
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.4),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showStoreDetailsBottomSheet(BuildContext context, Store store) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _StoreDetailsBottomSheet(store: store),
    );
  }
}

class _StoreDetailsBottomSheet extends StatelessWidget {
  final Store store;

  const _StoreDetailsBottomSheet({required this.store});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store Header
                      Center(
                        child: Column(
                          children: [
                            // Store Logo
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: colorScheme.primary.withOpacity(0.2),
                                  width: 2,
                                ),
                              ),
                              child: store.logoUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(22),
                                      child: Image.network(
                                        store.logoUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Center(
                                          child: Text(
                                            store.name
                                                .substring(0, 1)
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme
                                                  .onPrimaryContainer,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        store.name
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 16),
                            // Store Name
                            Text(
                              store.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: store.isActive
                                    ? colorScheme.primary.withOpacity(0.12)
                                    : colorScheme.error.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                store.isActive
                                    ? 'Open for Business'
                                    : 'Temporarily Closed',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: store.isActive
                                      ? colorScheme.primary
                                      : colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Store Information Section
                      Text(
                        'Store Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Location
                      if (store.city != null || store.address != null)
                        _InfoTile(
                          icon: Icons.location_on_outlined,
                          title: 'Location',
                          content: [
                            if (store.city != null) store.city!,
                            if (store.address != null) store.address!,
                          ].join(', '),
                          colorScheme: colorScheme,
                        ),

                      // Phone
                      if (store.phone != null)
                        _InfoTile(
                          icon: Icons.phone_outlined,
                          title: 'Phone',
                          content: store.phone!,
                          colorScheme: colorScheme,
                          isClickable: true,
                          onTap: () {
                            // TODO: Launch phone dialer
                            // final url = Uri.parse('tel:${store.phone}');
                            // if (await canLaunchUrl(url)) await launchUrl(url);
                          },
                        ),

                      // Website
                      if (store.website != null)
                        _InfoTile(
                          icon: Icons.language_outlined,
                          title: 'Website',
                          content: store.website!,
                          colorScheme: colorScheme,
                          isClickable: true,
                          onTap: () {
                            // TODO: Launch website
                            // final url = Uri.parse(store.website!);
                            // if (await canLaunchUrl(url)) await launchUrl(url);
                          },
                        ),

                      // Store ID
                      _InfoTile(
                        icon: Icons.qr_code_outlined,
                        title: 'Store ID',
                        content: store.id,
                        colorScheme: colorScheme,
                      ),

                      // Created Date
                      if (store.createdAt != null)
                        _InfoTile(
                          icon: Icons.calendar_today_outlined,
                          title: 'Member Since',
                          content: _formatDate(store.createdAt!),
                          colorScheme: colorScheme,
                        ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Close'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // In the "View Products" button onTap
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context); // Close bottom sheet
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StoreProductsPage(
                                      storeId: store.id,
                                      storeName: store.name,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.shopping_bag_outlined,
                                  size: 18),
                              label: const Text('View Products'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final ColorScheme colorScheme;
  final bool isClickable;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.content,
    required this.colorScheme,
    this.isClickable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 4),
                if (isClickable)
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      content,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                      ),
                    ),
                  )
                else
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreInitial extends StatelessWidget {
  final String name;
  const _StoreInitial({required this.name});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Text(
        name.substring(0, 1).toUpperCase(),
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AppBarIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child:
            Icon(icon, size: 20, color: colorScheme.onSurface.withOpacity(0.7)),
      ),
    );
  }
}
