import 'dart:math' as math;

/// Emission factors (kg CO2e per unit). Source: CEA CO2 Baseline Database v21
/// (electricity, FY 2024-25) and IPCC 2006 defaults. Configurable via AppConfig.
class EmissionFactors {
  const EmissionFactors({
    this.electricity = 0.71,
    this.lpg = 2.98,
    this.png = 2.0,
    this.petrol = 2.31,
    this.diesel = 2.68,
    this.cng = 2.75,
    this.busPkm = 0.05,
  });
  final double electricity;
  final double lpg;
  final double png;
  final double petrol;
  final double diesel;
  final double cng;
  final double busPkm;
}

class AppConfig {
  const AppConfig({
    this.avgTariffPerUnit = 6.0,
    this.gujaratAvgHouseholdCo2Kg = 190,
    this.dailySelfPointsCap = 150,
    this.pointsPerUnitSaved = 2,
    this.photoBonus = 5,
    this.solarLeadPoints = 200,
    this.factors = const EmissionFactors(),
    this.solar = const SolarConfig(),
  });
  final double avgTariffPerUnit;
  final double gujaratAvgHouseholdCo2Kg;
  final int dailySelfPointsCap;
  final int pointsPerUnitSaved;
  final int photoBonus;
  final int solarLeadPoints;
  final EmissionFactors factors;
  final SolarConfig solar;

  static const appliancesWatt = <String, double>{
    'ac': 1500,
    'fridge': 150,
    'geyser': 2000,
    'fan': 75,
    'led': 9,
    'tv': 100,
    'washing_machine': 500,
    'pump': 750,
  };
}

class SolarConfig {
  const SolarConfig({
    this.specificYield = 4.2,
    this.areaPerKw = 10,
    this.costPerKwFirst2 = 50000,
    this.costPerKwBeyond = 45000,
    this.centralRateFirst2 = 30000,
    this.centralRateThird = 18000,
    this.centralCap = 78000,
    this.stateSubsidyMaxKw = 2.18,
    this.consumerShareGeneral = 0.10,
    this.consumerShareScSt = 0.05,
    this.exportCreditPerUnit = 2.25,
    this.gridFactor = 0.71,
    this.degradation = 0.9,
    this.years = 25,
  });
  final double specificYield;
  final double areaPerKw;
  final double costPerKwFirst2;
  final double costPerKwBeyond;
  final double centralRateFirst2;
  final double centralRateThird;
  final double centralCap;
  final double stateSubsidyMaxKw;
  final double consumerShareGeneral;
  final double consumerShareScSt;
  final double exportCreditPerUnit;
  final double gridFactor;
  final double degradation;
  final int years;
}

class FootprintInput {
  const FootprintInput({
    this.electricityUnits = 0,
    this.lpgKg = 0,
    this.pngScm = 0,
    this.petrolL = 0,
    this.dieselL = 0,
    this.cngKg = 0,
    this.busKm = 0,
  });
  final double electricityUnits;
  final double lpgKg;
  final double pngScm;
  final double petrolL;
  final double dieselL;
  final double cngKg;
  final double busKm;
}

class FootprintResult {
  const FootprintResult({
    required this.electricityKg,
    required this.cookingKg,
    required this.transportKg,
  });
  final double electricityKg;
  final double cookingKg;
  final double transportKg;

  double get totalKg => electricityKg + cookingKg + transportKg;
  double get treesPerYear => totalKg * 12 / 20;
  double get kmDrivenEquivalent => totalKg / 0.17;
  double get phoneCharges => totalKg / 0.00822; // ~8.22 g CO2 per full charge
}

class FootprintCalculator {
  const FootprintCalculator([this.config = const AppConfig()]);
  final AppConfig config;

  FootprintResult calculate(FootprintInput i) {
    final f = config.factors;
    return FootprintResult(
      electricityKg: i.electricityUnits * f.electricity,
      cookingKg: i.lpgKg * f.lpg + i.pngScm * f.png,
      transportKg: i.petrolL * f.petrol +
          i.dieselL * f.diesel +
          i.cngKg * f.cng +
          i.busKm * f.busPkm,
    );
  }

  double unitsFromBill(double billAmount) =>
      billAmount / config.avgTariffPerUnit;

  /// quiz: map of appliance -> (quantity, hoursPerDay)
  double unitsFromAppliances(Map<String, (int, double)> quiz) {
    double wh = 0;
    quiz.forEach((key, value) {
      final watt = AppConfig.appliancesWatt[key] ?? 0;
      wh += watt * value.$1 * value.$2 * 30;
    });
    return wh / 1000;
  }

  /// Litres of petrol/month from weekly km for a travel mode.
  double petrolLitresFromKm(String mode, double weeklyKm) {
    final monthlyKm = weeklyKm * 4.33;
    return switch (mode) {
      'two_wheeler' => monthlyKm / 45,
      'car' => monthlyKm / 15,
      _ => 0,
    };
  }
}

