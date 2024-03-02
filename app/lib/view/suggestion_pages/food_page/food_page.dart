import "package:activ8/managers/api/api_auth.dart";
import "package:activ8/managers/api/v1/get_food_recommendation.dart";
import "package:activ8/managers/app_state.dart";
import "package:activ8/managers/location_manager.dart";
import "package:activ8/shorthands/gradient_scaffold.dart";
import "package:activ8/shorthands/padding.dart";
import "package:activ8/utils/snackbar.dart";
import "package:activ8/view/suggestion_pages/food_page/food_calories_widget.dart";
import "package:activ8/view/suggestion_pages/food_page/food_log/add_food_entry_fab.dart";
import "package:activ8/view/suggestion_pages/food_page/food_log/food_log_preview_widget.dart";
import "package:activ8/view/suggestion_pages/food_page/food_message_widget.dart";
import "package:activ8/view/suggestion_pages/food_page/food_recommendation_widget.dart";
import "package:activ8/view/suggestion_pages/food_page/shared.dart";
import "package:activ8/view/widgets/category_marker.dart";
import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  late Future<V1GetFoodRecommendationResponse> foodRecommendationFuture = _loadApi();

  Future<V1GetFoodRecommendationResponse> _loadApi() async {
    // Get the current location
    final Position location = await LocationManager.instance.getLocation();

    // Send the request
    final V1GetFoodRecommendationBody body = V1GetFoodRecommendationBody(location: location);
    final Auth auth = AppState.instance.auth;
    final V1GetFoodRecommendationResponse response = await v1getFoodRecommendation(body, auth);

    // Send snackbar if error
    if (mounted && !response.status.isSuccessful) {
      showSnackBar(context, "ERROR: ${response.errorMessage}");
    }

    return response;
  }

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

            // Calories
            const CategoryMarker(label: "CALORIES CONSUMED"),
            FoodCaloriesWidget(foodRecommendationFuture: foodRecommendationFuture),
            padding(8),
            FoodMessageWidget(foodRecommendationFuture: foodRecommendationFuture),

            padding(20),

            // TODO show message

            // Recommendations
            const CategoryMarker(label: "FOOD RECOMMENDATIONS"),
            FoodRecommendationWidget(
              foodRecommendationFuture: foodRecommendationFuture,
              refresh: () => setState(() {}),
            ),

            padding(20),

            // Food Log
            const CategoryMarker(label: "YOUR FOOD LOG"),
            FoodLogPreviewWidget(refresh: () => setState(() {})),

            // Bottom padding to prevent the FAB from cutting off items
            padding(52),
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
          foodRecommendationFuture = _loadApi();
          await foodRecommendationFuture;
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
