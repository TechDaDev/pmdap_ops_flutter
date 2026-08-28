// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'عمليات PMDAP';

  @override
  String get login => 'دخول المراجع';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get unsupportedRole => 'هذا الحساب غير مخول لاستخدام تطبيق العمليات.';

  @override
  String get sessionExpired => 'انتهت الجلسة. سجل الدخول مجدداً.';

  @override
  String get identityVerification => 'تدقيق الهوية';

  @override
  String get guardianRelationships => 'علاقات الولاية';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noRequests => 'لا توجد طلبات بانتظار المراجعة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get refresh => 'تحديث';

  @override
  String get approve => 'موافقة';

  @override
  String get reject => 'رفض';

  @override
  String get saveCorrections => 'حفظ التصحيحات';

  @override
  String get reason => 'السبب';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get front => 'الأمام';

  @override
  String get back => 'الخلف';

  @override
  String get corrected => 'مصحح';

  @override
  String get readyForReview => 'جاهز للمراجعة';

  @override
  String get evidenceIncomplete => 'الأدلة غير مكتملة';

  @override
  String get identityDetail => 'تفاصيل الهوية';

  @override
  String get guardianDetail => 'أدلة الولاية';

  @override
  String get original => 'الأصل/الاستخراج';

  @override
  String get reviewed => 'القيمة المراجعة';

  @override
  String get lightTheme => 'فاتح';

  @override
  String get darkTheme => 'داكن';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get requiredField => 'مطلوب';

  @override
  String get unableToLoad => 'تعذر تحميل الطلبات.';

  @override
  String get reviewQueues => 'قوائم المراجعة';

  @override
  String get displaySettings => 'إعدادات العرض';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get fatherName => 'اسم الأب';

  @override
  String get grandfatherName => 'اسم الجد';

  @override
  String get motherName => 'اسم الأم';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get sex => 'الجنس';

  @override
  String get bloodGroup => 'فصيلة الدم';

  @override
  String get nationality => 'الجنسية';

  @override
  String get nationalNumber => 'الرقم الوطني';

  @override
  String get cardBodyNumber => 'رقم جسم البطاقة';

  @override
  String get familyNumber => 'رقم العائلة';

  @override
  String get issueDate => 'تاريخ الإصدار';

  @override
  String get expiryDate => 'تاريخ الانتهاء';

  @override
  String get reviewChanged => 'تغيرت المراجعة على الخادم. تم تحميل أحدث القيم.';

  @override
  String get approveIdentityTitle => 'الموافقة على الهوية؟';

  @override
  String get approveIdentityMessage =>
      'سيعتمد الخادم القيم المراجعة بوصفها القيم الرسمية.';

  @override
  String get rejectIdentityTitle => 'رفض الهوية';

  @override
  String get adultIdentity => 'هوية البالغ';

  @override
  String get minorIdentity => 'هوية القاصر';

  @override
  String get relationshipEvidence => 'أدلة العلاقة';

  @override
  String get adultIdentityVerified => 'هوية البالغ موثقة';

  @override
  String get minorIdentityVerified => 'هوية القاصر موثقة';

  @override
  String get ageEligible => 'العمر مستوفٍ للشروط';

  @override
  String familyEvidence(String result) {
    return 'دليل العائلة: $result';
  }

  @override
  String get officialEvidence => 'دليل الولاية الرسمي';

  @override
  String get approveGuardianTitle => 'الموافقة على علاقة الولاية؟';

  @override
  String get approveGuardianMessage =>
      'سيعيد الخادم التحقق من جميع الأدلة قبل الموافقة.';

  @override
  String get rejectGuardianTitle => 'رفض علاقة الولاية';

  @override
  String get verified => 'موثق';

  @override
  String get notVerified => 'غير موثق';

  @override
  String get viewCard => 'عرض البطاقة';

  @override
  String get pass => 'مستوفى';

  @override
  String get blocked => 'غير مستوفى';

  @override
  String get notSatisfied => 'غير مستوفى';

  @override
  String get familyMatch => 'البطاقات الموثقة متطابقة';

  @override
  String get familyMismatch => 'البطاقات الموثقة غير متطابقة';

  @override
  String get nameMatch => 'الأسماء الموثقة متطابقة';

  @override
  String get nameMismatch => 'الأسماء الموثقة غير متطابقة';

  @override
  String imageSemantics(String side) {
    return 'صورة $side لبطاقة الهوية. قرّب بإصبعين واسحب للتحريك.';
  }
}
