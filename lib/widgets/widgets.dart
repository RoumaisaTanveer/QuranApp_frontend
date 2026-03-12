import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../models/models.dart';

// ── Card container ────────────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final double radius;
  final bool glowPurple;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.radius = 14,
    this.glowPurple = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? AppColors.bg2,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppColors.border),
          boxShadow: glowPurple
              ? [
                  BoxShadow(
                    color: AppColors.purpleGlow,
                    blurRadius: 24,
                    spreadRadius: -4,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: child,
      );
}

// ── Section label ─────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  final Color? color;
  const SectionLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppText.label(
          size: 11,
          color: color ?? AppColors.textSub,
          weight: FontWeight.w600,
        ),
      );
}

// ── Emotion pill ──────────────────────────────────────────────────────
class EmotionPill extends StatelessWidget {
  final String emotion;
  final bool small;
  const EmotionPill(this.emotion, {super.key, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = Color(EmotionMeta.getColor(emotion));
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 10 : 12,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        emotion,
        style: AppText.label(
          size: small ? 10 : 11,
          color: color,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Ayah card ─────────────────────────────────────────────────────────
class AyahCard extends StatefulWidget {
  final AyahMatch ayah;
  final int index;
  final int total;
  final bool isBookmarked;
  final VoidCallback onBookmark;

  const AyahCard({
    super.key,
    required this.ayah,
    required this.index,
    required this.total,
    required this.isBookmarked,
    required this.onBookmark,
  });

  @override
  State<AyahCard> createState() => _AyahCardState();
}

class _AyahCardState extends State<AyahCard> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(
      ClipboardData(
        text:
            '${widget.ayah.ayahAr}\n\n${widget.ayah.ayah}\n— ${widget.ayah.surah} · ${widget.ayah.ayahNo}',
      ),
    );
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top row — verse number + actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  // Gold icon box
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.goldDim,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      size: 15,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.ayah.surah,
                        style: AppText.sans(
                          size: 13,
                          weight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Verse ${widget.ayah.ayahNo}  ·  ${widget.ayah.index} of ${widget.total}',
                        style: AppText.label(
                          size: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ]),
                Row(children: [
                  _SmallBtn(
                    icon: _copied ? Icons.check_rounded : Icons.copy_rounded,
                    color:
                        _copied ? AppColors.green : AppColors.textMuted,
                    onTap: _copy,
                  ),
                  const SizedBox(width: 6),
                  _SmallBtn(
                    icon: widget.isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: widget.isBookmarked
                        ? AppColors.gold
                        : AppColors.textMuted,
                    onTap: widget.onBookmark,
                  ),
                ]),
              ],
            ),
          ),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            height: 1,
            color: AppColors.border,
          ),

          // Arabic
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.ayah.ayahAr,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppText.arabic(size: 21),
            ),
          ),

          const SizedBox(height: 12),

          // English
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.ayah.ayah,
              style: AppText.sans(
                size: 14,
                color: AppColors.textSub,
                height: 1.6,
              ).copyWith(fontStyle: FontStyle.italic),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

extension on AyahMatch {
  int get index => 0; // placeholder, passed from outside
}

class _SmallBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SmallBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.bg3,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
      );
}

// ── Comfort card ──────────────────────────────────────────────────────
class ComfortCard extends StatelessWidget {
  final String message;
  const ComfortCard(this.message, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.goldDim,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withOpacity(0.25)),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.goldDim,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Gentle Reminder',
                style: AppText.sans(
                  size: 13,
                  color: AppColors.gold,
                  weight: FontWeight.w600,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppText.sans(
                size: 14,
                color: AppColors.text,
                height: 1.7,
              ),
            ),
          ],
        ),
      );
}

// ── Primary button — purple gradient ──────────────────────────────────
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool secondary;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.secondary = false,
    this.icon,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.secondary ? 18 : 28,
              vertical: widget.secondary ? 10 : 14,
            ),
            decoration: BoxDecoration(
              gradient: widget.secondary
                  ? null
                  : const LinearGradient(
                      colors: [
                        AppColors.purple,
                        AppColors.purpleLight,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: widget.secondary ? AppColors.bg3 : null,
              borderRadius: BorderRadius.circular(12),
              border: widget.secondary
                  ? Border.all(color: AppColors.borderLight)
                  : null,
              boxShadow: widget.secondary
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.purple.withOpacity(
                          _pressed ? 0.15 : 0.3,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: widget.isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.secondary
                          ? AppColors.purple
                          : Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: 15,
                          color: widget.secondary
                              ? AppColors.purple
                              : Colors.white,
                        ),
                        const SizedBox(width: 7),
                      ],
                      Text(
                        widget.label,
                        style: AppText.sans(
                          size: 13,
                          color: widget.secondary
                              ? AppColors.text
                              : Colors.white,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
}

// ── Loading dots ──────────────────────────────────────────────────────
class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final o = (((_ctrl.value * 3) - i) % 1 + 1) % 1;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.purple.withOpacity(0.2 + 0.8 * o),
              ),
            );
          }),
        ),
      );
}

// ── Empty state ───────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String arabic;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onButton;

  const EmptyState({
    super.key,
    required this.arabic,
    required this.message,
    this.buttonLabel,
    this.onButton,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                arabic,
                style: AppText.arabic(
                  size: 42,
                  color: AppColors.gold.withOpacity(0.2),
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppText.sans(
                  size: 14,
                  color: AppColors.textSub,
                  height: 1.7,
                ).copyWith(fontStyle: FontStyle.italic),
              ),
              if (buttonLabel != null && onButton != null) ...[
                const SizedBox(height: 24),
                PrimaryButton(
                  label: buttonLabel!,
                  onPressed: onButton,
                  secondary: true,
                ),
              ],
            ],
          ),
        ),
      );
}
