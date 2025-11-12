enum SubscriptionPlanType { basic, premium, platinum }

enum SubscriptionPeriod { monthly, yearly }

class SubscriptionPlan {
  final int id;
  final String name;
  final String description;
  final double price; // قد تأتي من الـ API كـ String
  final int duration; // أيام

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
  });

  String get title => name;

  SubscriptionPeriod get period =>
      duration >= 365 ? SubscriptionPeriod.yearly : SubscriptionPeriod.monthly;

  SubscriptionPlanType get type =>
      price >= 50 ? SubscriptionPlanType.premium : SubscriptionPlanType.basic;

  String get currency => 'AED';

  List<String> get features => [
    'Access to all content',
    'HD quality streaming',
    'No ads',
    'Download for offline',
  ];

  factory SubscriptionPlan.fromMap(Map<String, dynamic> map) {
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return SubscriptionPlan(
      id: toInt(map['id']),
      name: (map['name'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      price: toDouble(map['price']),
      duration: toInt(map['duration']),
    );
  }
}
