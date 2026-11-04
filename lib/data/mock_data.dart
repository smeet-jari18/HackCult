import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'models.dart';

/// Static reference + demo data. Replace with Firestore repositories later
/// (collections: tasks, badges, vendors, schemes, communities, adminMetrics).
class MockData {
  MockData._();

  static const gujaratDistricts = <String>[
    'Ahmedabad',
    'Amreli',
    'Anand',
    'Aravalli',
    'Banaskantha',
    'Bharuch',
    'Bhavnagar',
    'Botad',
    'Chhota Udaipur',
    'Dahod',
    'Dang',
    'Devbhoomi Dwarka',
    'Gandhinagar',
    'Gir Somnath',
    'Jamnagar',
    'Junagadh',
    'Kheda',
    'Kutch',
    'Mahisagar',
    'Mehsana',
    'Morbi',
    'Narmada',
    'Navsari',
    'Panchmahal',
    'Patan',
    'Porbandar',
    'Rajkot',
    'Sabarkantha',
    'Surat',
    'Surendranagar',
    'Tapi',
    'Vadodara',
    'Valsad',
  ];

  static String districtFromPin(String pin) {
    if (pin.length < 3) return 'Ahmedabad';
    final p = pin.substring(0, 3);
    return switch (p) {
      '380' || '382' => pin.startsWith('3820') ? 'Gandhinagar' : 'Ahmedabad',
      '390' || '391' => 'Vadodara',
      '395' || '394' => 'Surat',
      '360' => 'Rajkot',
      '364' => 'Bhavnagar',
      '361' => 'Jamnagar',
      '362' => 'Junagadh',
      '370' => 'Kutch',
      '384' => 'Mehsana',
      '388' => 'Anand',
      '387' => 'Kheda',
      '392' => 'Bharuch',
      '396' => 'Valsad',
      _ => 'Ahmedabad',
    };
  }

  static const appliances = <(String, String, IconData)>[
    ('ac', 'Air conditioner', Icons.ac_unit_rounded),
    ('geyser', 'Geyser', Icons.hot_tub_rounded),
    ('washing_machine', 'Washing machine', Icons.local_laundry_service_rounded),
    ('pump', 'Water pump', Icons.water_rounded),
    ('fridge', 'Refrigerator', Icons.kitchen_rounded),
    ('inverter', 'Inverter', Icons.battery_charging_full_rounded),
    ('ev', 'Electric vehicle', Icons.electric_car_rounded),
  ];

