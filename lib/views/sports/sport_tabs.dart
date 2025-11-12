import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SportTabs extends StatelessWidget {
  const SportTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      indicatorColor: Colors.red,
      tabs: [
        Tab(text: "episodes_tab".tr()),
        Tab(text: "similar_tab".tr()),
        Tab(text: "more_info_tab".tr()),
      ],
    );
  }
}
