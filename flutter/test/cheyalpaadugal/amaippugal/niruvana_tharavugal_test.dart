import 'package:flutter_test/flutter_test.dart';
import 'package:elvan_niril/src/cheyalpaadugal/amaippugal/tharavu/niruvana_tharavugal.dart';

/// Tests for the NiruvanaTharavugal domain model.
void main() {
  group('NiruvanaTharavugal Model', () {
    test('Default constructor creates valid empty model', () {
      final model = NiruvanaTharavugal();

      expect(model.id, isNull);
      expect(model.mudhanMozhi, 'Tamil');
      expect(model.thunaiMozhi, 'English');
      expect(model.iruMozhi, isTrue);
      expect(model.niruvanathinPeyar, isEmpty);
      expect(model.kurumPeyar, isEmpty);
      expect(model.tholaipaesi1, isEmpty);
      expect(model.minnanjal, isEmpty);
      expect(model.gstin, isEmpty);
      expect(model.mugavari, isEmpty);
      expect(model.vangiPeyar, isEmpty);
      expect(model.oavuru, isEmpty);
      expect(model.thalaippuVadivu, 'small');
    });

    test('Constructor with bilingual data works correctly', () {
      final model = NiruvanaTharavugal(
        id: 1,
        niruvanathinPeyar: {'Tamil': 'எல்வன்', 'English': 'Elvan'},
        mugavari: {'Tamil': 'சென்னை', 'English': 'Chennai'},
        iruMozhi: true,
      );

      expect(model.id, 1);
      expect(model.niruvanathinPeyar['Tamil'], 'எல்வன்');
      expect(model.niruvanathinPeyar['English'], 'Elvan');
      expect(model.mugavari['Tamil'], 'சென்னை');
    });

    test('getPrimary returns correct language value', () {
      final model = NiruvanaTharavugal(
        mudhanMozhi: 'Tamil',
        niruvanathinPeyar: {'Tamil': 'எல்வன்', 'English': 'Elvan'},
      );

      expect(model.getPrimary('niruvanathinPeyar'), 'எல்வன்');
    });

    test('getSecondary returns correct language value', () {
      final model = NiruvanaTharavugal(
        thunaiMozhi: 'English',
        niruvanathinPeyar: {'Tamil': 'எல்வன்', 'English': 'Elvan'},
      );

      expect(model.getSecondary('niruvanathinPeyar'), 'Elvan');
    });

    test('getPrimary returns empty string for missing language', () {
      final model = NiruvanaTharavugal(
        mudhanMozhi: 'French',
        niruvanathinPeyar: {'Tamil': 'எல்வன்'},
      );

      expect(model.getPrimary('niruvanathinPeyar'), isEmpty);
    });

    test('setBilingual updates the correct field', () {
      final model = NiruvanaTharavugal();
      model.setBilingual('vangiPeyar', 'Tamil', 'இந்தியன் வங்கி');
      model.setBilingual('vangiPeyar', 'English', 'Indian Bank');

      expect(model.vangiPeyar['Tamil'], 'இந்தியன் வங்கி');
      expect(model.vangiPeyar['English'], 'Indian Bank');
    });

    test('copyWith creates independent deep copy', () {
      final original = NiruvanaTharavugal(
        id: 1,
        niruvanathinPeyar: {'Tamil': 'ஒன்று'},
        kurumPeyar: 'Original',
      );

      final copy = original.copyWith(kurumPeyar: 'Copy');

      // Verify the copy has the new value
      expect(copy.kurumPeyar, 'Copy');
      // Verify the original is unchanged
      expect(original.kurumPeyar, 'Original');
      // Verify bilingual maps are independent (deep copy)
      copy.niruvanathinPeyar['Tamil'] = 'மாற்றம்';
      expect(original.niruvanathinPeyar['Tamil'], 'ஒன்று');
    });

    test('copyWith preserves all fields when no overrides given', () {
      final original = NiruvanaTharavugal(
        id: 42,
        mudhanMozhi: 'English',
        thunaiMozhi: 'Tamil',
        iruMozhi: false,
        kurumPeyar: 'Test',
        tholaipaesi1: '9876543210',
        minnanjal: 'test@test.com',
        gstin: '33AAAAA0000A1Z5',
        anjalKuriyeedu: '600001',
        vangiKanakku: '1234567890',
        ifsc: 'IDIB000C001',
        thalaippuVadivu: 'wide',
        upiId: 'test@upi',
      );

      final copy = original.copyWith();

      expect(copy.id, 42);
      expect(copy.mudhanMozhi, 'English');
      expect(copy.thunaiMozhi, 'Tamil');
      expect(copy.iruMozhi, false);
      expect(copy.kurumPeyar, 'Test');
      expect(copy.tholaipaesi1, '9876543210');
      expect(copy.minnanjal, 'test@test.com');
      expect(copy.gstin, '33AAAAA0000A1Z5');
      expect(copy.anjalKuriyeedu, '600001');
      expect(copy.vangiKanakku, '1234567890');
      expect(copy.ifsc, 'IDIB000C001');
      expect(copy.thalaippuVadivu, 'wide');
      expect(copy.upiId, 'test@upi');
    });
  });

  group('NiruvanaTharavugal Bilingual Field Resolution', () {
    test('_getBilingualMap returns empty map for unknown field', () {
      final model = NiruvanaTharavugal();
      // getPrimary calls _getBilingualMap internally
      expect(model.getPrimary('nonExistentField'), isEmpty);
    });

    test('All bilingual field names resolve correctly', () {
      final model = NiruvanaTharavugal(
        niruvanathinPeyar: {'Tamil': 'a'},
        mugavari: {'Tamil': 'b'},
        oor: {'Tamil': 'c'},
        maavattam: {'Tamil': 'd'},
        maanilam: {'Tamil': 'e'},
        naadu: {'Tamil': 'f'},
        vangiPeyar: {'Tamil': 'g'},
        kilai: {'Tamil': 'h'},
        adaimozhi: {'Tamil': 'i'},
      );

      expect(model.getPrimary('niruvanathinPeyar'), 'a');
      expect(model.getPrimary('mugavari'), 'b');
      expect(model.getPrimary('oor'), 'c');
      expect(model.getPrimary('maavattam'), 'd');
      expect(model.getPrimary('maanilam'), 'e');
      expect(model.getPrimary('naadu'), 'f');
      expect(model.getPrimary('vangiPeyar'), 'g');
      expect(model.getPrimary('kilai'), 'h');
      expect(model.getPrimary('adaimozhi'), 'i');
    });
  });
}
