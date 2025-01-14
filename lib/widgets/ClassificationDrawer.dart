import 'package:flutter/material.dart';
import 'package:uniko/models/category.dart';
import 'package:uniko/providers/category_provider.dart';
import 'package:uniko/widgets/CategoryDrawer.dart';
import '../config/theme.config.dart';
import 'package:provider/provider.dart';

class ClassificationDrawer extends StatefulWidget {
  final String transactionId;
  final Function(String reason, String category, String description) onSave;

  const ClassificationDrawer({
    super.key,
    required this.transactionId,
    required this.onSave,
  });

  @override
  State<ClassificationDrawer> createState() => _ClassificationDrawerState();
}

class _ClassificationDrawerState extends State<ClassificationDrawer> {
  final _reasonController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drawer Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Phân loại giao dịch',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Form
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildTextField(
                  controller: _reasonController,
                  label: 'Lý do chi tiêu',
                  hint: 'Nhập lý do chi tiêu...',
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Danh mục',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showCategoryDrawer,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Consumer<CategoryProvider>(
                              builder: (context, provider, child) {
                                final selectedCategory =
                                    provider.categories.firstWhere(
                                  (cat) => cat.id == _selectedCategory,
                                  orElse: () => Category(
                                    id: '',
                                    name: 'Chọn phân loại',
                                    type: 'EXPENSE',
                                    trackerType: 'DEFAULT',
                                  ),
                                );
                                return Text(
                                  selectedCategory.name,
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 15,
                                  ),
                                );
                              },
                            ),
                            const Spacer(),
                            Icon(
                              Icons.chevron_right,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Mô tả',
                  hint: 'Thêm mô tả chi tiết...',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    widget.onSave(
                      _reasonController.text,
                      _selectedCategory,
                      _descriptionController.text,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Lưu phân loại',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryDrawer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          final categories = provider
              .getCategoriesByType('EXPENSE')
              .map((cat) => CategoryItem(
                    emoji: cat.name.split(' ')[0],
                    name: cat.name.split(' ').skip(1).join(' '),
                    color: Colors.red,
                  ))
              .toList();

          return CategoryDrawer(
            currentCategory: _selectedCategory,
            categories: categories,
            onCategorySelected: (categoryName) {
              setState(() {
                _selectedCategory = provider.categories
                    .firstWhere((cat) => cat.name.contains(categoryName))
                    .id;
              });
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            isExpense: true,
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            filled: true,
            fillColor: AppTheme.isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
