import "package:activ8/shorthands/gradient_scaffold.dart";
import "package:activ8/shorthands/padding.dart";
import "package:activ8/view/suggestion_pages/food_page/food_log/add_food_entry_fab.dart";
import "package:activ8/view/suggestion_pages/food_page/food_log/food_log_preview_widget.dart";
import "package:activ8/view/suggestion_pages/food_page/shared.dart";
import "package:activ8/view/widgets/category_marker.dart";
import "package:flutter/material.dart";

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      floatingActionButton: AddFoodEntryFAB(refresh: () => setState(() {})),
      hasBackButton: true,
      backgroundGradient: backgroundGradient,
      child: _allowRefresh(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            padding(58),

            // Icon
            const Icon(Icons.restaurant_menu, size: 60),
            padding(12),

            // Title
            Text("Food & Nutrition", style: Theme.of(context).textTheme.headlineLarge),
            padding(8),

            // TODO calorie counter
            // Calories
            const CategoryMarker(label: "CALORIES CONSUMED"),

            // TODO recommendations
            // Recommendations
            const CategoryMarker(label: "FOOD RECOMMENDATIONS"),

            // Food Log
            const CategoryMarker(label: "FOOD LOG"),
            FoodLogPreviewWidget(refresh: () => setState(() {})),
          ],
        ),
      ),
    );
  }

  Widget _allowRefresh({required Widget child}) {
    // TODO perhaps these allowRefreshes can be combined?
    return Align(
      alignment: Alignment.topCenter,
      child: RefreshIndicator(
        displacement: 80,
        backgroundColor: Colors.white.withOpacity(0.2),
        color: Colors.white,
        onRefresh: () async {
          // TODO refresh
          setState(() {});
        },
        child: SizedBox(
          width: 370,
          child: SizedBox.expand(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
