import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_domain/shared_domain.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgets('resumed server document is not uploaded as a local file; tracking uses parent gate', (tester) async {
    var uploads = 0;
    var submitted = false;
    var completed = false;
    await tester.binding.setSurfaceSize(const Size(720, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(theme: SportoTheme.darkTheme,
      home: AutomatedOnboardingWizard(
        user: const UserEntity(id: 'test', name: 'Test Referee', email: 'test@example.com',
          mobileNumber: '9999999999', role: 'referee'),
        initialStep: 6,
        initialData: const InitialOnboardingData(documents: {'government_id': 'referee/documents/existing.jpg'}),
        onUploadDocumentFile: (_, path) async { uploads++; throw StateError('Server file re-uploaded'); },
        onSubmitOnboarding: (submission) async {
          expect(submission.governmentIdPath, 'referee/documents/existing.jpg');
          submitted = true;
        },
        onComplete: (_) => completed = true,
      )));
    await tester.pumpAndSettle();
    await tester.tap(find.text('I confirm all information is accurate.'));
    await tester.pump();
    await tester.ensureVisible(find.text('Submit Application'));
    await tester.tap(find.text('Submit Application'));
    await tester.pump(const Duration(seconds: 1));
    expect(submitted, isTrue);
    expect(uploads, 0);
    await tester.ensureVisible(find.text('Track Application'));
    await tester.tap(find.text('Track Application'));
    await tester.pump();
    expect(completed, isTrue);
    expect(find.byType(ApplicationStatusScreen), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
