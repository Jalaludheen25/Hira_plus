import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../constants/color_class.dart';
import '../../../constants/textstyle_class.dart';
import '../provider/menu_provider.dart';
import '../models/menu_model.dart';
import 'food_menu_add_screen.dart';
import 'dart:async';

class FoodMenuListScreen extends StatefulWidget {
  const FoodMenuListScreen({Key? key}) : super(key: key);

  @override
  State<FoodMenuListScreen> createState() => _FoodMenuListScreenState();
}

class _FoodMenuListScreenState extends State<FoodMenuListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;
  Timer? _fabTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<MenuProvider>(context, listen: false).fetchAllMenus());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.isScrollingNotifier.value) {
      if (_isFabVisible) {
        setState(() => _isFabVisible = false);
      }
      _fabTimer?.cancel();
      _fabTimer = Timer(const Duration(milliseconds: 600), () {
        if (!_isFabVisible) {
          setState(() => _isFabVisible = true);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fabTimer?.cancel();
    super.dispose();
  }

  void _navigateToAddMenu() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: Provider.of<MenuProvider>(context, listen: false),
          child: const FoodMenuAddScreen(),
        ),
      ),
    );
    if (result == true) {
      Provider.of<MenuProvider>(context, listen: false)
        .fetchAllMenus();
    }
  }

  void _navigateToEditMenu(MenuModel menu) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: Provider.of<MenuProvider>(context, listen: false),
          child: FoodMenuAddScreen(editingMenu: menu),
        ),
      ),
    );
    if (result == true) {
      Provider.of<MenuProvider>(context, listen: false)
        .fetchAllMenus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: ColorClass.brandWhite,
          appBar: AppBar(
            title: Text('Food Menu List', style: TextStyleClass.poppinsSemiBold(fontSize: 20, color: ColorClass.white)),
            backgroundColor: ColorClass.brandDarkGreen,
            elevation: 0,
            iconTheme: const IconThemeData(color: ColorClass.white),
          ),
          body: _buildBody(provider),
          floatingActionButton: AnimatedSlide(
            duration: const Duration(milliseconds: 250),
            offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: _isFabVisible ? 1.0 : 0.0,
              child: FloatingActionButton.extended(
                onPressed: _navigateToAddMenu,
                backgroundColor: ColorClass.brandDarkGreen,
                foregroundColor: Colors.white,
                icon: const Icon(LucideIcons.plus),
                label: const Text('Add Food Menu'),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(MenuProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (provider.error != null) {
      return Center(
        child: Text(provider.error!, style: TextStyleClass.poppinsRegular(fontSize: 16, color: Colors.red)),
      );
    }
    if (provider.menus.isEmpty) {
      return Center(
        child: Text('No menus found.', style: TextStyleClass.poppinsRegular(fontSize: 16, color: ColorClass.neutral400)),
      );
    }
    final menus = provider.menus;
    return RefreshIndicator(
      onRefresh: () async {
        await provider.fetchAllMenus();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: menus.length,
        itemBuilder: (context, index) {
          return _buildMenuCard(menus[index]);
        },
      ),
    );
  }

  Widget _buildMenuCard(MenuModel menu) {
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(menu.date);
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: ColorClass.brandWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorClass.brandLightGreen.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: ColorClass.brandLightGreen.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(formattedDate, style: TextStyleClass.poppinsSemiBold(fontSize: 16, color: ColorClass.brandDarkGreen)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ColorClass.brandLightGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Added By: ${menu.addedBy}', style: TextStyleClass.poppinsSemiBold(fontSize: 12, color: ColorClass.brandDarkGreen)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMealInfo('Breakfast', menu.breakfast, LucideIcons.sunMedium),
                const SizedBox(height: 8),
                _buildMealInfo('Lunch', menu.lunch, LucideIcons.sun),
                const SizedBox(height: 8),
                _buildMealInfo('Dinner', menu.dinner, LucideIcons.moon),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToEditMenu(menu),
                        icon: Icon(LucideIcons.edit, size: 14, color: ColorClass.brandDarkGreen),
                        label: Text('Edit', style: TextStyleClass.poppinsMedium(fontSize: 12, color: ColorClass.brandDarkGreen)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: ColorClass.brandLightGreen),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Menu'),
                              content: const Text('Are you sure you want to delete this menu?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child:  Text('Delete',style: TextStyleClass.popinsDefault(color: ColorClass.redDark),),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            final provider = Provider.of<MenuProvider>(context, listen: false);
                            final success = await provider.deleteMenuByDate(DateFormat('yyyy-MM-dd').format(menu.date));
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Menu deleted successfully'), backgroundColor: Colors.green),
                              );
                              // Refresh the list after delete
                              await provider.fetchAllMenus();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to delete menu'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        icon: Icon(LucideIcons.trash2, size: 14, color: ColorClass.redDark),
                        label: Text('Delete', style: TextStyleClass.poppinsMedium(fontSize: 12, color: ColorClass.redDark)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: ColorClass.redLight),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Created: ${DateFormat('MMM d, h:mm a').format(menu.createdAt)}', style: TextStyleClass.poppinsRegular(fontSize: 11, color: ColorClass.neutral400)),
                    if (menu.createdAt != menu.updatedAt)
                      Text('Updated: ${DateFormat('MMM d, h:mm a').format(menu.updatedAt)}', style: TextStyleClass.poppinsRegular(fontSize: 11, color: ColorClass.neutral400)),
                  ],
                ),
                
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
    
  }

  Widget _buildMealInfo(String label, String value, IconData icon) {
    final hasValue = value.isNotEmpty;
    return Row(
      children: [
        Icon(icon, size: 18, color: hasValue ? ColorClass.brandDarkGreen : ColorClass.neutral300),
        const SizedBox(width: 8),
        Text(label, style: TextStyleClass.poppinsRegular(fontSize: 13, color: hasValue ? ColorClass.brandDarkGreen : ColorClass.neutral400)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, style: TextStyleClass.poppinsBold(fontSize: 14, color: hasValue ? ColorClass.brandDarkGreen : ColorClass.neutral400)),
        ),
      ],
    );
  }
} 