  static const tasks = <TaskItem>[
    TaskItem(
      id: 'ac_24',
      title: 'Set AC to 24°C today',
      theme: LifeTheme.saveEnergy,
      difficulty: Difficulty.easy,
      points: 20,
      verification: Verification.photo,
      applianceTags: ['ac'],
      description:
          'Every degree below 24°C adds ~6% to your AC bill. 24°C with a fan feels just as cool.',
      steps: [
        'Set the remote to 24°C',
        'Switch on the ceiling fan',
        'Take a photo of the display'
      ],
      estUnitsSaved: 1.5,
      estCo2Kg: 1.1,
      estRupees: 9,
    ),
    TaskItem(
      id: 'load_shift_wm',
      title: 'Run washing machine before 6 pm or after 11 pm',
      theme: LifeTheme.saveEnergy,
      difficulty: Difficulty.easy,
      points: 15,
      verification: Verification.self,
      applianceTags: ['washing_machine'],
      description:
          'Evening peak (6–11 pm) is powered by costly thermal plants. Shifting heavy loads eases the grid.',
      steps: [
        'Plan laundry for midday or late night',
        'Mark done after the cycle'
      ],
      estUnitsSaved: 0.5,
      estCo2Kg: 0.4,
      estRupees: 6,
    ),
    TaskItem(
      id: 'led_swap',
      title: 'Replace one bulb with LED',
      theme: LifeTheme.saveEnergy,
      difficulty: Difficulty.medium,
      points: 30,
      verification: Verification.photo,
      description:
          'A 9 W LED gives the same light as a 60 W bulb and lasts 10× longer.',
      steps: [
        'Buy a BEE star-rated LED',
        'Replace the most-used bulb',
        'Photo of the new bulb'
      ],
      estUnitsSaved: 5,
      estCo2Kg: 3.6,
      estRupees: 30,
    ),
    TaskItem(
      id: 'standby_off',
      title: 'Switch off standby loads tonight',
      theme: LifeTheme.saveEnergy,
      difficulty: Difficulty.easy,
      points: 5,
      verification: Verification.self,
      description:
          'TV, set-top box and chargers on standby waste up to 10 units a month.',
      steps: ['Turn off at the switchboard before bed'],
      estUnitsSaved: 0.3,
      estCo2Kg: 0.2,
      estRupees: 2,
    ),
    TaskItem(
      id: 'geyser_timer',
      title: 'Limit geyser to 15 minutes',
      theme: LifeTheme.saveEnergy,
      difficulty: Difficulty.medium,
      points: 25,
      verification: Verification.self,
      applianceTags: ['geyser'],
      description:
          'A 2 kW geyser left on for an hour burns 2 units. 15 minutes is enough for a family bath.',
      steps: ['Switch on 15 min before use', 'Switch off before bathing'],
      estUnitsSaved: 1.5,
      estCo2Kg: 1.1,
      estRupees: 9,
    ),
    TaskItem(
      id: 'midday_heavy_load',
      title: 'Run heavy appliances in solar hours (11–3)',
      theme: LifeTheme.saveEnergy,
      difficulty: Difficulty.easy,
      points: 10,
      verification: Verification.self,
      description:
          'Midday grid power in Gujarat is the greenest thanks to solar parks.',
      estUnitsSaved: 0.4,
      estCo2Kg: 0.3,
      estRupees: 3,
    ),
    TaskItem(
      id: 'bucket_bath',
      title: 'Bucket bath instead of shower',
      theme: LifeTheme.saveWater,
      difficulty: Difficulty.easy,
      points: 5,
      verification: Verification.self,
      description:
          'Saves ~40 litres of water and the energy used to pump and heat it.',
      estCo2Kg: 0.1,
    ),
    TaskItem(
      id: 'cloth_bag',
      title: 'Carry a cloth bag for shopping',
      theme: LifeTheme.noPlastic,
      difficulty: Difficulty.easy,
      points: 5,
      verification: Verification.photo,
      description:
          'One cloth bag replaces ~500 plastic bags over its lifetime.',
      estCo2Kg: 0.05,
    ),
    TaskItem(
      id: 'local_seasonal_meal',
      title: 'Cook a local, seasonal meal',
      theme: LifeTheme.sustainableFood,
      difficulty: Difficulty.easy,
      points: 5,
      verification: Verification.self,
      description:
          'Millets and seasonal vegetables need less water, transport and cold storage.',
      estCo2Kg: 0.3,
    ),
    TaskItem(
      id: 'waste_segregate',
      title: 'Segregate wet & dry waste today',
      theme: LifeTheme.reduceWaste,
      difficulty: Difficulty.easy,
      points: 10,
      verification: Verification.photo,
      description:
          'Segregated waste can be composted or recycled instead of releasing methane in landfills.',
      estCo2Kg: 0.4,
    ),
    TaskItem(
      id: 'walk_short_trip',
      title: 'Walk or cycle a trip under 2 km',
      theme: LifeTheme.healthyLifestyle,
      difficulty: Difficulty.easy,
      points: 15,
      verification: Verification.self,
      description:
          'Short two-wheeler trips are the least efficient — cold engines pollute most.',
      estCo2Kg: 0.2,
      estRupees: 8,
    ),
    TaskItem(
      id: 'ewaste_drop',
      title: 'Drop old batteries/phone at an e-waste centre',
      theme: LifeTheme.reduceEwaste,
      difficulty: Difficulty.medium,
      points: 30,
      verification: Verification.photo,
      description:
          'E-waste contains lead and mercury; authorised recyclers recover metals safely.',
      estCo2Kg: 1.0,
    ),
    TaskItem(
      id: 'upload_bill',
      title: 'Upload this month\'s electricity bill',
      theme: LifeTheme.saveEnergy,
      difficulty: Difficulty.medium,
      points: 50,
      verification: Verification.bill,
      description:
          'Verified savings earn 2 points per unit saved versus your baseline.',
    ),
    TaskItem(
      id: 'solar_assessment',
      title: 'Check your rooftop solar feasibility',
      theme: LifeTheme.saveEnergy,
      difficulty: Difficulty.easy,
      points: 20,
      verification: Verification.self,
      description:
          'A 2 kW system in Gujarat can cover a 250-unit household after subsidies.',
    ),
    TaskItem(
      id: 'diwali_led_lights',
      title: 'Use LED string lights & diyas this Diwali',
      theme: LifeTheme.saveEnergy,
      difficulty: Difficulty.easy,
      points: 10,
      verification: Verification.photo,
      seasonTags: ['diwali'],
      description:
          'LED strings use 80% less power than incandescent decorative lights.',
      estUnitsSaved: 2,
      estCo2Kg: 1.4,
      estRupees: 12,
    ),
  ];

