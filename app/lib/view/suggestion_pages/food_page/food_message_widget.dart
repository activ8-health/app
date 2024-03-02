import "package:activ8/managers/api/v1/get_food_recommendation.dart";
import "package:activ8/shorthands/padding.dart";
import "package:activ8/utils/future_widget_selector.dart";
import "package:activ8/view/widgets/clear_card.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class FoodMessageWidget extends StatelessWidget {
  final Future<V1GetFoodRecommendationResponse> foodRecommendationFuture;

  const FoodMessageWidget({super.key, required this.foodRecommendationFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: foodRecommendationFuture,
      builder: (BuildContext context, AsyncSnapshot<V1GetFoodRecommendationResponse> snapshot) {
        final Widget widget = futureWidgetSelector(
          snapshot,
          failureWidget: const SizedBox(height: 0, child: SizedBox.expand()),
          successWidgetBuilder: (V1GetFoodRecommendationResponse response) {
            return ClearCard(
              color: Colors.blue.shade200,
              padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 10.0, right: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Symbols.skillet,
                    size: 36,
                    color: Colors.blue.shade100,
                  ),
                  padding(4),
                  Expanded(
                    child: Text(
                      response.message!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
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
