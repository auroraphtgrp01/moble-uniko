import 'package:flutter/material.dart';
import 'package:uniko/services/core/logger_service.dart';
import '../config/theme.config.dart';
import 'AddCategoryDrawer.dart';
import 'package:uniko/providers/category_provider.dart';
import 'package:provider/provider.dart';

class CategoryDrawer extends StatefulWidget {
  final String currentCategory;
  final Function(String) onCategorySelected;
  final bool isExpense;
  final bool autoPopOnSelect;

  const CategoryDrawer({
    super.key,
    required this.currentCategory,
    required this.onCategorySelected,
    required this.isExpense,
    this.autoPopOnSelect = true,
  });

  @override
  State<CategoryDrawer> createState() => _CategoryDrawerState();
}

class _CategoryDrawerState extends State<CategoryDrawer> {
  final searchController = TextEditingController();
  List<CategoryItem> filteredCategories = [];
  Set<String> addedCategories = {};

  @override
  void initState() {
    super.initState();
    updateCategories();
    searchController.addListener(() {
      filterCategories();
    });
  }

  void updateCategories() {
    final categories = context
        .read<CategoryProvider>()
        .getCategoriesByType(widget.isExpense ? 'EXPENSE' : 'INCOMING')
        .toList();

    filteredCategories = categories
        .map((cat) => CategoryItem(
              emoji: cat.name.split(' ')[0],
              name: cat.name,
              color: widget.isExpense ? Colors.red : const Color(0xFF34C759),
            ))
        .toList();
    print(filteredCategories.toString());
  }

  void filterCategories() {
    final query = searchController.text.toLowerCase();
    final allCategories = context
        .read<CategoryProvider>()
        .getCategoriesByType(widget.isExpense ? 'EXPENSE' : 'INCOMING')
        .toList();

    setState(() {
      filteredCategories = allCategories
          .map((cat) => CategoryItem(
                emoji: cat.name.split(' ')[0],
                name: cat.name,
                color: widget.isExpense ? Colors.red : const Color(0xFF34C759),
              ))
          .where((category) => category.name.toLowerCase().contains(query))
          .toList();
    });
  }

  List<CategoryItem> get recentCategories {
    return filteredCategories.take(5).toList();
  }

  List<CategoryItem> get remainingCategories {
    return filteredCategories;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drawer Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppTheme.isDarkMode
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Text(
                  widget.isExpense ? 'Chi tiêu' : 'Thu nhập',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Add Category Button
                TextButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => const AddCategoryDrawer(),
                    );
                  },
                  icon: Icon(
                    Icons.add_circle_outline_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  label: Text(
                    'Thêm mới',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: searchController,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Tìm danh mục...',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppTheme.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // Recent Categories
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Gần đây',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Recent Categories List
          SizedBox(
            height: 36,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: recentCategories.length,
              itemBuilder: (context, index) {
                final category = recentCategories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    selected: category.name == widget.currentCategory,
                    showCheckmark: false,
                    avatar: Text(category.emoji),
                    label: Text(category.name),
                    labelStyle: TextStyle(
                      color: category.name == widget.currentCategory
                          ? Colors.white
                          : AppTheme.textPrimary,
                      fontSize: 13,
                    ),
                    backgroundColor: AppTheme.cardBackground,
                    selectedColor: category.color,
                    side: BorderSide(
                      color: category.name == widget.currentCategory
                          ? category.color
                          : AppTheme.isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : AppTheme.borderColor,
                      width: 0.5,
                    ),
                    onSelected: (_) {
                      widget.onCategorySelected(category.name);
                      if (widget.autoPopOnSelect) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // All Categories
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              children: [
                Icon(
                  Icons.grid_view_rounded,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tất cả danh mục',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Categories Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: remainingCategories.length,
              itemBuilder: (context, index) {
                final category = remainingCategories[index];
                final isSelected = category.name == widget.currentCategory;
                final emoji = category.name.split(' ')[0];
                final name = category.name.split(' ').skip(1).join(' ');

                return InkWell(
                  onTap: () {
                    widget.onCategorySelected(category.name);
                    if (widget.autoPopOnSelect) {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? category.color.withOpacity(0.1)
                          : AppTheme.isDarkMode
                              ? Colors.white.withOpacity(0.02)
                              : Colors.black.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? category.color
                            : AppTheme.isDarkMode
                                ? Colors.white.withOpacity(0.05)
                                : AppTheme.borderColor,
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: category.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          style: TextStyle(
                            color: isSelected
                                ? category.color
                                : AppTheme.textPrimary,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCategories() {
    return Column(children: []);
  }

  Widget _buildCategoryList() {
    return Column(
      children: filteredCategories
          .map((category) => _buildCategoryTile(category))
          .toList(),
    );
  }

  Widget _buildCategoryTile(CategoryItem category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        selected: category.name == widget.currentCategory,
        showCheckmark: false,
        avatar: Text(category.emoji),
        label: Text(category.name),
        labelStyle: TextStyle(
          color: category.name == widget.currentCategory
              ? Colors.white
              : AppTheme.textPrimary,
          fontSize: 13,
        ),
        backgroundColor: AppTheme.cardBackground,
        selectedColor: category.color,
        side: BorderSide(
          color: category.name == widget.currentCategory
              ? category.color
              : AppTheme.isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : AppTheme.borderColor,
          width: 0.5,
        ),
        onSelected: (_) {
          widget.onCategorySelected(category.name);
          if (widget.autoPopOnSelect) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

// Chuyển CategoryItem class vào đây
class CategoryItem {
  final String emoji;
  final String name;
  final Color color;

  const CategoryItem({
    required this.emoji,
    required this.name,
    required this.color,
  });
}
