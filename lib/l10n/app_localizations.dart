import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PMDAP Operations'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Reviewer login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @unsupportedRole.
  ///
  /// In en, this message translates to:
  /// **'This account cannot use PMDAP Operations.'**
  String get unsupportedRole;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Sign in again.'**
  String get sessionExpired;

  /// No description provided for @identityVerification.
  ///
  /// In en, this message translates to:
  /// **'Identity verification'**
  String get identityVerification;

  /// No description provided for @guardianRelationships.
  ///
  /// In en, this message translates to:
  /// **'Guardian relationships'**
  String get guardianRelationships;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'pending'**
  String get pending;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests awaiting review'**
  String get noRequests;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @saveCorrections.
  ///
  /// In en, this message translates to:
  /// **'Save corrections'**
  String get saveCorrections;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @front.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get front;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @corrected.
  ///
  /// In en, this message translates to:
  /// **'Corrected'**
  String get corrected;

  /// No description provided for @readyForReview.
  ///
  /// In en, this message translates to:
  /// **'Ready for review'**
  String get readyForReview;

  /// No description provided for @evidenceIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Evidence incomplete'**
  String get evidenceIncomplete;

  /// No description provided for @identityDetail.
  ///
  /// In en, this message translates to:
  /// **'Identity detail'**
  String get identityDetail;

  /// No description provided for @guardianDetail.
  ///
  /// In en, this message translates to:
  /// **'Guardian evidence'**
  String get guardianDetail;

  /// No description provided for @original.
  ///
  /// In en, this message translates to:
  /// **'OCR/original'**
  String get original;

  /// No description provided for @reviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get reviewed;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @unableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load requests.'**
  String get unableToLoad;

  /// No description provided for @reviewQueues.
  ///
  /// In en, this message translates to:
  /// **'Review queues'**
  String get reviewQueues;

  /// No description provided for @displaySettings.
  ///
  /// In en, this message translates to:
  /// **'Display settings'**
  String get displaySettings;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @fatherName.
  ///
  /// In en, this message translates to:
  /// **'Father\'s name'**
  String get fatherName;

  /// No description provided for @grandfatherName.
  ///
  /// In en, this message translates to:
  /// **'Grandfather\'s name'**
  String get grandfatherName;

  /// No description provided for @motherName.
  ///
  /// In en, this message translates to:
  /// **'Mother\'s name'**
  String get motherName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'DOB'**
  String get dateOfBirth;

  /// No description provided for @sex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sex;

  /// No description provided for @bloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood group'**
  String get bloodGroup;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @nationalNumber.
  ///
  /// In en, this message translates to:
  /// **'National number'**
  String get nationalNumber;

  /// No description provided for @cardBodyNumber.
  ///
  /// In en, this message translates to:
  /// **'Card body number'**
  String get cardBodyNumber;

  /// No description provided for @familyNumber.
  ///
  /// In en, this message translates to:
  /// **'Family number'**
  String get familyNumber;

  /// No description provided for @issueDate.
  ///
  /// In en, this message translates to:
  /// **'Issue date'**
  String get issueDate;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get expiryDate;

  /// No description provided for @reviewChanged.
  ///
  /// In en, this message translates to:
  /// **'Review changed on server. Reloaded latest values.'**
  String get reviewChanged;

  /// No description provided for @approveIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve identity?'**
  String get approveIdentityTitle;

  /// No description provided for @approveIdentityMessage.
  ///
  /// In en, this message translates to:
  /// **'The backend will promote reviewed values as authoritative.'**
  String get approveIdentityMessage;

  /// No description provided for @rejectIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject identity'**
  String get rejectIdentityTitle;

  /// No description provided for @adultIdentity.
  ///
  /// In en, this message translates to:
  /// **'Adult identity'**
  String get adultIdentity;

  /// No description provided for @minorIdentity.
  ///
  /// In en, this message translates to:
  /// **'Minor identity'**
  String get minorIdentity;

  /// No description provided for @relationshipEvidence.
  ///
  /// In en, this message translates to:
  /// **'Relationship evidence'**
  String get relationshipEvidence;

  /// No description provided for @adultIdentityVerified.
  ///
  /// In en, this message translates to:
  /// **'Adult identity verified'**
  String get adultIdentityVerified;

  /// No description provided for @minorIdentityVerified.
  ///
  /// In en, this message translates to:
  /// **'Minor identity verified'**
  String get minorIdentityVerified;

  /// No description provided for @ageEligible.
  ///
  /// In en, this message translates to:
  /// **'Age eligible'**
  String get ageEligible;

  /// No description provided for @familyEvidence.
  ///
  /// In en, this message translates to:
  /// **'Family evidence: {result}'**
  String familyEvidence(String result);

  /// No description provided for @officialEvidence.
  ///
  /// In en, this message translates to:
  /// **'Official guardianship evidence'**
  String get officialEvidence;

  /// No description provided for @approveGuardianTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve guardian relationship?'**
  String get approveGuardianTitle;

  /// No description provided for @approveGuardianMessage.
  ///
  /// In en, this message translates to:
  /// **'The backend will re-check all evidence before approval.'**
  String get approveGuardianMessage;

  /// No description provided for @rejectGuardianTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject guardian relationship'**
  String get rejectGuardianTitle;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @notVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get notVerified;

  /// No description provided for @viewCard.
  ///
  /// In en, this message translates to:
  /// **'View card'**
  String get viewCard;

  /// No description provided for @pass.
  ///
  /// In en, this message translates to:
  /// **'PASS'**
  String get pass;

  /// No description provided for @blocked.
  ///
  /// In en, this message translates to:
  /// **'BLOCKED'**
  String get blocked;

  /// No description provided for @notSatisfied.
  ///
  /// In en, this message translates to:
  /// **'not satisfied'**
  String get notSatisfied;

  /// No description provided for @familyMatch.
  ///
  /// In en, this message translates to:
  /// **'Verified cards match'**
  String get familyMatch;

  /// No description provided for @familyMismatch.
  ///
  /// In en, this message translates to:
  /// **'Verified cards do not match'**
  String get familyMismatch;

  /// No description provided for @nameMatch.
  ///
  /// In en, this message translates to:
  /// **'Verified names match'**
  String get nameMatch;

  /// No description provided for @nameMismatch.
  ///
  /// In en, this message translates to:
  /// **'Verified names do not match'**
  String get nameMismatch;

  /// No description provided for @imageSemantics.
  ///
  /// In en, this message translates to:
  /// **'{side} identity card image. Pinch to zoom and drag to pan.'**
  String imageSemantics(String side);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
