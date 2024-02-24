import "package:activ8/managers/api/v1/get_activity_recommendation.dart";
import "package:activ8/managers/app_state.dart";
import "package:activ8/managers/location_manager.dart";
import "package:activ8/shorthands/gradient_scaffold.dart";
import "package:activ8/shorthands/padding.dart";
import "package:activ8/utils/snackbar.dart";
import "package:activ8/view/suggestion_pages/exercise_page/calories_message.dart";
import "package:activ8/view/suggestion_pages/exercise_page/recommendation_message.dart";
import "package:activ8/view/suggestion_pages/exercise_page/step_progress_widget.dart";
import "package:activ8/view/widgets/category_marker.dart";
import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";

// uiGradients (Emerald Water)
const LinearGradient _backgroundGradient = LinearGradient(
  colors: [Color(0xEDD38312), Color(0xFEA83279)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  late Future<V1GetActivityRecommendationResponse> activityRecommendationFuture = _loadApi();

  Future<V1GetActivityRecommendationResponse> _loadApi() async {
    // Get the current location
    final Position location = await LocationManager.instance.getLocation();

    // Send the request
    final V1GetActivityRecommendationBody body = V1GetActivityRecommendationBody(location: location);
    final V1GetActivityRecommendationResponse response =
        await v1getActivityRecommendation(body, AppState.instance.auth);

    // Send snackbar if error
    if (mounted && !response.status.isSuccessful) {
      showSnackBar(context, "ERROR: ${response.errorMessage}");
    }

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      hasBackButton: true,
      backgroundGradient: _backgroundGradient,
      child: _allowRefresh(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            padding(58),

            // Title
            const Icon(Icons.directions_run, size: 60),
            padding(12),
            Text(
              "Exercise",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            padding(16),

            // Step Progress
            const CategoryMarker(label: "STEP PROGRESS"),
            StepProgressWidget(activityRecommendationFuture: activityRecommendationFuture),
            padding(12),

            // Calories
            const CategoryMarker(label: "CALORIES"),
            CaloriesMessage(activityRecommendationFuture: activityRecommendationFuture),
            padding(12),

            // Message
            const CategoryMarker(label: "RECOMMENDATION"),
            RecommendationMessage(activityRecommendationFuture: activityRecommendationFuture),
          ],
        ),
      ),
    );
  }

  Widget _allowRefresh({required Widget child}) {
    return Align(
      alignment: Alignment.topCenter,
      child: RefreshIndicator(
        displacement: 80,
        backgroundColor: Colors.white.withOpacity(0.2),
        color: Colors.white,
        onRefresh: () async {
          activityRecommendationFuture = _loadApi();
          await activityRecommendationFuture;
          setState(() {});
        },
        child: SizedBox(
          width: 370,
          child: SizedBox.expand(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // TODO remove if not necessary
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
