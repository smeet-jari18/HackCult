import 'package:flutter_test/flutter_test.dart';
import 'package:life_mitra/core/logic/calculators.dart';

void main() {
  const config = AppConfig();

  group('SolarCalculator', () {
    test('250 units → 2 kW, net ≈ ₹10,000 with Gujarat state subsidy', () {
      final r = SolarCalculator(config)
          .calculate(monthlyUnits: 250, roofAreaM2: 30, scSt: false);
      expect(r.sizeKw, closeTo(2, 0.01));
      expect(r.grossCost, 100000);
      expect(r.centralSubsidy, 60000);
      expect(r.stateSubsidy, 30000);
      expect(r.netCost, 10000);
      expect(r.paybackYears, lessThan(1.5));
    });

    test('3 kW gets central cap ₹78,000 and no state subsidy', () {
      final r = SolarCalculator(config)
          .calculate(monthlyUnits: 380, roofAreaM2: 40, scSt: false);
      expect(r.sizeKw, closeTo(3, 0.01));
      expect(r.centralSubsidy, 78000);
      expect(r.stateSubsidy, 0);
    });

    test('roof area caps the system size', () {
      final r = SolarCalculator(config)
          .calculate(monthlyUnits: 600, roofAreaM2: 10, scSt: false);
      expect(r.sizeKw, lessThanOrEqualTo(1.0));
    });
  });

  group('FootprintCalculator', () {
    test('electricity uses 0.71 kg/unit', () {
      final r = FootprintCalculator(config)
          .calculate(const FootprintInput(electricityUnits: 100));
      expect(r.electricityKg, closeTo(71, 0.01));
    });
  });

  group('LevelEngine', () {
    test('levels thresholds', () {
      expect(LevelEngine.levelFor(0).$2, 'Seedling');
      expect(LevelEngine.levelFor(200).$2, 'Sapling');
      expect(LevelEngine.levelFor(599).$2, 'Sapling');
      expect(LevelEngine.levelFor(600).$2, 'Tree');
      expect(LevelEngine.levelFor(10000).$2, 'Pro-Planet Champion');
    });
  });
}
