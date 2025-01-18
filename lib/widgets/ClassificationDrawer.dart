import 'package:flutter/material.dart';
import 'package:uniko/models/category.dart';
import 'package:uniko/providers/category_provider.dart';
import 'package:uniko/providers/fund_provider.dart';
import 'package:uniko/widgets/CategoryDrawer.dart';
import '../config/theme.config.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:uniko/services/api/tracker_service.dart';
import 'package:uniko/services/core/toast_service.dart';
import 'package:uniko/providers/statistics_provider.dart';

class ClassificationDrawer extends StatefulWidget {
  final String transactionId;
  final String transactionType;
  final Function(String reason, String category, String description) onSave;

  const ClassificationDrawer({
    super.key,
    required this.transactionId,
    required this.transactionType,
    required this.onSave,
  });

  @override
  State<ClassificationDrawer> createState() => _ClassificationDrawerState();
}

class _ClassificationDrawerState extends State<ClassificationDrawer> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = '';
  bool _isSubmitting = false;

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
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildTextField(
                    controller: _reasonController,
                    label: 'Lý do chi tiêu',
                    hint: 'Nhập lý do chi tiêu...',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập lý do chi tiêu';
                      }
                      return null;
                    },
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
                            border: Border.all(
                              color: Colors.transparent,
                            ),
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
                      if (_selectedCategory.isEmpty && _isSubmitting)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            'Vui lòng chọn danh mục',
                            style: TextStyle(
                              color: Colors.red.withOpacity(0.8),
                              fontSize: 12,
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
                    validator: null, // Optional field
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor:
                          AppTheme.primary.withOpacity(0.5),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
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
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!mounted) return;

    setState(() {
      _isSubmitting = true;
    });

    bool isValid = true;
    List<String> errors = [];

    // Validate form
    if (!_formKey.currentState!.validate()) {
      isValid = false;
    }

    // Validate category
    if (_selectedCategory.isEmpty) {
      isValid = false;
      errors.add('Vui lòng chọn danh mục');
    }

    // Show all errors if any
    if (!isValid) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (errors.isNotEmpty) {
          ToastService.showError(errors.join('\n'));
        }
      }
      return;
    }

    try {
      if (!mounted) return;
      final fundId = context.read<FundProvider>().selectedFundId;
      if (fundId == null) {
        throw Exception('Không tìm thấy Fund ID');
      }

      // 1. Thêm dữ liệu
      final response = await TrackerService.classify(
        transactionId: widget.transactionId,
        trackerTypeId: _selectedCategory,
        reasonName: _reasonController.text,
        fundId: fundId,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
      );

      widget.onSave(
        _reasonController.text,
        _selectedCategory,
        _descriptionController.text,
      );

      if (!mounted) return;

      // 2. Hiển thị toast thành công
      ToastService.showSuccess('Phân loại giao dịch thành công');

      // 3. Đóng tất cả drawer
      Navigator.of(context).popUntil((route) => route.isFirst);

      // 4. Refetch data
      await context.read<StatisticsProvider>().fetchStatistics(
            fundId,
            DateTime.now(),
            DateTime.now(),
          );
    } catch (e) {
      if (mounted) {
        ToastService.showError('Có lỗi xảy ra: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
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
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
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
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primary,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red.withOpacity(0.5),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  void _showCategoryDrawer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (categoryContext) => CategoryDrawer(
        currentCategory: _selectedCategory,
        onCategorySelected: (categoryName) {
          setState(() {
            final selectedCat =
                context.read<CategoryProvider>().categories.firstWhere(
                      (cat) => cat.name == categoryName,
                      orElse: () => throw Exception('Không tìm thấy category'),
                    );
            _selectedCategory = selectedCat.id;
          });
          Navigator.pop(categoryContext);
        },
        isExpense: widget.transactionType == 'EXPENSE',
        autoPopOnSelect: false,
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
