import 'dart:typed_data';

String _text(Object? value) => value?.toString() ?? '';
bool _bool(Object? value) => value == true;
Map<String, dynamic> _map(Object? value) =>
    value is Map<String, dynamic> ? value : const <String, dynamic>{};
List<dynamic> _list(Object? value) => value is List ? value : const [];

String knownEnum(Object? value, Set<String> values) {
  final raw = _text(value);
  return values.contains(raw) ? raw : 'UNKNOWN';
}

class OpsUser {
  const OpsUser({
    required this.id,
    required this.email,
    required this.role,
    required this.canVerifyIdentity,
  });

  factory OpsUser.fromJson(Map<String, dynamic> json) => OpsUser(
    id: _text(json['uuid']),
    email: _text(json['email']),
    role: knownEnum(json['role'], const {
      'PATIENT',
      'IDENTITY_VERIFICATION_AGENT',
      'ADMIN',
    }),
    canVerifyIdentity: _bool(json['can_verify_identity']),
  );

  final String id;
  final String email;
  final String role;
  final bool canVerifyIdentity;
}

class TokenPair {
  const TokenPair({required this.access, required this.refresh});
  factory TokenPair.fromJson(Map<String, dynamic> json) =>
      TokenPair(access: _text(json['access']), refresh: _text(json['refresh']));
  final String access;
  final String refresh;
}

class Paged<T> {
  const Paged({required this.count, required this.items});
  final int count;
  final List<T> items;
}

class IdentityQueueItem {
  const IdentityQueueItem({
    required this.id,
    required this.safeName,
    required this.documentType,
    required this.status,
    required this.createdAt,
    required this.corrected,
  });

  factory IdentityQueueItem.fromJson(Map<String, dynamic> json) {
    final patient = _map(json['patient']);
    return IdentityQueueItem(
      id: _text(json['uuid']),
      safeName: _text(patient['full_name']),
      documentType: knownEnum(json['document_type'], const {
        'UNIFIED_NATIONAL_CARD',
        'PASSPORT',
        'BIRTH_DOCUMENT',
      }),
      status: knownEnum(json['verification_status'], const {
        'PENDING',
        'VERIFIED',
        'REJECTED',
      }),
      createdAt: DateTime.tryParse(_text(json['created_at'])),
      corrected: _bool(json['has_corrections']),
    );
  }

  final String id;
  final String safeName;
  final String documentType;
  final String status;
  final DateTime? createdAt;
  final bool corrected;
}

class IdentityReviewField {
  const IdentityReviewField({
    required this.name,
    required this.original,
    required this.reviewed,
    required this.corrected,
  });

  factory IdentityReviewField.fromJson(
    String name,
    Map<String, dynamic> json,
  ) => IdentityReviewField(
    name: name,
    original: _text(json['original']),
    reviewed: _text(json['reviewed']),
    corrected: _bool(json['corrected']),
  );

  final String name;
  final String original;
  final String reviewed;
  final bool corrected;
}

class IdentityReviewDetail {
  const IdentityReviewDetail({
    required this.id,
    required this.safeName,
    required this.documentType,
    required this.status,
    required this.reviewVersion,
    required this.fields,
    required this.availableActions,
    required this.hasCorrections,
  });

  factory IdentityReviewDetail.fromJson(Map<String, dynamic> json) {
    final fields = _map(json['review_fields']).entries
        .map(
          (entry) => IdentityReviewField.fromJson(entry.key, _map(entry.value)),
        )
        .toList(growable: false);
    return IdentityReviewDetail(
      id: _text(json['uuid']),
      safeName: _text(_map(json['patient'])['full_name']),
      documentType: knownEnum(json['document_type'], const {
        'UNIFIED_NATIONAL_CARD',
        'PASSPORT',
        'BIRTH_DOCUMENT',
      }),
      status: knownEnum(json['verification_status'], const {
        'PENDING',
        'VERIFIED',
        'REJECTED',
      }),
      reviewVersion: json['review_version'] is int
          ? json['review_version'] as int
          : 0,
      fields: fields,
      availableActions: _list(json['available_actions']).map(_text).toSet(),
      hasCorrections: _bool(json['has_corrections']),
    );
  }

  final String id;
  final String safeName;
  final String documentType;
  final String status;
  final int reviewVersion;
  final List<IdentityReviewField> fields;
  final Set<String> availableActions;
  final bool hasCorrections;
}

