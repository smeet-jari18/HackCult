import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

enum UserRole { citizen, captain, admin }

enum AuthProvider { password, google }

enum LifeTheme {
  saveEnergy,
  saveWater,
  noPlastic,
  sustainableFood,
  reduceWaste,
  healthyLifestyle,
  reduceEwaste;

  String get label => switch (this) {
        LifeTheme.saveEnergy => 'Save Energy',
        LifeTheme.saveWater => 'Save Water',
        LifeTheme.noPlastic => 'No Single-Use Plastic',
        LifeTheme.sustainableFood => 'Sustainable Food',
        LifeTheme.reduceWaste => 'Reduce Waste',
        LifeTheme.healthyLifestyle => 'Healthy Lifestyle',
        LifeTheme.reduceEwaste => 'Reduce E-Waste',
      };

  Color get color => switch (this) {
        LifeTheme.saveEnergy => AppColors.themeEnergy,
        LifeTheme.saveWater => AppColors.themeWater,
        LifeTheme.noPlastic => AppColors.themePlastic,
        LifeTheme.sustainableFood => AppColors.themeFood,
        LifeTheme.reduceWaste => AppColors.themeWaste,
        LifeTheme.healthyLifestyle => AppColors.themeHealthy,
        LifeTheme.reduceEwaste => AppColors.themeEwaste,
      };

  IconData get icon => switch (this) {
        LifeTheme.saveEnergy => Icons.bolt_rounded,
        LifeTheme.saveWater => Icons.water_drop_rounded,
        LifeTheme.noPlastic => Icons.shopping_bag_rounded,
        LifeTheme.sustainableFood => Icons.restaurant_rounded,
        LifeTheme.reduceWaste => Icons.recycling_rounded,
        LifeTheme.healthyLifestyle => Icons.directions_walk_rounded,
        LifeTheme.reduceEwaste => Icons.phonelink_erase_rounded,
      };
}

enum Difficulty { easy, medium, hard }

enum Verification {
  self,
  photo,
  bill,
  vendor;

  IconData get icon => switch (this) {
        Verification.self => Icons.check_circle_outline_rounded,
        Verification.photo => Icons.photo_camera_outlined,
        Verification.bill => Icons.receipt_long_outlined,
        Verification.vendor => Icons.verified_outlined,
      };

  String get label => switch (this) {
        Verification.self => 'Self-report',
        Verification.photo => 'Photo required',
        Verification.bill => 'Bill verified',
        Verification.vendor => 'Vendor confirmed',
      };
}

enum TaskStatus { pending, done, skipped, notApplicable }

class AppUser {
  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.authProvider,
    this.photoUrl,
    this.language = 'en',
    this.district = 'Ahmedabad',
    this.pincode = '380015',
    this.householdSize = 4,
    this.homeType = 'flat',
    this.roofAccess = 'yes',
    this.appliances = const ['ac', 'fridge', 'washing_machine', 'geyser'],
    this.travelMode = 'two_wheeler',
    this.weeklyKm = 70,
    this.baselineUnits = 250,
    this.baselineCo2Kg = 226.9,
    this.goalPercent = 15,
    this.onboardingComplete = false,
    this.communityId,
    this.points = 0,
    this.weeklyPoints = 0,
    this.streak = 0,
    this.longestStreak = 0,
    this.freezeTokens = 1,
    this.badges = const [],
    this.peakNudge = true,
    this.weatherNudge = true,
    this.communityUpdates = true,
    this.streakReminders = true,
  });

  final String uid;
  String email;
  String displayName;
  UserRole role;
  AuthProvider authProvider;
  String? photoUrl;
  String language;
  String district;
  String pincode;
  int householdSize;
  String homeType;
  String roofAccess;
  List<String> appliances;
  String travelMode;
  double weeklyKm;
  double baselineUnits;
  double baselineCo2Kg;
  int goalPercent;
  bool onboardingComplete;
  String? communityId;
  int points;
  int weeklyPoints;
  int streak;
  int longestStreak;
  int freezeTokens;
  List<String> badges;
  bool peakNudge;
  bool weatherNudge;
  bool communityUpdates;
  bool streakReminders;

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  bool get isAdmin => role == UserRole.admin;
}

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.theme,
    required this.difficulty,
    required this.points,
    required this.verification,
    this.steps = const [],
    this.estUnitsSaved = 0,
    this.estCo2Kg = 0,
    this.estRupees = 0,
    this.applianceTags = const [],
    this.seasonTags = const ['all'],
  });

  final String id;
  final String title;
  final String description;
  final LifeTheme theme;
  final Difficulty difficulty;
  final int points;
  final Verification verification;
  final List<String> steps;
  final double estUnitsSaved;
  final double estCo2Kg;
  final double estRupees;
  final List<String> applianceTags;
  final List<String> seasonTags;
}

class TaskLog {
  TaskLog({
    required this.taskId,
    required this.date,
    required this.status,
    this.pointsAwarded = 0,
    this.hasProof = false,
  });

  final String taskId;
  final DateTime date;
  final TaskStatus status;
  final int pointsAwarded;
  final bool hasProof;
}

class FootprintEntry {
  FootprintEntry({
    required this.month,
    required this.electricityUnits,
    required this.electricityKg,
    required this.cookingKg,
    required this.transportKg,
    required this.source,
    this.isBaseline = false,
    this.unitsSaved = 0,
    this.rupeesSaved = 0,
    this.percentChange = 0,
    this.pointsAwarded = 0,
  });

