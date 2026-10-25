import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../domain/models/tracking_stage.dart';
import '../../l10n/generated/app_localizations.dart';

/// Visual delivery timeline for [TrackingStage].
///
/// Shows all six stages of the journey and distinguishes three states:
///   * completed — filled primary node,
///   * current   — ringed node with the stage icon,
///   * upcoming  — muted node.
///
/// The layout is responsive: a horizontal rail on wide viewports
/// (>= [horizontalBreakpoint]) and a vertical rail on narrow ones, so it fits
/// the admin order dialog, the public tracking page and small phones alike.
///
/// The widget is deliberately dumb: it renders [currentStage] and the
/// [timestamps] it is given and never derives progress by itself, so it can
/// never claim an order moved further than the database says.
class OrderTrackingTimeline extends StatelessWidget {
  const OrderTrackingTimeline({
    super.key,
    required this.currentStage,
    this.timestamps = const {},
    this.cancelled = false,
  });

  /// Available width above which the timeline switches to the horizontal rail.
  static const double horizontalBreakpoint = 720;

  final TrackingStage currentStage;

  /// Known timestamps per stage; stages absent here stay dateless.
  final Map<TrackingStage, DateTime> timestamps;

  /// True when the order was cancelled — the current node is rendered muted
  /// and an explanatory line is added instead of implying the shipment moves.
  final bool cancelled;

  static Key stageKey(TrackingStage stage) => ValueKey('stage-${stage.name}');

  /// The delivery icon for each stage.
  static IconData iconFor(TrackingStage stage) => switch (stage) {
        TrackingStage.orderReceived => Icons.receipt_long_outlined,
        TrackingStage.processing => Icons.inventory_2_outlined,
        TrackingStage.shipped => Icons.local_shipping_outlined,
        TrackingStage.inTransit => Icons.flight_outlined,
        TrackingStage.outForDelivery => Icons.delivery_dining_outlined,
        TrackingStage.delivered => Icons.check_circle_outline,
      };

  String _label(AppLocalizations l10n, TrackingStage stage) =>
      switch (stage) {
        TrackingStage.orderReceived => l10n.trackingStageOrderReceived,
        TrackingStage.processing => l10n.trackingStageProcessing,
        TrackingStage.shipped => l10n.trackingStageShipped,
        TrackingStage.inTransit => l10n.trackingStageInTransit,
        TrackingStage.outForDelivery => l10n.trackingStageOutForDelivery,
        TrackingStage.delivered => l10n.trackingStageDelivered,
      };

  /// Resolves how a single stage should be painted.
  _StageState _stateOf(TrackingStage stage) {
    if (stage.index < currentStage.index) return _StageState.done;
    if (stage == currentStage) {
      return cancelled ? _StageState.cancelled : _StageState.current;
    }
    return _StageState.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder (not the viewport) decides: inside a dialog or a
    // constrained card the available width is what actually matters.
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        return width >= horizontalBreakpoint
            ? _buildHorizontal(context)
            : _buildVertical(context);
      },
    );
  }

  // ── horizontal rail ───────────────────────────────────────────────

  Widget _buildHorizontal(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    const stages = TrackingStage.values;

    return Row(
      key: const ValueKey('tracking-timeline-horizontal'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < stages.length; i++) ...[
          if (i > 0)
            // Connector: 15px puts a 2px line on the centre of the 32px node.
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Container(
                  height: 2,
                  color: i <= currentStage.index
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                ),
              ),
            ),
          Expanded(
            flex: 3,
            key: OrderTrackingTimeline.stageKey(stages[i]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StageNode(
                  stage: stages[i],
                  state: _stateOf(stages[i]),
                  size: 32,
                  iconSize: 16,
                ),
                const SizedBox(height: 6),
                _StageLabel(
                  stage: stages[i],
                  state: _stateOf(stages[i]),
                  label: _label(l10n, stages[i]),
                  timestamp: timestamps[stages[i]],
                  showTime: false,
                  centered: true,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── vertical rail ─────────────────────────────────────────────────

  Widget _buildVertical(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final stages = TrackingStage.values;

    return Column(
      key: const ValueKey('tracking-timeline-vertical'),
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < stages.length; i++)
          IntrinsicHeight(
            key: OrderTrackingTimeline.stageKey(stages[i]),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 40,
                  child: Column(
                    children: [
                      _StageNode(
                        stage: stages[i],
                        state: _stateOf(stages[i]),
                        size: 36,
                        iconSize: 18,
                      ),
                      if (i < stages.length - 1)
                        Expanded(
                          child: Center(
                            child: Container(
                              width: 2,
                              color: i + 1 <= currentStage.index
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 4,
                      bottom: AppSpacing.sm,
                    ),
                    child: _StageLabel(
                      stage: stages[i],
                      state: _stateOf(stages[i]),
                      label: _label(l10n, stages[i]),
                      timestamp: timestamps[stages[i]],
                      showTime: true,
                      centered: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

enum _StageState { done, current, upcoming, cancelled }

/// The circular marker for one stage.
class _StageNode extends StatelessWidget {
  const _StageNode({
    required this.stage,
    required this.state,
    required this.size,
    required this.iconSize,
  });

  final TrackingStage stage;
  final _StageState state;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (background, foreground, border) = switch (state) {
      _StageState.done => (scheme.primary, scheme.onPrimary, null),
      _StageState.current => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          Border.all(color: scheme.primary, width: 2),
        ),
      _StageState.upcoming => (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
          null,
        ),
      _StageState.cancelled => (
          scheme.surfaceContainerHighest,
          scheme.error,
          Border.all(color: scheme.error.withValues(alpha: 0.5)),
        ),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: border,
      ),
      child: Icon(
        OrderTrackingTimeline.iconFor(stage),
        size: iconSize,
        color: foreground,
      ),
    );
  }
}

/// Labels + timestamp attached to one node (centred on the horizontal rail).
class _StageLabel extends StatelessWidget {
  const _StageLabel({
    required this.stage,
    required this.state,
    required this.label,
    required this.timestamp,
    required this.showTime,
    required this.centered,
  });

  final TrackingStage stage;
  final _StageState state;
  final String label;
  final DateTime? timestamp;
  final bool showTime;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final current = state == _StageState.current;
    final upcoming = state == _StageState.upcoming;
    final bold = current || state == _StageState.done;

    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          key: ValueKey('stage-label-${stage.name}'),
          maxLines: centered ? 2 : null,
          overflow: centered ? TextOverflow.ellipsis : null,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: upcoming
                ? theme.colorScheme.onSurfaceVariant
                : current
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
          ),
        ),
        if (timestamp != null)
          Text(
            _format(context, timestamp!, showTime),
            style: (centered ? theme.textTheme.labelSmall : theme.textTheme.bodySmall)
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        if (state == _StageState.cancelled)
          Text(
            l10n.trackingCancelled,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  static String _format(BuildContext context, DateTime value, bool showTime) {
    final localizations = MaterialLocalizations.of(context);
    final local = value.toLocal();
    final date = localizations.formatMediumDate(local);
    if (!showTime) return date;
    final time = localizations.formatTimeOfDay(TimeOfDay.fromDateTime(local));
    return '$date · $time';
  }
}
