import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';
import 'sporto_doc_card.dart';
import 'sporto_shimmer.dart';

/// Skeleton mirroring the referee/venue list card (`SportoBookingTile`).
/// Same surface (glass `DocCard`, 10 padding) and internal rhythm so there is
/// no layout jump when data arrives.
class RefereeTileSkeleton extends StatelessWidget {
  final bool withFooter;

  const RefereeTileSkeleton({super.key, this.withFooter = true});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    return SportoDocCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonCircle(size: 50),
              SizedBox(width: context.sportoLayout.space10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLine(width: 150, height: 16),
                    SizedBox(height: context.sportoLayout.space6),
                    const SkeletonLine(width: 200, height: 12),
                    SizedBox(height: context.sportoLayout.space4),
                    const SkeletonLine(width: 120, height: 12),
                  ],
                ),
              ),
              SizedBox(width: context.sportoLayout.space10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SkeletonLine(width: 44, height: 16),
                  SizedBox(height: context.sportoLayout.space6),
                  const SkeletonLine(width: 52, height: 12),
                ],
              ),
            ],
          ),
          if (withFooter) ...[
            SizedBox(height: context.sportoLayout.space10),
            Container(height: 1, color: tokens.border.withValues(alpha: 0.5)),
            SizedBox(height: context.sportoLayout.space10),
            const Row(
              children: [
                SkeletonLine(width: 130, height: 11),
                Spacer(),
                SkeletonLine(width: 55, height: 11),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Skeleton mirroring a compact booking list row (`DocCard` 350x70).
class BookingListItemSkeleton extends StatelessWidget {
  const BookingListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final gap = context.sportoLayout;
    return SportoDocCard(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonCircle(size: 50),
          SizedBox(width: gap.space10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLine(width: 170, height: 16),
                SizedBox(height: gap.space6),
                const SkeletonLine(width: 210, height: 12),
                SizedBox(height: gap.space4),
                const SkeletonLine(width: 120, height: 12),
              ],
            ),
          ),
          SizedBox(width: gap.space10),
          const SkeletonLine(width: 44, height: 16),
        ],
      ),
    );
  }
}

/// Skeleton mirroring a full-width payment method tile (`DocCard` 350x50).
class PaymentTileSkeleton extends StatelessWidget {
  const PaymentTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SportoDocCard(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          SkeletonBox(width: 24, height: 24, radius: 6),
          SizedBox(width: 10),
          Expanded(child: SkeletonLine(width: 160, height: 16)),
        ],
      ),
    );
  }
}

/// Skeleton mirroring a `Section`: title + several label/value rows + total.
class BookingDetailSectionSkeleton extends StatelessWidget {
  final int rows;

  const BookingDetailSectionSkeleton({super.key, this.rows = 3});

  @override
  Widget build(BuildContext context) {
    final gap = context.sportoLayout;
    final tokens = context.sporto;
    return SportoDocCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < rows; i++) ...[
            const Row(
              children: [
                Expanded(child: SkeletonLine(width: 100, height: 14)),
                SkeletonLine(width: 80, height: 14),
              ],
            ),
            SizedBox(height: gap.space10),
          ],
          Container(height: 1, color: tokens.border.withValues(alpha: 0.5)),
          SizedBox(height: gap.space10),
          const Row(
            children: [
              Expanded(child: SkeletonLine(width: 90, height: 16)),
              SkeletonLine(width: 70, height: 18),
            ],
          ),
        ],
      ),
    );
  }
}

/// Repeats a skeleton builder with a fixed gap (no layout jump for lists).
class SportoSkeletonList extends StatelessWidget {
  final int itemCount;
  final WidgetBuilder itemBuilder;
  final double gap;

  const SportoSkeletonList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.gap = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < itemCount; i++) ...[
          itemBuilder(context),
          if (i != itemCount - 1) SizedBox(height: gap),
        ],
      ],
    );
  }
}

