abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'PMDAP_API_BASE_URL',
    defaultValue: 'https://pmdapbackend.up.railway.app',
  );
  static const sessionTimeout = Duration(minutes: 15);
}

abstract final class ApiPaths {
  static const login = '/api/v1/auth/login/';
  static const logout = '/api/v1/auth/logout/';
  static const me = '/api/v1/auth/me/';
  static const identities = '/api/v1/verification/identity-documents/';
  static const guardians = '/api/v1/verification/guardian-relationships/';

  static String identity(String id) => '$identities$id/';
  static String reviewFields(String id) => '${identity(id)}review-fields/';
  static String approveIdentity(String id) => '${identity(id)}approve/';
  static String rejectIdentity(String id) => '${identity(id)}reject/';
  static String correctVerified(String id) =>
      '${identity(id)}correct-verified/';
  static String identityImage(String id, String side) =>
      '/api/v1/identity-documents/$id/images/$side/';
  static String guardian(String id) => '$guardians$id/';
  static String approveGuardian(String id) => '${guardian(id)}approve/';
  static String rejectGuardian(String id) => '${guardian(id)}reject/';
}
