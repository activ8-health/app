import 'package:activ8/managers/api/v1/get_activity_recommendation.dart';
import 'package:activ8/view/suggestion_pages/exercise_page/step_progress_gauge.dart';
import 'package:activ8/view/widgets/clear_card.dart';
import 'package:activ8/view/widgets/shorthand.dart';
import 'package:flutter/material.dart';

class StepProgressWidget extends StatelessWidget {
  final Future<V1GetActivityRecommendationResponse> activityRecommendationFuture;

  const StepProgressWidget({super.key, required this.activityRecommendationFuture});

  @override
  Widget build(BuildContext context) {
    const double stepProgress = 12000;
    const double stepTarget = 20000;

    return ClearCard(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24).copyWith(top: 16, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getProgressLabel(context, stepProgress, stepTarget),
            padding(4),
            const StepProgressGauge(progress: stepProgress, target: stepTarget),
          ],
        ),
      ),
    );
  }

  Widget _getProgressLabel(BuildContext context, double stepProgress, double stepTarget) {
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
        Text(
          stepProgress.toStringAsFixed(0),
          style: progressTextStyle,
        ),
        Text(
          " / ${stepTarget.toStringAsFixed(0)}",
          style: targetTextStyle,
        ),
      ],
    );
  }
}
