import 'package:flutter/material.dart';
import '../../../../models/cartoon_model.dart';

class InfoGrid extends StatelessWidget {
  final CartoonModel cartoon;
  const InfoGrid({super.key, required this.cartoon});

  @override
  Widget build(BuildContext context) {
    final items = <Map<String, String>>[
      {'العنوان': cartoon.title},
      {'السنة': '${cartoon.releaseYear ?? '-'}'},
      {'التصنيف': cartoon.rating?.toString() ?? '-'},
      {'الحالة': cartoon.status ?? ''},
      {'اللغة': '${cartoon.languageId}'},
      if ((cartoon.audience ?? '').isNotEmpty)
        {'الفئة العمرية': cartoon.audience!},
    ];

    final cross = MediaQuery.of(context).size.width >= 900
        ? 3
        : (MediaQuery.of(context).size.width >= 600 ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3.6,
      ),
      itemBuilder: (_, i) {
        final key = items[i].keys.first;
        final val = items[i][key]!;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Text('$key: ',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              Expanded(
                child: Text(
                  val,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 13, height: 1.1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
