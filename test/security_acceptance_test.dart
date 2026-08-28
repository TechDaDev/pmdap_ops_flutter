import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android activity enforces FLAG_SECURE', () {
    final source = File(
      'android/app/src/main/kotlin/com/pmdap/operations/MainActivity.kt',
    ).readAsStringSync();

    expect(source, contains('WindowManager.LayoutParams.FLAG_SECURE'));
    expect(source, contains('window.addFlags'));
  });

  test('client source contains no HTTP body logger or public image URL', () {
    final source = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => file.readAsStringSync())
        .join('\n');

    expect(source, isNot(contains('LogInterceptor')));
    expect(source, isNot(contains('print(')));
    expect(source, isNot(contains('Image.network')));
    expect(source, isNot(contains('shared_preferences')));
    expect(source, contains('flutter_secure_storage'));
    expect(source, contains('ResponseType.bytes'));
    expect(source, contains('fillRange(0'));
  });

  test('Android manifest requests no broad media or storage permission', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, isNot(contains('READ_MEDIA_IMAGES')));
    expect(manifest, isNot(contains('WRITE_EXTERNAL_STORAGE')));
    expect(manifest, isNot(contains('MANAGE_EXTERNAL_STORAGE')));
  });
}
