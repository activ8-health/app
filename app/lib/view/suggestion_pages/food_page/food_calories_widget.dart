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

  const _Widget({super.key, this.caloriesGoal, this.caloriesConsumed});

  @override
  Widget build(BuildContext context) {
    return ClearCard(
      child: SizedBox(
        width: double.infinity,
        height: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: FoodCaloriesGauge(
                caloriesGoal: caloriesGoal,
                caloriesConsumed: caloriesConsumed,
              ),
            ),
            _createLabel(context),
            padding(16),
          ],
        ),
      ),
    );
  }

  Widget _createLabel(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: "${caloriesConsumed ?? "--"}", style: Theme.of(context).textTheme.headlineLarge),
              TextSpan(text: " cal", style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
        Text("of ${caloriesGoal ?? "--"}", style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}
