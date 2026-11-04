import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_mitra/core/services/proof_picker.dart';
import 'package:life_mitra/core/widgets/proof_picker_sheet.dart';

void main() {
  group('PickedProof', () {
    test('exposes byte size for the UI label', () {
      final proof = PickedProof(
        bytes: Uint8List.fromList(List.filled(2048, 1)),
        contentType: 'image/jpeg',
        fileName: 'bill.jpg',
      );
      expect(proof.sizeBytes, 2048);
      expect(proof.contentType, 'image/jpeg');
    });

    test('limits match the server-side storage rules', () {
      expect(ProofPicker.maxBytes, 10 * 1024 * 1024);
      expect(
          ProofPicker.allowedTypes, {'image/jpeg', 'image/png', 'image/webp'});
    });
  });

  group('ProofPickerException', () {
    test('renders a user-readable message', () {
      const error = ProofPickerException('Camera permission denied.');
      expect(error.toString(), 'Camera permission denied.');
    });
  });

  group('showProofPickerSheet', () {
    testWidgets('offers camera + gallery and blocks confirm until a photo',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showProofPickerSheet(context),
              child: const Text('open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Choose a photo first'), findsOneWidget);

      // Confirm button must be disabled before a photo is picked.
      // PrimaryButton renders a FilledButton internally.
      final confirm = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Choose a photo first'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(confirm.onPressed, isNull);
    });
  });
}
