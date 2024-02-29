import "dart:ui";

import "package:activ8/constants.dart";
import "package:activ8/managers/api/v1/get_food_recommendation.dart";
import "package:activ8/managers/food_manager.dart";
import "package:activ8/shorthands/padding.dart";
import "package:activ8/types/food/menu.dart";
import "package:activ8/utils/future_widget_selector.dart";
import "package:activ8/view/suggestion_pages/food_page/food_log/edit_food_log_entry_page.dart";
import "package:activ8/view/widgets/clear_card.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:intl/intl.dart";

class FoodRecommendationWidget extends StatelessWidget {
  final Future<V1GetFoodRecommendationResponse> foodRecommendationFuture;
  final Function()? refresh;

  const FoodRecommendationWidget({super.key, required this.foodRecommendationFuture, this.refresh});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: foodRecommendationFuture,
      builder: (BuildContext context, AsyncSnapshot<V1GetFoodRecommendationResponse> snapshot) {
        final Widget widget = futureWidgetSelector(
          snapshot,
          failureWidget: _Widget(key: const ValueKey(1), recommendations: const [], refresh: refresh),
          successWidgetBuilder: (V1GetFoodRecommendationResponse response) {
            return _Widget(key: const ValueKey(0), recommendations: response.recommendations, refresh: refresh);
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
  final List<FoodMenuItem> recommendations;
  final Function()? refresh;

  const _Widget({super.key, required this.recommendations, this.refresh});

  @override
  Widget build(BuildContext context) {
    // Only show message (other widget) if no recommendations
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return ClearCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final FoodMenuItem recommendation in recommendations) ...[
            _createFoodCard(context, recommendation),
            if (recommendation != recommendations.last) const ClearCardDivider(),
          ],
        ],
      ),
    );
  }

  Widget _createFoodCard(BuildContext context, FoodMenuItem recommendation) {
    return InkWell(
      onTap: () async {
        // Show add page, with preset
        final FoodLogEntry? entry = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          // Prevent the user from dismissing outside of the "back" button, which messes up return values
          isDismissible: false,
          enableDrag: false,
          builder: (BuildContext context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: FractionallySizedBox(
                heightFactor: 0.85,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  child: EditFoodLogEntryPage(
                      isEditing: false,
                      // Placeholder widget
                      sourceEntry: FoodLogEntry(
                        item: recommendation,
                        date: DateTime.now(),
                        rating: defaultRatingStars,
                        servings: 1.0,
                      )),
                ),
              ),
            );
          },
        );

        // If a new entry is to be added
        if (entry != null) {
          FoodManager.instance.addFoodLogEntry(entry);
          if (refresh != null) refresh!();
        }
      },
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _createHeader(recommendation.name, recommendation.calories),

            // Description
            Text(
              recommendation.description.isNotEmpty ? recommendation.description : "No description available",
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _createHeader(String title, int calories) {
    final NumberFormat decimalFormatter = NumberFormat.decimalPattern();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        padding(8),

        // Calories
        Text(
          "${decimalFormatter.format(calories)} cal",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.6)),
        ),
      ],
    );
  }
}
