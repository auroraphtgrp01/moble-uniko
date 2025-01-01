import './core/api_service.dart';
import './core/logger_service.dart';
import 'dart:convert';

class UserService {
  static Future<Map<String, dynamic>> updateUserInfo({
    required String userId,
    String? fullName,
    String? gender,
    String? phoneNumber,
    String? address,
    String? dateOfBirth,
    String? avatarId,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (fullName?.isNotEmpty ?? false) data['fullName'] = fullName;
      if (gender?.isNotEmpty ?? false) data['gender'] = gender;
      if (phoneNumber?.isNotEmpty ?? false) data['phone_number'] = phoneNumber;
      if (address?.isNotEmpty ?? false) data['address'] = address;
      if (dateOfBirth?.isNotEmpty ?? false) data['dateOfBirth'] = dateOfBirth;
      if (avatarId?.isNotEmpty ?? false) data['avatarId'] = avatarId;

      LoggerService.info('UPDATE_USER_INFO Request: ${json.encode({
            'userId': userId,
            'endpoint': '/users/$userId',
            'method': 'PATCH',
            'body': data,
          })}');

      final response = await ApiService.call(
        '/users/$userId',
        method: 'PATCH',
        body: data,
      );

      LoggerService.info('UPDATE_USER_INFO Response: ${json.encode({
            'statusCode': response.statusCode,
            'body': response.body,
          })}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        LoggerService.error('UPDATE_USER_INFO Error:', {
          'statusCode': response.statusCode,
          'body': response.body,
        });
        throw Exception('Cập nhật thông tin thất bại');
      }
    } catch (e) {
      LoggerService.error('UPDATE_USER_INFO Exception:', e.toString());
      throw Exception('Có lỗi xảy ra: ${e.toString()}');
    }
  }
}