  static TaskItem taskById(String id) =>
      tasks.firstWhere((t) => t.id == id, orElse: () => tasks.first);

  static const badges = <BadgeItem>[
    BadgeItem(
        id: 'first_step',
        name: 'First Step',
        description: 'Completed your first task',
        icon: Icons.flag_rounded,
        color: AppColors.primary),
    BadgeItem(
        id: 'peak_shifter',
        name: 'Peak Shifter',
        description: 'Shifted heavy loads off-peak 5 times',
        icon: Icons.schedule_rounded,
        color: AppColors.warning),
    BadgeItem(
        id: 'led_legend',
        name: 'LED Legend',
        description: 'Replaced 5 bulbs with LEDs',
        icon: Icons.lightbulb_rounded,
        color: AppColors.secondary),
    BadgeItem(
        id: 'streak_7',
        name: '7-Day Streak',
        description: 'Active for 7 days in a row',
        icon: Icons.local_fire_department_rounded,
        color: Color(0xFFE65100)),
    BadgeItem(
        id: 'streak_30',
        name: '30-Day Streak',
        description: 'Active for 30 days in a row',
        icon: Icons.whatshot_rounded,
        color: Color(0xFFD84315)),
    BadgeItem(
        id: 'bill_verified',
        name: 'Bill Verified',
        description: 'Uploaded a bill showing real savings',
        icon: Icons.receipt_long_rounded,
        color: AppColors.tertiary),
    BadgeItem(
        id: 'solar_pioneer_lead',
        name: 'Solar Explorer',
        description: 'Requested a rooftop solar survey',
        icon: Icons.wb_sunny_rounded,
        color: AppColors.secondary),
    BadgeItem(
        id: 'solar_pioneer',
        name: 'Solar Pioneer',
        description: 'Installed rooftop solar',
        icon: Icons.solar_power_rounded,
        color: Color(0xFFF57F17)),
    BadgeItem(
        id: 'plastic_free_week',
        name: 'Plastic-Free Week',
        description: '7 plastic-free actions in a week',
        icon: Icons.shopping_bag_rounded,
        color: AppColors.themePlastic),
    BadgeItem(
        id: 'community_builder',
        name: 'Community Builder',
        description: 'Created a community',
        icon: Icons.groups_rounded,
        color: AppColors.themeHealthy),
  ];

  static TaskItem? taskByIdOrNull(String id) =>
      tasks.where((t) => t.id == id).firstOrNull;

  static BadgeItem badgeById(String id) =>
      badges.firstWhere((b) => b.id == id, orElse: () => badges.first);

  static final communities = <Community>[
    Community(
        id: 'c1',
        name: 'Shanti Nagar Society',
        type: 'Society',
        district: 'Ahmedabad',
        pincode: '380015',
        memberCount: 128,
        joinCode: 'SHNT15',
        totalUnitsSaved: 3200),
    Community(
        id: 'c2',
        name: 'Bopal Green Residency',
        type: 'Society',
        district: 'Ahmedabad',
        pincode: '380058',
        memberCount: 86,
        joinCode: 'BOPL58',
        totalUnitsSaved: 2140),
    Community(
        id: 'c3',
        name: 'Sector 21 Ward',
        type: 'Ward',
        district: 'Gandhinagar',
        pincode: '382021',
        memberCount: 212,
        joinCode: 'GNR021',
        totalUnitsSaved: 5100),
    Community(
        id: 'c4',
        name: 'Adajan Sunrise Apartments',
        type: 'Society',
        district: 'Surat',
        pincode: '395009',
        memberCount: 64,
        joinCode: 'ADJN09',
        totalUnitsSaved: 1480),
    Community(
        id: 'c5',
        name: 'Kalali Village',
        type: 'Village',
        district: 'Vadodara',
        pincode: '390012',
        memberCount: 340,
        joinCode: 'KLLI12',
        totalUnitsSaved: 6900),
    Community(
        id: 'c6',
        name: 'Kendriya Vidyalaya Rajkot',
        type: 'School',
        district: 'Rajkot',
        pincode: '360005',
        memberCount: 410,
        joinCode: 'KVRJ05',
        totalUnitsSaved: 3300),
  ];

