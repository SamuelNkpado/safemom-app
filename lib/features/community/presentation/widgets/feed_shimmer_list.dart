import 'package:flutter/material.dart';
import 'package:safemom/core/constants/app_spacing.dart';

class FeedShimmerList extends StatefulWidget {
  const FeedShimmerList({super.key});

  @override
  State<FeedShimmerList> createState() => _FeedShimmerListState();
}

class _FeedShimmerListState extends State<FeedShimmerList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = 0.4 + (_controller.value * 0.35);
        return Column(
          children: List.generate(3, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
