import "package:activ8/shorthands/gradient_scaffold.dart";
import "package:activ8/shorthands/padding.dart";
import "package:activ8/view/suggestion_pages/food_page/food_log/add_food_entry_fab.dart";
import "package:activ8/view/suggestion_pages/food_page/food_log/preview.dart";
import "package:activ8/view/widgets/category_marker.dart";
import "package:flutter/material.dart";

// uiGradients (Crazy Orange I)
const LinearGradient _backgroundGradient = LinearGradient(
  colors: [Color(0xAA348F50), Color(0x8856B4D3)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  @override
  Widget build(BuildContext context) {
    // TODO
    return GradientScaffold(
      floatingActionButton: const AddFoodEntryFAB(),
      hasBackButton: true,
      backgroundGradient: _backgroundGradient,
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
            const FoodLogPreviewWidget(),
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
