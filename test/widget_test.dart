// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasi_warisan/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AplikasiWarisan());
  });
}
