import 'dart:typed_data';

import 'package:pmdap_operations/core/models.dart';
import 'package:pmdap_operations/core/token_store.dart';
import 'package:pmdap_operations/repositories/ops_repository.dart';

class MemoryTokenStore implements TokenStore {
  String? access;
  String? refresh;
  int clears = 0;

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
    clears++;
  }

  @override
  Future<String?> readAccess() async => access;

  @override
  Future<String?> readRefresh() async => refresh;

  @override
  Future<void> write({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }
}

IdentityReviewDetail identityDetail({
  Set<String> actions = const {'review_fields', 'approve', 'reject'},
  int reviewVersion = 2,
}) => IdentityReviewDetail(
  id: 'identity-1',
  safeName: 'Synthetic Reviewer Subject',
  documentType: 'UNIFIED_NATIONAL_CARD',
  status: 'PENDING',
  reviewVersion: reviewVersion,
  fields: const [
    IdentityReviewField(
      name: 'given_name',
      original: 'Synthetc',
      reviewed: 'Synthetc',
      corrected: false,
    ),
    IdentityReviewField(
      name: 'issue_date',
      original: '2020-01-01',
      reviewed: '2020-01-01',
      corrected: false,
    ),
  ],
  availableActions: actions,
  hasCorrections: false,
);

GuardianReviewDetail guardianDetail({
  String relationship = 'FATHER',
  bool eligible = true,
  String nameKind = 'FATHER',
  bool official = false,
}) => GuardianReviewDetail(
  item: GuardianQueueItem(
    id: 'guardian-1',
    adultName: 'Synthetic Adult',
    minorName: 'Synthetic Minor',
    relationship: relationship,
    status: 'PENDING',
    reviewReadiness: eligible ? 'READY_FOR_REVIEW' : 'EVIDENCE_INCOMPLETE',
    createdAt: DateTime.utc(2026, 1, 1),
  ),
  evaluation: GuardianApprovalEvaluation(
    eligible: eligible,
    code: eligible ? 'ELIGIBLE' : 'NOT_ELIGIBLE_FAMILY_EVIDENCE',
    reasons: eligible
        ? const []
        : const ['Verified family evidence must match.'],
    adultIdentityVerified: true,
    minorIdentityVerified: true,
    ageValid: true,
    familyResult: eligible ? 'MATCH' : 'MISMATCH',
    familyExplanation: eligible
        ? 'Verified cards match'
        : 'Verified cards mismatch',
    nameResult: eligible ? 'MATCH' : 'MISMATCH',
    nameExplanation: eligible
        ? 'Verified names match'
        : 'Verified names mismatch',
    nameEvidenceKind: relationship == 'LEGAL_GUARDIAN' ? null : nameKind,
    officialEvidencePresent: official,
    adultDocumentId: 'adult-card',
    minorDocumentId: 'minor-card',
  ),
);

class FakeOpsRepository implements OpsRepository {
  OpsUser user = const OpsUser(
    id: 'reviewer-1',
    email: 'reviewer@example.test',
    role: 'IDENTITY_VERIFICATION_AGENT',
    canVerifyIdentity: true,
  );
  Paged<IdentityQueueItem> identityPage = Paged(
    count: 1,
    items: [
      IdentityQueueItem(
        id: 'identity-1',
        safeName: 'Synthetic Reviewer Subject',
        documentType: 'UNIFIED_NATIONAL_CARD',
        status: 'PENDING',
        createdAt: DateTime.utc(2026, 1, 1),
        corrected: false,
      ),
    ],
  );
  Paged<GuardianQueueItem> guardianPage = Paged(
    count: 1,
    items: [guardianDetail().item],
  );
  IdentityReviewDetail identityValue = identityDetail();
  GuardianReviewDetail guardianValue = guardianDetail();
  Object? identityQueueError;
  Object? guardianQueueError;
  Object? saveError;
  Map<String, String?>? savedFields;
  int? savedVersion;
  String? approvedIdentityId;
  String? rejectedIdentityReason;
  String? approvedGuardianId;
  String? rejectedGuardianReason;
  String? requestedImageSide;
  int logoutCalls = 0;

  @override
  Future<TokenPair> login(String email, String password) async =>
      const TokenPair(access: 'access-token', refresh: 'refresh-token');

  @override
  Future<OpsUser> me() async => user;

  @override
  Future<void> logout(String refresh) async => logoutCalls++;

  @override
  Future<Paged<IdentityQueueItem>> identities() async {
    if (identityQueueError case final error?) throw error;
    return identityPage;
  }

  @override
  Future<IdentityReviewDetail> identity(String id) async => identityValue;

  @override
  Future<IdentityReviewDetail> saveIdentityFields(
    String id,
    int reviewVersion,
    Map<String, String?> fields,
  ) async {
    savedFields = fields;
    savedVersion = reviewVersion;
    if (saveError case final error?) throw error;
    identityValue = identityDetail(reviewVersion: reviewVersion + 1);
    return identityValue;
  }

  @override
  Future<void> approveIdentity(String id) async => approvedIdentityId = id;

  @override
  Future<void> rejectIdentity(String id, String reason) async =>
      rejectedIdentityReason = reason;

  @override
  Future<PrivateImageBytes> identityImage(String id, String side) async {
    requestedImageSide = side;
    return PrivateImageBytes(
      bytes: Uint8List.fromList(_onePixelPng),
      mimeType: 'image/png',
    );
  }

  @override
  Future<Paged<GuardianQueueItem>> guardians() async {
    if (guardianQueueError case final error?) throw error;
    return guardianPage;
  }

  @override
  Future<GuardianReviewDetail> guardian(String id) async => guardianValue;

  @override
  Future<void> approveGuardian(String id) async => approvedGuardianId = id;

  @override
  Future<void> rejectGuardian(String id, String reason) async =>
      rejectedGuardianReason = reason;
}

const _onePixelPng = <int>[
  137,
  80,
  78,
  71,
  13,
  10,
  26,
  10,
  0,
  0,
  0,
  13,
  73,
  72,
  68,
  82,
  0,
  0,
  0,
  1,
  0,
  0,
  0,
  1,
  8,
  6,
  0,
  0,
  0,
  31,
  21,
  196,
  137,
  0,
  0,
  0,
  13,
  73,
  68,
  65,
  84,
  8,
  215,
  99,
  248,
  207,
  192,
  240,
  31,
  0,
  5,
  0,
  1,
  255,
  137,
  153,
  61,
  29,
  0,
  0,
  0,
  0,
  73,
  69,
  78,
  68,
  174,
  66,
  96,
  130,
];