class SolarResult {
  const SolarResult({
    required this.sizeKw,
    required this.annualGenUnits,
    required this.grossCost,
    required this.centralSubsidy,
    required this.stateSubsidy,
    required this.netCost,
    required this.annualSavings,
    required this.paybackYears,
    required this.co2Avoided25yKg,
    required this.steps,
  });
  final double sizeKw;
  final double annualGenUnits;
  final double grossCost;
  final double centralSubsidy;
  final double stateSubsidy;
  final double netCost;
  final double annualSavings;
  final double? paybackYears;
  final double co2Avoided25yKg;
  final List<(String, String)> steps;
}

class SolarCalculator {
  const SolarCalculator([this.config = const AppConfig()]);
  final AppConfig config;

  static double _roundHalf(double v) => (v * 2).round() / 2;

  SolarResult calculate({
    required double monthlyUnits,
    required double roofAreaM2,
    bool scSt = false,
    double? tariffOverride,
  }) {
    final s = config.solar;
    final tariff = tariffOverride ?? config.avgTariffPerUnit;
    final dailyNeed = monthlyUnits / 30;
    final recommended = dailyNeed / s.specificYield;
    final roofLimit = roofAreaM2 / s.areaPerKw;
    final size = _roundHalf(math.min(recommended, roofLimit)).clamp(1.0, 10.0);
    final annualGen = size * s.specificYield * 365;
    final gross = math.min(size, 2) * s.costPerKwFirst2 +
        math.max(0, size - 2) * s.costPerKwBeyond;
    final central = math.min(
      s.centralCap,
      s.centralRateFirst2 * math.min(size, 2) +
          s.centralRateThird * math.max(0, math.min(size, 3) - 2),
    );
    final share = scSt ? s.consumerShareScSt : s.consumerShareGeneral;
    final state = size <= s.stateSubsidyMaxKw
        ? math.max(0.0, gross - central - share * gross)
        : 0.0;
    final net = gross - central - state;
    final annualConsumption = monthlyUnits * 12;
    final selfConsumed = math.min(annualGen, annualConsumption);
    final savings = selfConsumed * tariff +
        math.max(0, annualGen - annualConsumption) * s.exportCreditPerUnit;
    final payback = savings > 0 ? net / savings : null;
    final co2 = annualGen * s.gridFactor * s.years * s.degradation;

    return SolarResult(
      sizeKw: size,
      annualGenUnits: annualGen,
      grossCost: gross,
      centralSubsidy: central,
      stateSubsidy: state,
      netCost: net,
      annualSavings: savings,
      paybackYears: payback,
      co2Avoided25yKg: co2,
      steps: [
        ('Daily need', '${dailyNeed.toStringAsFixed(1)} units/day'),
        (
          'Recommended size',
          '${recommended.toStringAsFixed(2)} kW (÷ ${s.specificYield} units/kW/day)'
        ),
        (
          'Roof-limited size',
          '${roofLimit.toStringAsFixed(1)} kW (${s.areaPerKw.toInt()} m² per kW)'
        ),
        ('Final size', '${size.toStringAsFixed(1)} kW'),
        ('Annual generation', '${annualGen.round()} units'),
        ('Gross cost', '₹${gross.round()}'),
        ('Central subsidy (PM Surya Ghar)', '₹${central.round()}'),
        ('Gujarat state subsidy', '₹${state.round()}'),
        ('Net cost', '₹${net.round()}'),
        ('Annual savings', '₹${savings.round()} @ ₹$tariff/unit'),
        (
          'Payback',
          payback == null ? '—' : '${payback.toStringAsFixed(1)} years'
        ),
        ('CO₂ avoided (25 yrs)', '${(co2 / 1000).toStringAsFixed(1)} tonnes'),
      ],
    );
  }
}

class LevelEngine {
  static const levels = [
    ('seedling', 'Seedling', 0, '🌱'),
    ('sapling', 'Sapling', 200, '🌿'),
    ('tree', 'Tree', 600, '🌳'),
    ('grove', 'Grove', 1500, '🌲'),
    ('forest', 'Forest', 4000, '🏞️'),
    ('champion', 'Pro-Planet Champion', 10000, '🏆'),
  ];

  static (String id, String name, int min, String emoji) levelFor(int points) {
    var current = levels.first;
    for (final l in levels) {
      if (points >= l.$3) current = l;
    }
    return current;
  }

  static (String, String, int, String)? nextLevel(int points) {
    for (final l in levels) {
      if (points < l.$3) return l;
    }
    return null;
  }

  /// 0..1 progress within the current level band.
  static double progress(int points) {
    final cur = levelFor(points);
    final next = nextLevel(points);
    if (next == null) return 1;
    return ((points - cur.$3) / (next.$3 - cur.$3)).clamp(0, 1);
  }
}