  static Community communityById(String id) => communities
      .firstWhere((c) => c.id == id, orElse: () => communities.first);

  static final goals = <CommunityGoal>[
    CommunityGoal(
        id: 'g1',
        communityId: 'c1',
        title: 'Save 5,000 units in October',
        metric: 'units',
        target: 5000,
        progress: 3200,
        endDate: DateTime.now().add(const Duration(days: 12)),
        bonusPoints: 150,
        myContribution: 120),
    CommunityGoal(
        id: 'g2',
        communityId: 'c2',
        title: '1,000 tasks this month',
        metric: 'tasks',
        target: 1000,
        progress: 640,
        endDate: DateTime.now().add(const Duration(days: 9))),
    CommunityGoal(
        id: 'g3',
        communityId: 'c3',
        title: 'Cut 4 tonnes CO₂ by Diwali',
        metric: 'co2',
        target: 4000,
        progress: 3450,
        endDate: DateTime.now().add(const Duration(days: 5)),
        bonusPoints: 200),
  ];

  static const leaderboardNames = <(String, String, int)>[
    ('Hetal Shah', 'Ahmedabad', 2890),
    ('Rajesh Mehta', 'Ahmedabad', 2640),
    ('Priya Desai', 'Gandhinagar', 2410),
    ('Amit Trivedi', 'Surat', 2275),
    ('Kinjal Parmar', 'Ahmedabad', 2110),
    ('Mehul Joshi', 'Vadodara', 1980),
    ('Bhavna Rathod', 'Rajkot', 1890),
    ('Dhruv Panchal', 'Ahmedabad', 1760),
    ('Sonal Vyas', 'Bhavnagar', 1640),
    ('Jigar Soni', 'Ahmedabad', 1520),
    ('Nirali Bhatt', 'Surat', 1455),
    ('Kirtan Dave', 'Ahmedabad', 1390),
    ('Pooja Chauhan', 'Kutch', 1310),
    ('Harsh Modi', 'Ahmedabad', 1265),
    ('Riddhi Gandhi', 'Vadodara', 1190),
  ];

  static const vendors = <Vendor>[
    Vendor(
        id: 'v1',
        name: 'SunGujarat Solar Solutions',
        category: 'solar',
        districts: ['Ahmedabad', 'Gandhinagar'],
        phone: '+91 98250 11223',
        rating: 4.7,
        empanelledBy: 'GEDA',
        pricePerKw: 52000),
    Vendor(
        id: 'v2',
        name: 'Suryoday Renewables',
        category: 'solar',
        districts: ['Ahmedabad', 'Mehsana', 'Kheda'],
        phone: '+91 99090 44556',
        rating: 4.5,
        empanelledBy: 'MNRE',
        pricePerKw: 49500),
    Vendor(
        id: 'v3',
        name: 'Tapi Solar Tech',
        category: 'solar',
        districts: ['Surat', 'Navsari', 'Valsad'],
        phone: '+91 98791 77889',
        rating: 4.6,
        empanelledBy: 'GEDA',
        pricePerKw: 51000),
    Vendor(
        id: 'v4',
        name: 'Narmada Green Energy',
        category: 'solar',
        districts: ['Vadodara', 'Bharuch'],
        phone: '+91 97120 33445',
        rating: 4.4,
        empanelledBy: 'DISCOM',
        pricePerKw: 50500),
    Vendor(
        id: 'v5',
        name: 'Saurashtra Solar Hub',
        category: 'solar',
        districts: ['Rajkot', 'Jamnagar', 'Bhavnagar'],
        phone: '+91 94260 99001',
        rating: 4.3,
        empanelledBy: 'GEDA',
        pricePerKw: 48500),
    Vendor(
        id: 'v6',
        name: 'BrightLite LED Store',
        category: 'led',
        districts: ['Ahmedabad'],
        phone: '+91 98980 12121',
        rating: 4.2,
        empanelledBy: 'BEE'),
    Vendor(
        id: 'v7',
        name: 'HeatWave Solar Water Heaters',
        category: 'solar_water_heater',
        districts: ['Ahmedabad', 'Gandhinagar', 'Vadodara'],
        phone: '+91 99250 56565',
        rating: 4.5,
        empanelledBy: 'GEDA'),
    Vendor(
        id: 'v8',
        name: 'ChargeGrid EV Points',
        category: 'ev_charging',
        districts: ['Ahmedabad', 'Surat'],
        phone: '+91 98240 78787',
        rating: 4.1,
        empanelledBy: 'DISCOM'),
    Vendor(
        id: 'v9',
        name: 'EcoRecycle E-Waste Centre',
        category: 'ewaste',
        districts: ['Ahmedabad', 'Gandhinagar'],
        phone: '+91 97270 90909',
        rating: 4.6,
        empanelledBy: 'GPCB'),
  ];

