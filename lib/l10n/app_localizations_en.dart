// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PMDAP Operations';

  @override
  String get login => 'Reviewer login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get unsupportedRole => 'This account cannot use PMDAP Operations.';

  @override
  String get sessionExpired => 'Session expired. Sign in again.';

  @override
  String get identityVerification => 'Identity verification';

  @override
  String get guardianRelationships => 'Guardian relationships';

  @override
  String get pending => 'pending';

  @override
  String get retry => 'Retry';

  @override
  String get noRequests => 'No requests awaiting review';

  @override
  String get logout => 'Logout';

  @override
  String get refresh => 'Refresh';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get saveCorrections => 'Save corrections';

  @override
  String get reason => 'Reason';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get front => 'Front';

  @override
  String get back => 'Back';

  @override
  String get corrected => 'Corrected';

  @override
  String get readyForReview => 'Ready for review';

  @override
  String get evidenceIncomplete => 'Evidence incomplete';

  @override
  String get identityDetail => 'Identity detail';

  @override
  String get guardianDetail => 'Guardian evidence';

  @override
  String get original => 'OCR/original';

  @override
  String get reviewed => 'Reviewed';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get requiredField => 'Required';

  @override
  String get unableToLoad => 'Unable to load requests.';

  @override
  String get reviewQueues => 'Review queues';

  @override
  String get displaySettings => 'Display settings';

  @override
  String get firstName => 'First name';

  @override
  String get fatherName => 'Father\'s name';

  @override
  String get grandfatherName => 'Grandfather\'s name';

  @override
  String get motherName => 'Mother\'s name';

  @override
  String get dateOfBirth => 'DOB';

  @override
  String get sex => 'Sex';

  @override
  String get bloodGroup => 'Blood group';

  @override
  String get nationality => 'Nationality';

  @override
  String get nationalNumber => 'National number';

  @override
  String get cardBodyNumber => 'Card body number';

  @override
  String get familyNumber => 'Family number';

  @override
  String get issueDate => 'Issue date';

  @override
  String get expiryDate => 'Expiry date';

  @override
  String get reviewChanged =>
      'Review changed on server. Reloaded latest values.';

  @override
  String get approveIdentityTitle => 'Approve identity?';

  @override
  String get approveIdentityMessage =>
      'The backend will promote reviewed values as authoritative.';

  @override
  String get rejectIdentityTitle => 'Reject identity';

  @override
  String get adultIdentity => 'Adult identity';

  @override
  String get minorIdentity => 'Minor identity';

  @override
  String get relationshipEvidence => 'Relationship evidence';

  @override
  String get adultIdentityVerified => 'Adult identity verified';

  @override
  String get minorIdentityVerified => 'Minor identity verified';

  @override
  String get ageEligible => 'Age eligible';

  @override
  String familyEvidence(String result) {
    return 'Family evidence: $result';
  }

  @override
  String get officialEvidence => 'Official guardianship evidence';

  @override
  String get approveGuardianTitle => 'Approve guardian relationship?';

  @override
  String get approveGuardianMessage =>
      'The backend will re-check all evidence before approval.';

  @override
  String get rejectGuardianTitle => 'Reject guardian relationship';

  @override
  String get verified => 'Verified';

  @override
  String get notVerified => 'Not verified';

  @override
  String get viewCard => 'View card';

  @override
  String get pass => 'PASS';

  @override
  String get blocked => 'BLOCKED';

  @override
  String get notSatisfied => 'not satisfied';

  @override
  String get familyMatch => 'Verified cards match';

  @override
  String get familyMismatch => 'Verified cards do not match';

  @override
  String get nameMatch => 'Verified names match';

  @override
  String get nameMismatch => 'Verified names do not match';

  @override
  String imageSemantics(String side) {
    return '$side identity card image. Pinch to zoom and drag to pan.';
  }
}
