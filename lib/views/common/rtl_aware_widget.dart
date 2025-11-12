import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui show TextDirection; // 💡 تحديد مصدر TextDirection بدقة

class RTLAwareWidget extends StatelessWidget {
  final Widget child;
  final bool enforceRTL;
  final bool enforceLTR;

  const RTLAwareWidget({
    super.key,
    required this.child,
    this.enforceRTL = false,
    this.enforceLTR = false,
  }) : assert(!(enforceRTL && enforceLTR),
            'Cannot enforce both RTL and LTR at the same time');

  @override
  Widget build(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';

    final ui.TextDirection direction;
    if (enforceRTL) {
      direction = ui.TextDirection.ltr;
    } else if (enforceLTR) {
      direction = ui.TextDirection.ltr;
    } else {
      direction = isRTL ? ui.TextDirection.ltr : ui.TextDirection.ltr;
    }

    return Directionality(
      textDirection: direction,
      child: child,
    );
  }
}

extension RTLAwareExtension on Widget {
  Widget withRTLAwareness(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';
    final direction = isRTL ? ui.TextDirection.ltr : ui.TextDirection.ltr;

    return Directionality(
      textDirection: direction,
      child: this,
    );
  }

  Widget enforceRTL() {
    return RTLAwareWidget(enforceRTL: true, child: this);
  }

  Widget enforceLTR() {
    return RTLAwareWidget(enforceLTR: true, child: this);
  }
}