  static const vendorCategories = <(String, String)>[
    ('solar', 'Solar'),
    ('led', 'LED'),
    ('solar_water_heater', 'Solar water heater'),
    ('ev_charging', 'EV charging'),
    ('ewaste', 'E-waste'),
  ];

  static const schemes = <Scheme>[
    Scheme(
      id: 'pm_surya_ghar',
      title: 'PM Surya Ghar Muft Bijli Yojana',
      icon: Icons.wb_sunny_rounded,
      summary:
          'Central subsidy for residential rooftop solar — up to ₹78,000 per household, paid directly to your bank account.',
      eligibility: [
        'Indian household with own roof (or society common roof)',
        'Valid electricity connection in your name',
        'Not availed any other solar subsidy for the same connection'
      ],
      steps: [
        'Register on pmsuryaghar.gov.in with consumer number',
        'Choose an empanelled vendor and get feasibility approval',
        'Install, get net-meter & inspection; subsidy credited in ~30 days'
      ],
      keyNumbers: [
        '₹30,000/kW up to 2 kW',
        '₹18,000 for 3rd kW',
        'Max ₹78,000'
      ],
      officialUrl: 'https://pmsuryaghar.gov.in',
    ),
    Scheme(
      id: 'gujarat_state_subsidy',
      title: 'Gujarat Additional State Subsidy',
      icon: Icons.account_balance_rounded,
      summary:
          'From 22 Oct 2026, Gujarat tops up the central subsidy for systems up to 2.18 kWp so consumers pay only 10% of benchmark cost (5% for SC/ST).',
      eligibility: [
        'Residential consumer in Gujarat',
        'System capacity ≤ 2.18 kWp',
        'Commissioned on/after 22 Oct 2026'
      ],
      steps: [
        'Apply through PM Surya Ghar portal',
        'DISCOM verifies installation',
        'State share credited via DBT'
      ],
      keyNumbers: ['Pay only 10% of cost', 'SC/ST pay 5%', 'Up to 2.18 kWp'],
      officialUrl: 'https://geda.gujarat.gov.in',
    ),
    Scheme(
      id: 'net_metering',
      title: 'Net Metering',
      icon: Icons.electric_meter_rounded,
      summary:
          'Your bidirectional meter credits surplus solar units exported to the grid against the units you consume.',
      eligibility: [
        'Grid-connected rooftop solar',
        'Bidirectional meter installed by DISCOM'
      ],
      steps: [
        'Vendor applies for net-meter with DISCOM',
        'Meter installed & sealed',
        'Monthly bill shows import/export'
      ],
      keyNumbers: [
        'Surplus credited',
        'Settlement yearly',
        'Export ≈ ₹2.25/unit'
      ],
      officialUrl: 'https://www.gseb.com',
    ),
    Scheme(
      id: 'tod_tariff',
      title: 'Time-of-Day Tariff',
      icon: Icons.schedule_rounded,
      summary:
          'Electricity costs more during peak evening hours and less during solar hours — shifting loads saves money.',
      eligibility: [
        'Smart-meter consumers (rolling out)',
        'All consumers above 10 kW load'
      ],
      steps: [
        'Check your tariff category on the bill',
        'Shift washing, pumping and EV charging to 11 am–3 pm',
        'Track savings in Impact'
      ],
      keyNumbers: ['Peak 6–11 pm', 'Solar hours 11–3', 'Up to 20% cheaper'],
      officialUrl: 'https://gercin.org',
    ),
    Scheme(
      id: 'read_your_bill',
      title: 'How to Read Your Bill',
      icon: Icons.receipt_long_rounded,
      summary:
          'Find your consumer number, units consumed, tariff slab and fuel surcharge in 60 seconds.',
      eligibility: [
        'Any DGVCL / MGVCL / PGVCL / UGVCL / Torrent Power consumer'
      ],
      steps: [
        'Locate "Units consumed" (kWh) for the billing period',
        'Note the slab rate and fixed charges',
        'Enter units in Impact → Add month'
      ],
      keyNumbers: ['0–50 units ≈ ₹3.2', '51–200 ≈ ₹3.95', '>200 ≈ ₹5.0+'],
      officialUrl: 'https://www.gseb.com',
    ),
  ];

