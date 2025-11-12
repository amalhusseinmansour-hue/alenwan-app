// lib/views/home/widgets/hover_media_card.dart
import 'dart:async';
import 'package:flutter/material.dart';

class HoverMediaCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String? badge;

  final bool isFavorite;
  final VoidCallback? onFav; // سيُستدعى من الأب
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final VoidCallback? onAdd;

  final double width;
  final double height;
  final BorderRadius borderRadius;

  const HoverMediaCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.badge,
    this.isFavorite = false,
    this.onFav,
    this.onTap,
    this.onPlay,
    this.onAdd,
    this.width = 160,
    this.height = 180,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<HoverMediaCard> createState() => _HoverMediaCardState();
}

class _HoverMediaCardState extends State<HoverMediaCard> {
  // overlay only — لا نكبر الكرت ولا نغير ارتفاعه
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;
  bool _overCard = false, _overOverlay = false;
  Timer? _hideTimer;
  static const _hideDelay = Duration(milliseconds: 280);

  static const double _panelW = 210;
  static const double _panelH = 98;

  late bool _fav;

  @override
  void initState() {
    super.initState();
    _fav = widget.isFavorite;
  }

  @override
  void didUpdateWidget(covariant HoverMediaCard old) {
    super.didUpdateWidget(old);
    if (old.isFavorite != widget.isFavorite) {
      _fav = widget.isFavorite;
      _entry?.markNeedsBuild();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _entry?.remove();
    super.dispose();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_hideDelay, () {
      if (!_overCard && !_overOverlay) {
        _entry?.remove();
        _entry = null;
      }
    });
  }

  Offset _calcOffset() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return Offset(0, widget.height - 1);

    final target = box.localToGlobal(Offset.zero);
    final screenW = MediaQuery.of(context).size.width;

    double dx = -8;
    double left = target.dx + dx;
    double right = left + _panelW;

    if (right > screenW - 8) dx = widget.width - _panelW;
    if (target.dx + dx < 8) dx = 8 - target.dx;

    return Offset(dx, widget.height - 1);
  }

  void _showOverlay() {
    if (_entry != null) return;

    _entry = OverlayEntry(
      builder: (_) => CompositedTransformFollower(
        link: _link,
        showWhenUnlinked: false,
        offset: _calcOffset(),
        child: MouseRegion(
          onEnter: (_) {
            _overOverlay = true;
            _hideTimer?.cancel();
          },
          onExit: (_) {
            _overOverlay = false;
            _scheduleHide();
          },
          child: Material(
            type: MaterialType.transparency,
            child: ConstrainedBox(
              constraints: const BoxConstraints.tightFor(
                  width: _panelW, height: _panelH),
              child: _ActionPanel(
                title: widget.title,
                fav: _fav,
                onPlay: widget.onPlay ?? widget.onTap,
                onToggleFav: () {
                  setState(() => _fav = !_fav); // UI لحظي فقط
                  _entry?.markNeedsBuild();
                  widget.onFav?.call(); // الحفظ الفعلي عند الأب (post-frame)
                },
                onAdd: widget.onAdd,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_entry!);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _overCard = true;
        _hideTimer?.cancel();
        _showOverlay();
      },
      onExit: (_) {
        _overCard = false;
        _scheduleHide();
      },
      child: CompositedTransformTarget(
        link: _link,
        child: SizedBox(
          width: widget.width,
          height: widget.height, // ثابت دائماً
          child: Material(
            color: Colors.transparent,
            borderRadius: widget.borderRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              child: Stack(
                children: [
                  Image.network(
                    widget.imageUrl,
                    width: widget.width,
                    height: widget.height,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade800,
                      alignment: Alignment.center,
                      child:
                          const Icon(Icons.broken_image, color: Colors.white54),
                    ),
                  ),
                  if (widget.badge != null && widget.badge!.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.badge == 'مباشر'
                              ? Colors.red
                              : Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(widget.badge!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.32),
                            Colors.transparent
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  final String title;
  final bool fav;
  final VoidCallback? onPlay;
  final VoidCallback? onToggleFav;
  final VoidCallback? onAdd;
  const _ActionPanel(
      {required this.title,
      required this.fav,
      this.onPlay,
      this.onToggleFav,
      this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                onTap: onPlay,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE50914),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.play_arrow_rounded,
                        size: 18, color: Colors.white),
                    SizedBox(width: 4),
                    Text('تشغيل',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ]),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onToggleFav,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Icon(fav ? Icons.favorite : Icons.favorite_border,
                      color: fav ? Colors.red : Colors.white, size: 18),
                ),
              ),
              if (onAdd != null) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Icon(Icons.download_for_offline,
                        size: 18, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
