// lib/services/account_source_service.dart

import 'dart:convert';
import 'package:uniko/services/core/api_service.dart';
import 'package:uniko/services/core/logger_service.dart';
import 'package:uniko/services/core/toast_service.dart';
import '../models/account_source.dart';

class AccountSourceService {
  Future<AccountSource> createAccountSource({
    required String name,
    required String accountSourceType,
    required int initAmount,
    required String fundId,
    List<String>? accounts,
    String? password,
    String? loginId,
    String? type,
  }) async {
    try {
      final body = {
        'name': name,
        'accountSourceType': accountSourceType,
        'initAmount': initAmount,
        'fundId': fundId,
      };

      if (accountSourceType == 'BANKING') {
        body['password'] = password ?? '';
        body['login_id'] = loginId ?? '';
        body['type'] = type ?? 'MB_BANK';
        body['accounts'] = accounts ?? [];
      }

      LoggerService.info('UPDATE_USER_INFO Request: ${json.encode(body)}');

      final response = await ApiService.call(
        '/account-sources',
        method: 'POST',
        body: body,
      );

      LoggerService.info('CREATE_ACCOUNT_SOURCE Response: ${response.body}');

      if (response.statusCode == 201) {
        ToastService.showSuccess('Tạo nguồn tiền thành công');
        return AccountSource.fromJson(jsonDecode(response.body));
      } else {
        ToastService.showError('Tạo nguồn tiền thất bại - Vui lòng thử lại');
        throw Exception('Failed to create account source: ${response.statusCode}');
      }
    } catch (e) {
      ToastService.showError('Có lỗi xảy ra: $e');
      throw Exception('Failed to create account source: $e');
    }
  }

  Future<AccountSourceResponse> getAdvancedAccountSources(String fundId) async {
    try {
      final response =
          await ApiService.call('/account-sources/advanced/$fundId');

      LoggerService.info('GET_ACCOUNT_SOURCES Response: ${response.body}');

      if (response.statusCode == 200) {
        return AccountSourceResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to get account sources: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('Error getting account sources: $e');
      throw Exception('Failed to get account sources: $e');
    }
  }
}