  static Scheme schemeById(String id) =>
      schemes.firstWhere((s) => s.id == id, orElse: () => schemes.first);

  static const nudges = <Nudge>[
    Nudge(
      id: 'peak_shift',
      title: 'Peak hours start at 6 pm',
      message:
          'Run the washing machine now or after 11 pm to ease the grid and dodge peak tariff.',
      impact: '~₹6 · 0.4 kg CO₂',
      icon: Icons.bolt_rounded,
      color: AppColors.warning,
      softColor: AppColors.warningSoft,
      taskId: 'load_shift_wm',
    ),
    Nudge(
      id: 'heat_ac24',
      title: "It's 39°C tomorrow",
      message:
          'Set AC to 24°C and use the fan together — about 6% saving per degree.',
      impact: '~₹9 · 1.1 kg CO₂',
      icon: Icons.thermostat_rounded,
      color: AppColors.tertiary,
      softColor: AppColors.tertiarySoft,
      taskId: 'ac_24',
    ),
    Nudge(
      id: 'goal_close',
      title: 'Your society is 64% there',
      message:
          'Shanti Nagar needs 1,800 more units this month. Complete a task to push it over the line.',
      impact: 'Bonus +150 pts on completion',
      icon: Icons.groups_rounded,
      color: AppColors.primary,
      softColor: AppColors.primarySoft,
    ),
  ];

  static final leads = <Lead>[
    Lead(
        id: 'l1',
        userName: 'Nisha Patel',
        district: 'Ahmedabad',
        sizeKw: 2,
        netCost: 10000,
        type: 'survey',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        vendorName: 'SunGujarat Solar Solutions'),
    Lead(
        id: 'l2',
        userName: 'Mehul Joshi',
        district: 'Vadodara',
        sizeKw: 3,
        netCost: 67000,
        type: 'quote',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        vendorName: 'Narmada Green Energy',
        status: 'contacted'),
    Lead(
        id: 'l3',
        userName: 'Priya Desai',
        district: 'Gandhinagar',
        sizeKw: 1.5,
        netCost: 7500,
        type: 'survey',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: 'surveyed'),
    Lead(
        id: 'l4',
        userName: 'Amit Trivedi',
        district: 'Surat',
        sizeKw: 2,
        netCost: 10000,
        type: 'survey',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        vendorName: 'Tapi Solar Tech',
        status: 'installed'),
    Lead(
        id: 'l5',
        userName: 'Bhavna Rathod',
        district: 'Rajkot',
        sizeKw: 5,
        netCost: 197000,
        type: 'quote',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        vendorName: 'Saurashtra Solar Hub'),
    Lead(
        id: 'l6',
        userName: 'Sonal Vyas',
        district: 'Bhavnagar',
        sizeKw: 2,
        netCost: 10000,
        type: 'survey',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        status: 'contacted'),
  ];

  static const districtMetrics = <DistrictMetric>[
    DistrictMetric('Ahmedabad', 4820, 186400, 132344, 61200),
    DistrictMetric('Surat', 3610, 142100, 100891, 44800),
    DistrictMetric('Vadodara', 2480, 98600, 70006, 30100),
    DistrictMetric('Rajkot', 2150, 84200, 59782, 26900),
    DistrictMetric('Gandhinagar', 1890, 77800, 55238, 24400),
    DistrictMetric('Bhavnagar', 1120, 41200, 29252, 13900),
    DistrictMetric('Jamnagar', 980, 36500, 25915, 12100),
    DistrictMetric('Kutch', 860, 33800, 23998, 10400),
    DistrictMetric('Mehsana', 740, 27900, 19809, 9100),
    DistrictMetric('Anand', 690, 25100, 17821, 8300),
  ];

  static const monthlyTrend = <(String, double, double)>[
    ('May', 42000, 29820),
    ('Jun', 58000, 41180),
    ('Jul', 71000, 50410),
    ('Aug', 96000, 68160),
    ('Sep', 131000, 93010),
    ('Oct', 168000, 119280),
  ];
}
