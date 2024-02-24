import 'package:activ8/managers/api/v1/get_activity_recommendation.dart';
import 'package:activ8/view/suggestion_pages/exercise_page/step_progress_gauge.dart';
import 'package:activ8/view/widgets/clear_card.dart';
import 'package:activ8/view/widgets/shorthand.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class StepProgressWidget extends StatelessWidget {
  final Future<V1GetActivityRecommendationResponse> activityRecommendationFuture;

  const StepProgressWidget({super.key, required this.activityRecommendationFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: activityRecommendationFuture,
      builder: (BuildContext context, AsyncSnapshot<V1GetActivityRecommendationResponse> snapshot) {
        Widget widget;
        // Loading
        if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
          widget = const _Widget(key: ValueKey(1));
        } else {
          // Interpret data
          V1GetActivityRecommendationResponse response = snapshot.data!;

          if (!response.status.isSuccessful) {
            // Error
            widget = const _Widget(key: ValueKey(1));
          } else {
            // Success
            widget = _Widget(
              key: const ValueKey(0),
              stepProgress: response.stepProgress?.toDouble(),
              stepTarget: response.stepTarget?.toDouble(),
            );
          }
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: widget,
        );
      },
    );
  }
}

class _Widget extends StatelessWidget {
  final double? stepProgress;
  final double? stepTarget;

  const _Widget({super.key, this.stepProgress, this.stepTarget});

  @override
  Widget build(BuildContext context) {
    return ClearCard(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24).copyWith(top: 16, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getProgressLabel(context, stepProgress, stepTarget),
            padding(4),
            StepProgressGauge(progress: stepProgress ?? 0, target: stepTarget ?? 10),
          ],
        ),
      ),
    );
  }

  Widget _getProgressLabel(BuildContext context, double? stepProgress, double? stepTarget) {
    final TextStyle? progressTextStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        );

    final TextStyle? targetTextStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white.withOpacity(0.5),
          fontWeight: FontWeight.bold,
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Symbols.footprint, size: 36),
        padding(8),
        Text(
          stepProgress?.toStringAsFixed(0) ?? "--",
          style: progressTextStyle,
        ),
        Text(
          " / ${stepTarget?.toStringAsFixed(0) ?? "--"}",
          style: targetTextStyle,
        ),
        padding(12),
      ],
    );
  }
}
