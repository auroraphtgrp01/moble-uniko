import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.config.dart';
import '../../services/core/storage_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:uniko/widgets/Avatar.dart';
import '../../constants/avatars.dart';
import '../../services/user_service.dart';

class AvatarDrawer extends StatefulWidget {
  final String? currentAvatarId;
  final Function(String) onAvatarSelected;

  const AvatarDrawer({
    Key? key,
    this.currentAvatarId,
    required this.onAvatarSelected,
  }) : super(key: key);

  @override
  State<AvatarDrawer> createState() => _AvatarDrawerState();
}

class _AvatarDrawerState extends State<AvatarDrawer> {
  String? selectedAvatarId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedAvatarId = widget.currentAvatarId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppTheme.isDarkMode
              ? [
                  AppTheme.cardDark.withOpacity(0.8),
                  AppTheme.cardDark,
                ]
              : [
                  AppTheme.cardLight.withOpacity(0.8),
                  AppTheme.cardLight,
                ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chọn Avatar',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (selectedAvatarId != widget.currentAvatarId)
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (selectedAvatarId != null) {
                                  setState(() => isLoading = true);
                                  try {
                                    await widget
                                        .onAvatarSelected(selectedAvatarId!);
                                    Navigator.pop(context);
                                  } catch (e) {
                                    // Xử lý lỗi nếu cần
                                  } finally {
                                    setState(() => isLoading = false);
                                  }
                                }
                              },
                        child: Row(
                          children: [
                            if (isLoading)
                              Container(
                                width: 16,
                                height: 16,
                                margin: EdgeInsets.only(right: 8),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.primary,
                                  ),
                                ),
                              ),
                            Text(
                              'Lưu',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: avatarPath.length,
              itemBuilder: (context, index) {
                final avatarId = avatarPath[index];
                final isSelected = avatarId == selectedAvatarId;

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedAvatarId = avatarId);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            isSelected ? AppTheme.primary : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/avatars/$avatarId.png',
                        fit: BoxFit.cover,
                      ),
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
}

