import "package:activ8/managers/api/v1/get_food_recommendation.dart";
import "package:activ8/shorthands/padding.dart";
import "package:activ8/utils/future_widget_selector.dart";
import "package:activ8/view/suggestion_pages/food_page/food_calories_gauge.dart";
import "package:activ8/view/widgets/clear_card.dart";
import "package:flutter/material.dart";

class FoodCaloriesWidget extends StatelessWidget {
  final Future<V1GetFoodRecommendationResponse> foodRecommendationFuture;

  const FoodCaloriesWidget({super.key, required this.foodRecommendationFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: foodRecommendationFuture,
      builder: (context, snapshot) {
        final Widget widget = futureWidgetSelector(
          snapshot,
          failureWidget: const _Widget(key: ValueKey(1)),
          successWidgetBuilder: (response) {
            return _Widget(
              key: const ValueKey(0),
              caloriesGoal: response.caloriesGoal,
              caloriesConsumed: response.caloriesConsumed,
              message: response.message,
            );
          },
        );

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: widget,
        );
      },
    );
  }
}

class _Widget extends StatelessWidget {
  final int? caloriesGoal;
  final int? caloriesConsumed;
  final String? message;

  const _Widget({super.key, this.caloriesGoal, this.caloriesConsumed, this.message});

  @override
  Widget build(BuildContext context) {
    return ClearCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          padding(8),
          Expanded(
            child: SizedBox(
              height: 180,
              child: FoodCaloriesGauge(
                caloriesGoal: caloriesGoal,
                caloriesConsumed: caloriesConsumed,
              ),
            ),
          ),
          padding(8),
          _createMessage(context),
          padding(8),
        ],
      ),
    );
  }

  Widget _createMessage(context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(message ?? "Loading...", style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
