import 'package:alenwan/core/services/sport_service.dart';
import 'package:alenwan/models/sport_clip_model.dart';
import 'package:flutter/material.dart';

class SportClipsTab extends StatelessWidget {
  final List<SportClipModel> clips;
  final Function(String url, String title) onPlayClip;

  const SportClipsTab({
    super.key,
    required this.clips,
    required this.onPlayClip,
    required String title,
    required String banner,
    required String videoUrl,
    required Null Function() onPlay,
  });

  String _full(String? path) {
    final origin = Uri.parse(SportService().baseUrl).origin;
    if (path == null || path.isEmpty) {
      return 'https://via.placeholder.com/300x450';
    }
    var p = path.trim();
    if (p.startsWith('//')) p = 'https:$p';
    if (p.startsWith('http')) {
      return p.replaceFirst(
        RegExp(r'^https?:\/\/(127\.0\.0\.1|localhost)(:\d+)?'),
        origin,
      );
    }
    if (!p.startsWith('/')) p = '/$p';
    final normalized = p.startsWith('/storage/') ? p : '/storage$p';
    return '$origin$normalized';
  }

  @override
  Widget build(BuildContext context) {
    if (clips.isEmpty) {
      return const Center(
        child: Text("لا توجد حلقات متاحة حالياً",
            style: TextStyle(color: Colors.white70)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 16 / 9,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: clips.length,
      itemBuilder: (context, i) {
        final clip = clips[i];
        final thumb = _full(clip.posterPath); // من thumbnail_url
// من video_url

        return GestureDetector(
          onTap: () => onPlayClip(clip.videoPath, clip.title),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  thumb.isNotEmpty
                      ? thumb
                      : 'https://via.placeholder.com/640x360?text=No+Image',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
              ),
              const Positioned.fill(
                child: Center(
                    child: Icon(Icons.play_circle_fill,
                        size: 56, color: Colors.white)),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(
                  clip.title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
