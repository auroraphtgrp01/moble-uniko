import 'package:flutter/material.dart';
import 'package:uniko/config/theme.config.dart';
import 'package:intl/intl.dart';

enum FilterType {
  week,
  month,
  year,
  custom,
}

class DateFilterDrawer extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final FilterType? currentFilter;
  final Function(DateTime start, DateTime end, FilterType type) onFilterChanged;

  const DateFilterDrawer({
    super.key,
    this.startDate,
    this.endDate,
    this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  State<DateFilterDrawer> createState() => _DateFilterDrawerState();
}

class _DateFilterDrawerState extends State<DateFilterDrawer> {
  late FilterType _selectedFilter;
  DateTime? _startDate;
  DateTime? _endDate;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.currentFilter ?? FilterType.month;
    _startDate = widget.startDate ?? DateTime.now();
    _endDate = widget.endDate ?? DateTime.now();
    _selectedDate = DateTime.now();
  }

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
                  'Bộ lọc thời gian',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Đóng',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Type Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: FilterType.values.map((type) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      selected: _selectedFilter == type,
                      showCheckmark: false,
                      label: Text(_getFilterLabel(type)),
                      labelStyle: TextStyle(
                        color: _selectedFilter == type
                            ? Colors.white
                            : AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                      backgroundColor: AppTheme.cardBackground,
                      selectedColor: AppTheme.primary,
                      side: BorderSide(
                        color: _selectedFilter == type
                            ? AppTheme.primary
                            : AppTheme.borderColor,
                        width: 0.5,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = type;
                          _updateDateRange();
                        });
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Date Selector
          if (_selectedFilter == FilterType.custom) ...[
            _buildCustomDateRange(),
          ] else ...[
            _buildDatePicker(),
          ],

          const Spacer(),

          // Apply Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                widget.onFilterChanged(_startDate!, _endDate!, _selectedFilter);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Áp dụng',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel(FilterType type) {
    switch (type) {
      case FilterType.week:
        return 'Tuần';
      case FilterType.month:
        return 'Tháng';
      case FilterType.year:
        return 'Năm';
      case FilterType.custom:
        return 'Tùy chọn';
    }
  }

  void _updateDateRange() {
    switch (_selectedFilter) {
      case FilterType.week:
        _startDate = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        _endDate = _startDate!.add(const Duration(days: 6));
        break;
      case FilterType.month:
        _startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
        _endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
        break;
      case FilterType.year:
        _startDate = DateTime(_selectedDate.year, 1, 1);
        _endDate = DateTime(_selectedDate.year, 12, 31);
        break;
      case FilterType.custom:
        // Handled separately
        break;
    }
  }

  Widget _buildDatePicker() {
    String title;
    String dateFormat;
    
    switch (_selectedFilter) {
      case FilterType.week:
        title = 'Chọn tuần';
        dateFormat = "'Tuần' w, MM/yyyy";
        break;
      case FilterType.month:
        title = 'Chọn tháng';
        dateFormat = 'MM/yyyy';
        break;
      case FilterType.year:
        title = 'Chọn năm';
        dateFormat = 'yyyy';
        break;
      default:
        title = '';
        dateFormat = '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          child: CalendarDatePicker(
            initialDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
                _updateDateRange();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomDateRange() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn khoảng thời gian',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  'Từ ngày',
                  _startDate,
                  (date) => setState(() => _startDate = date),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateButton(
                  'Đến ngày',
                  _endDate,
                  (date) => setState(() => _endDate = date),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(
    String label,
    DateTime? date,
    Function(DateTime?) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (selected != null) {
          onDateSelected(selected);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? DateFormat('dd/MM/yyyy').format(date)
                  : 'Chọn ngày',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 