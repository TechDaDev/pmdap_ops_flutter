import 'package:flutter_test/flutter_test.dart';
import 'package:pmdap_operations/core/models.dart';

void main() {
  test('unknown enums fail safe without dynamic widget decisions', () {
    final item = IdentityQueueItem.fromJson({
      'uuid': 'synthetic-id',
      'patient': {'full_name': 'Synthetic Person'},
      'document_type': 'FUTURE_DOCUMENT',
      'verification_status': 'FUTURE_STATUS',
      'has_corrections': false,
    });

    expect(item.documentType, 'UNKNOWN');
    expect(item.status, 'UNKNOWN');
  });

  test('identity contract maps typed reviewed fields and actions', () {
    final detail = IdentityReviewDetail.fromJson({
      'uuid': 'synthetic-id',
      'patient': {'full_name': 'Synthetic Person'},
      'document_type': 'UNIFIED_NATIONAL_CARD',
      'verification_status': 'PENDING',
      'review_version': 4,
      'review_fields': {
        'national_number': {
          'original': 'synthetic-original',
          'reviewed': 'synthetic-reviewed',
          'corrected': true,
        },
      },
      'available_actions': ['review_fields', 'approve', 'reject'],
      'has_corrections': true,
    });

    expect(detail.reviewVersion, 4);
    expect(detail.fields.single.corrected, isTrue);
    expect(detail.availableActions, contains('approve'));
  });

  test('guardian evaluation consumes backend verdict only', () {
    final detail = GuardianReviewDetail.fromJson({
      'uuid': 'relationship-id',
      'relationship': 'MOTHER',
      'verification_status': 'PENDING',
      'review_readiness': 'EVIDENCE_INCOMPLETE',
      'guardian_patient': {'full_name': 'Synthetic Adult'},
      'minor_patient': {'full_name': 'Synthetic Minor'},
      'approval_evaluation': {
        'eligible': false,
        'code': 'NOT_ELIGIBLE_MOTHER_NAME_EVIDENCE',
        'reasons': ['Verified mother-name evidence must match.'],
        'adult_identity_verified': true,
        'minor_identity_verified': true,
        'age_valid': true,
        'family_result': 'MATCH',
        'family_explanation': 'Match',
        'name_result': 'MISMATCH',
        'name_explanation': 'Mismatch',
        'name_evidence_kind': 'MOTHER',
        'official_evidence_present': false,
      },
    });

    expect(detail.evaluation.eligible, isFalse);
    expect(detail.evaluation.nameEvidenceKind, 'MOTHER');
    expect(detail.evaluation.code, 'NOT_ELIGIBLE_MOTHER_NAME_EVIDENCE');
  });
}
