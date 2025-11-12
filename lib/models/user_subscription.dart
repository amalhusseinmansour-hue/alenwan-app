import 'subscription_plan.dart';

class UserSubscription {
  final int id;
  final SubscriptionPlan plan;
  final DateTime startsAt;
  final DateTime endsAt;
  final String status; // active | cancelled | expired

  UserSubscription({
    required this.id,
    required this.plan,
    required this.startsAt,
    required this.endsAt,
    required this.status,
  });

  bool get isActive => status == 'active' && DateTime.now().isBefore(endsAt);

  factory UserSubscription.fromMap(Map<String, dynamic> m) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    DateTime toDate(dynamic v) {
      if (v is DateTime) return v;
      if (v is String) {
        try {
          return DateTime.parse(v);
        } catch (_) {}
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    // بعض الـ APIs ترجع الخطة بداخل مفتاح 'subscription' أو 'plan'
    final planMap = (m['subscription'] ?? m['plan']) as Map? ?? {};
    return UserSubscription(
      id: toInt(m['id']),
      plan: SubscriptionPlan.fromMap(Map<String, dynamic>.from(planMap)),
      startsAt: toDate(m['starts_at'] ?? m['startDate'] ?? m['startsAt']),
      endsAt: toDate(m['ends_at'] ?? m['endDate'] ?? m['endsAt']),
      status: (m['status'] ?? '').toString(),
    );
  }
}
