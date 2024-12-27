import 'package:flutter/material.dart';
import '../config/theme.config.dart';
import '../constants/emoji_categories.dart';

class AddCategoryDrawer extends StatefulWidget {
  const AddCategoryDrawer({super.key});

  @override
  State<AddCategoryDrawer> createState() => _AddCategoryDrawerState();
}

class _AddCategoryDrawerState extends State<AddCategoryDrawer> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'Chi tiêu';
  String _selectedEmoji = '🏷️';
  final Map<String, List<String>> _emojiCategories = EMOJI_CATEGORIES;

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
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Thêm danh mục mới',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Emoji Selector
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Tên phân loại input
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Tên phân loại',
                              labelStyle:
                                  TextStyle(color: AppTheme.textSecondary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.isDarkMode
                                      ? Colors.white.withOpacity(0.1)
                                      : AppTheme.borderColor,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập tên phân loại';
                              }
                              return null;
                            },
                          ),
                        ),

                        // Emoji Selector Button
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                padding: const EdgeInsets.only(top: 20),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardBackground,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(24)),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Chọn biểu tượng',
                                      style: TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Expanded(
                                      child: _buildEmojiGrid(_emojiCategories),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(left: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.isDarkMode
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.isDarkMode
                                    ? Colors.white.withOpacity(0.1)
                                    : AppTheme.borderColor,
                              ),
                            ),
                            child: Text(
                              _selectedEmoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeButton(
                            title: 'Chi tiêu',
                            isSelected: _selectedType == 'Chi tiêu',
                            onTap: () =>
                                setState(() => _selectedType = 'Chi tiêu'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTypeButton(
                            title: 'Thu nhập',
                            isSelected: _selectedType == 'Thu nhập',
                            onTap: () =>
                                setState(() => _selectedType = 'Thu nhập'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Mô tả
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Mô tả (tùy chọn)',
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : AppTheme.borderColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              border: Border(
                top: BorderSide(
                  color: AppTheme.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : AppTheme.borderColor,
                ),
              ),
            ),
            child: ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Thêm danh mục',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // Định nghĩa màu sắc cho từng loại
    final colors = {
      'Chi tiêu': {
        'selected': const Color(0xFFFF5252),      // Đỏ nhạt cho chi tiêu
        'bg': const Color(0xFFFFEBEE),            // Nền hồng nhạt
        'border': const Color(0xFFFFCDD2),        // Viền hồng đậm hơn
      },
      'Thu nhập': {
        'selected': const Color(0xFF4CAF50),      // Xanh lá cho thu nhập
        'bg': const Color(0xFFE8F5E9),            // Nền xanh nhạt
        'border': const Color(0xFFC8E6C9),        // Viền xanh đậm hơn
      },
    };

    final color = colors[title]!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? color['selected']!.withOpacity(0.1) 
              : color['bg']!.withOpacity(AppTheme.isDarkMode ? 0.05 : 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? color['selected']! 
                : color['border']!.withOpacity(AppTheme.isDarkMode ? 0.2 : 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              title == 'Chi tiêu' 
                  ? Icons.remove_circle_outline 
                  : Icons.add_circle_outline,
              size: 18,
              color: isSelected 
                  ? color['selected'] 
                  : color['selected']!.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected 
                    ? color['selected'] 
                    : color['selected']!.withOpacity(0.7),
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement category creation
      print('Tên: ${_nameController.text}');
      print('Loại: $_selectedType');
      print('Mô tả: ${_descriptionController.text}');
      print('Emoji: $_selectedEmoji');
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildEmojiGrid(Map<String, List<String>> categories) {
    return DefaultTabController(
      length: categories.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            tabs: categories.keys
                .map((category) => Tab(
                      text: category,
                      height: 40,
                    ))
                .toList(),
          ),
          Expanded(
            child: TabBarView(
              children: categories.entries.map((entry) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: entry.value.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedEmoji = entry.value[index]);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            entry.value[index],
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