  final DateTime month;
  final double electricityUnits;
  final double electricityKg;
  final double cookingKg;
  final double transportKg;
  final String source; // manual | bill | quiz
  final bool isBaseline;
  final double unitsSaved;
  final double rupeesSaved;
  final double percentChange;
  final int pointsAwarded;

  double get co2Kg => electricityKg + cookingKg + transportKg;
}

class PointsEntry {
  PointsEntry(
      {required this.delta,
      required this.reason,
      required this.createdAt,
      this.icon});
  final int delta;
  final String reason;
  final DateTime createdAt;
  final IconData? icon;
}

class BadgeItem {
  const BadgeItem(
      {required this.id,
      required this.name,
      required this.description,
      required this.icon,
      required this.color});
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
}

class LevelInfo {
  const LevelInfo(this.id, this.name, this.minPoints, this.emoji);
  final String id;
  final String name;
  final int minPoints;
  final String emoji;
}

class Community {
  Community({
    required this.id,
    required this.name,
    required this.type,
    required this.district,
    required this.pincode,
    required this.memberCount,
    required this.joinCode,
    this.totalUnitsSaved = 0,
  });
  final String id;
  final String name;
  final String type;
  final String district;
  final String pincode;
  int memberCount;
  final String joinCode;
  double totalUnitsSaved;
}

class CommunityGoal {
  CommunityGoal({
    required this.id,
    required this.communityId,
    required this.title,
    required this.metric,
    required this.target,
    required this.progress,
    required this.endDate,
    this.bonusPoints = 100,
    this.myContribution = 0,
  });
  final String id;
  final String communityId;
  final String title;
  final String metric;
  final double target;
  double progress;
  final DateTime endDate;
  final int bonusPoints;
  double myContribution;

  double get ratio => (progress / target).clamp(0, 1);
  int get daysLeft => endDate.difference(DateTime.now()).inDays.clamp(0, 999);
}

class LeaderboardEntry {
  const LeaderboardEntry(
      {required this.rank,
      required this.name,
      required this.district,
      required this.points,
      this.isMe = false});
  final int rank;
  final String name;
  final String district;
  final int points;
  final bool isMe;
}

class Vendor {
  const Vendor({
    required this.id,
    required this.name,
    required this.category,
    required this.districts,
    required this.phone,
    required this.rating,
    required this.empanelledBy,
    this.pricePerKw,
  });
  final String id;
  final String name;
  final String category;
  final List<String> districts;
  final String phone;
  final double rating;
  final String empanelledBy;
  final double? pricePerKw;
}

class Scheme {
  const Scheme({
    required this.id,
    required this.title,
    required this.summary,
    required this.eligibility,
    required this.steps,
    required this.keyNumbers,
    required this.officialUrl,
    required this.icon,
  });
  final String id;
  final String title;
  final String summary;
  final List<String> eligibility;
  final List<String> steps;
  final List<String> keyNumbers;
  final String officialUrl;
  final IconData icon;
}

class SolarAssessment {
  SolarAssessment({
    required this.id,
    required this.monthlyUnits,
    required this.roofAreaM2,
    required this.category,
    required this.sizeKw,
    required this.annualGenUnits,
    required this.grossCost,
    required this.centralSubsidy,
    required this.stateSubsidy,
    required this.netCost,
    required this.annualSavings,
    required this.paybackYears,
    required this.co2Avoided25yKg,
    required this.createdAt,
  });
  final String id;
  final double monthlyUnits;
  final double roofAreaM2;
  final String category;
  final double sizeKw;
  final double annualGenUnits;
  final double grossCost;
  final double centralSubsidy;
  final double stateSubsidy;
  final double netCost;
  final double annualSavings;
  final double? paybackYears;
  final double co2Avoided25yKg;
  final DateTime createdAt;
}

class Lead {
  Lead({
    required this.id,
    required this.userName,
    required this.district,
    required this.sizeKw,
    required this.netCost,
    required this.type,
    required this.createdAt,
    this.vendorName,
    this.status = 'new',
    this.phone,
    this.preferredSlot,
    this.ownerUid,
  });
  final String id;
  final String userName;
  final String district;
  final double sizeKw;
  final double netCost;
  final String type;
  final DateTime createdAt;
  final String? vendorName;
  String status;
  final String? phone;
  final String? preferredSlot;
  final String? ownerUid;
}

class Nudge {
  const Nudge({
    required this.id,
    required this.title,
    required this.message,
    required this.impact,
    required this.icon,
    required this.color,
    required this.softColor,
    this.taskId,
  });
  final String id;
  final String title;
  final String message;
  final String impact;
  final IconData icon;
  final Color color;
  final Color softColor;
  final String? taskId;
}

class DistrictMetric {
  const DistrictMetric(
      this.district, this.users, this.unitsSaved, this.co2Kg, this.tasks);
  final String district;
  final int users;
  final double unitsSaved;
  final double co2Kg;
  final int tasks;
}


/// Household cooking-fuel connection (LPG cylinder or piped PNG meter).
class GasConnection {
  GasConnection({
    required this.type, // 'lpg' | 'png'
    required this.provider,
    required this.consumerNumber,
    this.agency = '',
    this.cylindersPerMonth = 1,
    this.scmPerMonth = 15,
    this.pmuy = false,
    this.proofAttached = false,
  });
  final String type;
  final String provider;
  final String consumerNumber;
  final String agency;
  final int cylindersPerMonth;
  final int scmPerMonth;
  final bool pmuy;
  final bool proofAttached;

  bool get isPng => type == 'png';
  String get providerShort => provider.split(' ').first;
}
