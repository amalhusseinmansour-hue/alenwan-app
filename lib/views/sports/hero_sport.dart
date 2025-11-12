import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'package:alenwan/controllers/downloads_controller.dart';
import 'package:alenwan/models/download_model.dart';
import 'package:alenwan/core/services/download_manager.dart';

class HeroSport extends StatelessWidget {
  final String title;
  final String? banner;
  final String posterUrl;
  final String subtitle;
  final String videoUrl;
  final VoidCallback onWatchNow;
  final VoidCallback? onMoreInfo;
  final VideoPlayerController? controller;

  const HeroSport({
    super.key,
    required this.title,
    this.banner,
    required this.posterUrl,
    required this.subtitle,
    required this.videoUrl,
    required this.onWatchNow,
    this.onMoreInfo,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (controller != null && controller!.value.isInitialized)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller!.value.size.width,
              height: controller!.value.size.height,
              child: VideoPlayer(controller!),
            ),
          )
        else if ((banner ?? '').isNotEmpty)
          Image.network(banner!, fit: BoxFit.cover)
        else
          Container(color: Colors.black),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),

        Positioned(
          bottom: 60,
          left: 20,
          right: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (posterUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    posterUrl,
                    width: screenWidth < 600 ? 90 : 120,
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: onWatchNow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE50914),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 18,
                            ),
                          ),
                          icon: const Icon(Icons.play_arrow, color: Colors.white),
                          label: const Text("شاهد الآن",
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final ctrl = context.read<DownloadsController>();

                            try {
                              final savePath =
                                  await DownloadManager().downloadVideo(
                                url: videoUrl,
                                fileName: "${title.replaceAll(' ', '_')}.mp4",
                              );

                              final file = File(savePath);
                              final fileSize = await file.length();

                              final d = DownloadModel(
                                id: DateTime.now().millisecondsSinceEpoch,
                                title: title,
                                path: savePath,
                                fileSize: fileSize,
                              );

                              await ctrl.addDownload(d);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("✅ تمت الإضافة إلى التنزيلات"),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("❌ فشل التنزيل: $e"),
                                  ),
                                );
                              }
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white70),
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.download),
                          label: const Text("قائمتي"),
                        ),
                        if (onMoreInfo != null) ...[
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: onMoreInfo,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white70),
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.info_outline),
                            label: const Text("مزيد من المعلومات"),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