class GuardianQueueItem {
  const GuardianQueueItem({
    required this.id,
    required this.adultName,
    required this.minorName,
    required this.relationship,
    required this.status,
    required this.reviewReadiness,
    required this.createdAt,
  });

  factory GuardianQueueItem.fromJson(Map<String, dynamic> json) =>
      GuardianQueueItem(
        id: _text(json['uuid']),
        adultName: _text(_map(json['guardian_patient'])['full_name']),
        minorName: _text(_map(json['minor_patient'])['full_name']),
        relationship: knownEnum(json['relationship'], const {
          'FATHER',
          'MOTHER',
          'LEGAL_GUARDIAN',
        }),
        status: knownEnum(json['verification_status'], const {
          'PENDING',
          'VERIFIED',
          'REJECTED',
          'REVOKED',
        }),
        reviewReadiness: knownEnum(json['review_readiness'], const {
          'READY_FOR_REVIEW',
          'EVIDENCE_INCOMPLETE',
        }),
        createdAt: DateTime.tryParse(_text(json['created_at'])),
      );

  final String id;
  final String adultName;
  final String minorName;
  final String relationship;
  final String status;
  final String reviewReadiness;
  final DateTime? createdAt;
}

class GuardianApprovalEvaluation {
  const GuardianApprovalEvaluation({
    required this.eligible,
    required this.code,
    required this.reasons,
    required this.adultIdentityVerified,
    required this.minorIdentityVerified,
    required this.ageValid,
    required this.familyResult,
    required this.familyExplanation,
    required this.nameResult,
    required this.nameExplanation,
    required this.nameEvidenceKind,
    required this.officialEvidencePresent,
    required this.adultDocumentId,
    required this.minorDocumentId,
  });

  factory GuardianApprovalEvaluation.fromJson(Map<String, dynamic> json) =>
      GuardianApprovalEvaluation(
        eligible: _bool(json['eligible']),
        code: _text(json['code']),
        reasons: _list(json['reasons']).map(_text).toList(growable: false),
        adultIdentityVerified: _bool(json['adult_identity_verified']),
        minorIdentityVerified: _bool(json['minor_identity_verified']),
        ageValid: _bool(json['age_valid']),
        familyResult: knownEnum(json['family_result'], const {
          'MATCH',
          'MISMATCH',
          'UNAVAILABLE',
        }),
        familyExplanation: _text(json['family_explanation']),
        nameResult: knownEnum(json['name_result'], const {
          'MATCH',
          'MISMATCH',
          'UNAVAILABLE',
        }),
        nameExplanation: _text(json['name_explanation']),
        nameEvidenceKind: json['name_evidence_kind'] == null
            ? null
            : knownEnum(json['name_evidence_kind'], const {'FATHER', 'MOTHER'}),
        officialEvidencePresent: _bool(json['official_evidence_present']),
        adultDocumentId: json['adult_identity_document_uuid']?.toString(),
        minorDocumentId: json['minor_identity_document_uuid']?.toString(),
      );

  final bool eligible;
  final String code;
  final List<String> reasons;
  final bool adultIdentityVerified;
  final bool minorIdentityVerified;
  final bool ageValid;
  final String familyResult;
  final String familyExplanation;
  final String nameResult;
  final String nameExplanation;
  final String? nameEvidenceKind;
  final bool officialEvidencePresent;
  final String? adultDocumentId;
  final String? minorDocumentId;
}

class GuardianReviewDetail {
  const GuardianReviewDetail({required this.item, required this.evaluation});
  factory GuardianReviewDetail.fromJson(Map<String, dynamic> json) =>
      GuardianReviewDetail(
        item: GuardianQueueItem.fromJson(json),
        evaluation: GuardianApprovalEvaluation.fromJson(
          _map(json['approval_evaluation']),
        ),
      );
  final GuardianQueueItem item;
  final GuardianApprovalEvaluation evaluation;
}

class PrivateImageBytes {
  const PrivateImageBytes({required this.bytes, required this.mimeType});
  final Uint8List bytes;
  final String mimeType;
}

class ApiFailure implements Exception {
  const ApiFailure({
    required this.code,
    required this.message,
    this.statusCode,
    this.details = const {},
  });
  final String code;
  final String message;
  final int? statusCode;
  final Map<String, dynamic> details;
  bool get isStale => statusCode == 409;
  @override
  String toString() => message;
}
