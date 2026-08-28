import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:pmdap_operations/core/api_client.dart';
import 'package:pmdap_operations/core/config.dart';
import 'package:pmdap_operations/core/models.dart';

abstract class OpsRepository {
  Future<TokenPair> login(String email, String password);
  Future<OpsUser> me();
  Future<void> logout(String refresh);
  Future<Paged<IdentityQueueItem>> identities();
  Future<IdentityReviewDetail> identity(String id);
  Future<IdentityReviewDetail> saveIdentityFields(
    String id,
    int reviewVersion,
    Map<String, String?> fields,
  );
  Future<void> approveIdentity(String id);
  Future<void> rejectIdentity(String id, String reason);
  Future<PrivateImageBytes> identityImage(String id, String side);
  Future<Paged<GuardianQueueItem>> guardians();
  Future<GuardianReviewDetail> guardian(String id);
  Future<void> approveGuardian(String id);
  Future<void> rejectGuardian(String id, String reason);
}

class DioOpsRepository implements OpsRepository {
  DioOpsRepository(this._client);
  final ApiClient _client;

  Map<String, dynamic> _data(Response<dynamic> response) {
    final body = response.data;
    if (body is! Map<String, dynamic> ||
        body['data'] is! Map<String, dynamic>) {
      throw const ApiFailure(
        code: 'invalid_response',
        message: 'Server returned an invalid response.',
      );
    }
    return body['data'] as Map<String, dynamic>;
  }

  Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on DioException catch (error) {
      throw _client.failure(error);
    }
  }

  @override
  Future<TokenPair> login(String email, String password) => _guard(() async {
    final response = await _client.dio.post<dynamic>(
      ApiPaths.login,
      data: {'email': email.trim(), 'password': password},
    );
    return TokenPair.fromJson(_data(response));
  });

  @override
  Future<OpsUser> me() => _guard(() async {
    final response = await _client.dio.get<dynamic>(ApiPaths.me);
    return OpsUser.fromJson(_data(response));
  });

  @override
  Future<void> logout(String refresh) => _guard(() async {
    await _client.dio.post<dynamic>(
      ApiPaths.logout,
      data: {'refresh': refresh},
    );
  });

  @override
  Future<Paged<IdentityQueueItem>> identities() => _guard(() async {
    final response = await _client.dio.get<dynamic>(
      ApiPaths.identities,
      queryParameters: const {'status': 'PENDING'},
    );
    final page = _data(response);
    final items = page['results'] is List ? page['results'] as List : const [];
    return Paged(
      count: page['count'] is int ? page['count'] as int : items.length,
      items: items
          .whereType<Map<String, dynamic>>()
          .map(IdentityQueueItem.fromJson)
          .toList(growable: false),
    );
  });

  @override
  Future<IdentityReviewDetail> identity(String id) => _guard(() async {
    final response = await _client.dio.get<dynamic>(ApiPaths.identity(id));
    return IdentityReviewDetail.fromJson(_data(response));
  });

  @override
  Future<IdentityReviewDetail> saveIdentityFields(
    String id,
    int reviewVersion,
    Map<String, String?> fields,
  ) => _guard(() async {
    final response = await _client.dio.post<dynamic>(
      ApiPaths.reviewFields(id),
      data: {'review_version': reviewVersion, 'fields': fields},
    );
    return IdentityReviewDetail.fromJson(_data(response));
  });

  @override
  Future<void> approveIdentity(String id) => _guard(() async {
    await _client.dio.post<dynamic>(ApiPaths.approveIdentity(id), data: {});
  });

  @override
  Future<void> rejectIdentity(String id, String reason) => _guard(() async {
    await _client.dio.post<dynamic>(
      ApiPaths.rejectIdentity(id),
      data: {'rejection_reason': reason.trim()},
    );
  });

  @override
  Future<PrivateImageBytes> identityImage(String id, String side) =>
      _guard(() async {
        if (side != 'front' && side != 'back') {
          throw const ApiFailure(
            code: 'invalid_side',
            message: 'Invalid identity image side.',
          );
        }
        final response = await _client.dio.get<List<int>>(
          ApiPaths.identityImage(id, side),
          options: Options(responseType: ResponseType.bytes),
        );
        return PrivateImageBytes(
          bytes: Uint8List.fromList(response.data ?? const []),
          mimeType:
              response.headers.value(Headers.contentTypeHeader) ?? 'image/jpeg',
        );
      });

  @override
  Future<Paged<GuardianQueueItem>> guardians() => _guard(() async {
    final response = await _client.dio.get<dynamic>(
      ApiPaths.guardians,
      queryParameters: const {'status': 'PENDING'},
    );
    final page = _data(response);
    final items = page['results'] is List ? page['results'] as List : const [];
    return Paged(
      count: page['count'] is int ? page['count'] as int : items.length,
      items: items
          .whereType<Map<String, dynamic>>()
          .map(GuardianQueueItem.fromJson)
          .toList(growable: false),
    );
  });

  @override
  Future<GuardianReviewDetail> guardian(String id) => _guard(() async {
    final response = await _client.dio.get<dynamic>(ApiPaths.guardian(id));
    return GuardianReviewDetail.fromJson(_data(response));
  });

  @override
  Future<void> approveGuardian(String id) => _guard(() async {
    await _client.dio.post<dynamic>(ApiPaths.approveGuardian(id), data: {});
  });

  @override
  Future<void> rejectGuardian(String id, String reason) => _guard(() async {
    await _client.dio.post<dynamic>(
      ApiPaths.rejectGuardian(id),
      data: {'rejection_reason': reason.trim()},
    );
  });
}