class DatePickerDrawer extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime) onDateSelected;

  const DatePickerDrawer({
    Key? key,
    this.initialDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<DatePickerDrawer> createState() => _DatePickerDrawerState();
}

class _DatePickerDrawerState extends State<DatePickerDrawer> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppTheme.isDarkMode
              ? [AppTheme.cardDark.withOpacity(0.8), AppTheme.cardDark]
              : [AppTheme.cardLight.withOpacity(0.8), AppTheme.cardLight],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chọn ngày sinh',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (selectedDate != widget.initialDate)
                      TextButton(
                        onPressed: () {
                          widget.onDateSelected(selectedDate!);
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Lưu',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: CalendarDatePicker(
              initialDate: selectedDate!,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              onDateChanged: (date) {
                setState(() => selectedDate = date);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  Map<String, dynamic>? userInfo;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController phoneController = TextEditingController();
  late TextEditingController addressController = TextEditingController();
  late TextEditingController dobController = TextEditingController();
  late String selectedGender = '';

  // FocusNodes
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _dobFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _phoneFocus.dispose();
    _addressFocus.dispose();
    _dobFocus.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final data = await StorageService.getUserInfo();
    if (data != null) {
      setState(() {
        userInfo = data;
        phoneController = TextEditingController(text: data['phone_number'] ?? '');
        addressController = TextEditingController(text: data['address'] ?? '');
        dobController = TextEditingController(text: _formatDateFromServer(data['dateOfBirth']));
        selectedGender = data['gender'] ?? 'OTHER';
      });
    }
  }

  String _formatDateFromServer(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return date; // Nếu parse thất bại, trả về nguyên bản
    }
  }

  Future<void> _saveUserInfo() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (userInfo == null || userInfo!['id'] == null) {
          throw Exception('Không tìm thấy thông tin người dùng');
        }

        // Chuyển đổi định dạng ngày
        DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(dobController.text.trim());
        String isoDate = parsedDate.toIso8601String();

        final updatedInfo = await UserService.updateUserInfo(
          userId: userInfo!['id'].toString(),
          phoneNumber: phoneController.text.trim(),
          address: addressController.text.trim(),
          dateOfBirth: isoDate, // Sử dụng định dạng ISO
          gender: selectedGender,
        );
        print(updatedInfo);

        setState(() {
          userInfo = updatedInfo;
          isEditing = false;
        });
        print("user info: $userInfo");

        // Cập nhật storage
        await StorageService.saveUserInfo(updatedInfo);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cập nhật thông tin thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Sửa lại widget _buildInfoItem để hỗ trợ chế độ edit
  Widget _buildInfoItem(String label, String value, IconData icon,
      {TextEditingController? controller,
      bool isGender = false,
      bool isDatePicker = false,
      FocusNode? focusNode}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppTheme.isDarkMode
              ? [
                  AppTheme.cardDark.withOpacity(0.8),
                  AppTheme.cardDark,
                ]
              : [
                  AppTheme.cardLight.withOpacity(0.8),
                  AppTheme.cardLight,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEditing
              ? AppTheme.primary.withOpacity(0.3)
              : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEditing && isDatePicker
                ? () async {
                    // Hiển thị date picker khi tap vào field ngày sinh
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(controller?.text ?? '') ??
                          DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: AppTheme.primary,
                              onPrimary: Colors.white,
                              surface: AppTheme.isDarkMode
                                  ? AppTheme.cardDark
                                  : Colors.white,
                              onSurface: AppTheme.textPrimary,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primary,
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (picked != null) {
                      // Format ngày theo định dạng dd/MM/yyyy
                      final formattedDate =
                          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                      controller?.text = formattedDate;
                    }
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primary.withOpacity(0.2),
                              AppTheme.primary.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          icon,
                          color: AppTheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        label,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isGender && isEditing)
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primary.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedGender,
                          isExpanded: true,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          borderRadius: BorderRadius.circular(12),
                          dropdownColor: AppTheme.isDarkMode
                              ? Colors.grey.shade900
                              : Colors.white,
                          items: [
                            DropdownMenuItem(
                              value: 'MALE',
                              child: Text(
                                'Nam',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'FEMALE',
                              child: Text(
                                'Nữ',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'OTHER',
                              child: Text(
                                'Khác',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => selectedGender = value!);
                          },
                        ),
                      ),
                    )
                  else if (isGender && !isEditing)
                    Text(
                      selectedGender == 'MALE'
                          ? 'Nam'
                          : selectedGender == 'FEMALE'
                              ? 'Nữ'
                              : 'Khác',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else if (isEditing && !isGender && !isDatePicker)
                    TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      onFieldSubmitted: (_) {
                        if (_dobFocus == _dobFocus) {
                          _addressFocus.requestFocus();
                        } else {
                          _dobFocus.unfocus();
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.shade50,
                        hintStyle: TextStyle(
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập $label';
                        }
                        return null;
                      },
                    )
                  else if (isEditing && isDatePicker)
                    TextFormField(
                      controller: controller,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                      ),
                      readOnly: true,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => DatePickerDrawer(
                            initialDate: DateFormat('dd/MM/yyyy').parseStrict(controller!.text),
                            onDateSelected: (date) {
                              final formattedDate = DateFormat('dd/MM/yyyy').format(date);
                              controller.text = formattedDate;
                            },
                          ),
                        );
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.shade50,
                        hintText: 'Chọn ngày sinh',
                        hintStyle: TextStyle(
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                        suffixIcon: Container(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primary.withOpacity(0.2),
                                AppTheme.primary.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.calendar_today_outlined,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    )
                  else
                    Text(
                      _formatDateFromServer(value),
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Trong class _UserInfoPageState, thêm hàm để xử lý việc thay đổi avatar
  Future<void> _handleAvatarChange(String newAvatarId) async {
    try {
      if (userInfo == null || userInfo!['id'] == null) {
        throw Exception('Không tìm thấy thông tin người dùng');
      }

      final updatedInfo = await UserService.updateUserInfo(
        userId: userInfo!['id'].toString(),
        avatarId: newAvatarId,
      );

      setState(() {
        userInfo = updatedInfo;
      });

      // Cập nhật storage
      await StorageService.saveUserInfo(updatedInfo);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Thông tin cá nhân',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isEditing ? Icons.save : Icons.edit,
              color: AppTheme.textPrimary,
            ),
            onPressed: () {
              if (isEditing) {
                _saveUserInfo();
              } else {
                setState(() => isEditing = true);
              }
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Ẩn keyboard khi tap outside
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          child: Column(
            children: [
              // Phần avatar và thông tin cơ bản
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppTheme.isDarkMode
                        ? [
                            AppTheme.cardDark.withOpacity(0.8),
                            AppTheme.cardDark,
                          ]
                        : [
                            AppTheme.cardLight.withOpacity(0.8),
                            AppTheme.cardLight,
                          ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.isDarkMode
                          ? Colors.black.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => AvatarDrawer(
                            currentAvatarId: userInfo?['avatarId'],
                            onAvatarSelected: _handleAvatarChange,
                          ),
                        );
                      },
                      child: Avatar(
                        avatarId: userInfo?['avatarId'],
                        size: 100,
                        borderWidth: 0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userInfo?['fullName'] ?? 'Chưa cập nhật',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userInfo?['email'] ?? 'Chưa cập nhật',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Phần thông tin chi tiết
              Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 8,
                        ),
                        child: Text(
                          'Thông tin chi tiết',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildInfoItem(
                        'Số điện thoại',
                        userInfo?['phone_number'] ?? 'Chưa cập nhật',
                        Icons.phone_outlined,
                        controller: phoneController,
                        focusNode: _phoneFocus,
                      ),
                      _buildInfoItem(
                        'Địa chỉ',
                        userInfo?['address'] ?? 'Chưa cập nhật',
                        Icons.location_on_outlined,
                        controller: addressController,
                        focusNode: _addressFocus,
                      ),
                      _buildInfoItem(
                        'Ngày sinh',
                        userInfo?['dateOfBirth'] ?? 'Chưa cập nhật',
                        Icons.calendar_today_outlined,
                        controller: dobController,
                        isDatePicker: true,
                        focusNode: _dobFocus,
                      ),
                      _buildInfoItem(
                        'Giới tính',
                        userInfo?['gender'] == 'MALE'
                            ? 'Nam'
                            : userInfo?['gender'] == 'FEMALE'
                                ? 'Nữ'
                                : 'Khác',
                        Icons.person_outline,
                        isGender: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
