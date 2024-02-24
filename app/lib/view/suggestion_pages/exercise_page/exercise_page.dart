import 'package:activ8/managers/api/v1/get_activity_recommendation.dart';
import 'package:activ8/managers/app_state.dart';
import 'package:activ8/utils/snackbar.dart';
import 'package:activ8/view/suggestion_pages/exercise_page/calories_message.dart';
import 'package:activ8/view/suggestion_pages/exercise_page/recommendation_message.dart';
import 'package:activ8/view/suggestion_pages/exercise_page/step_progress_widget.dart';
import 'package:activ8/view/widgets/back_button_app_bar.dart';
import 'package:activ8/view/widgets/category_marker.dart';
import 'package:activ8/view/widgets/shorthand.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  late Future<V1GetActivityRecommendationResponse> activityRecommendationFuture;

  Future<V1GetActivityRecommendationResponse> loadApi() async {
    // Get the current location
    Position location = await Geolocator.getLastKnownPosition() ??
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // Send the request
    V1GetActivityRecommendationBody body = V1GetActivityRecommendationBody(location: location);
    V1GetActivityRecommendationResponse response = await v1getActivityRecommendation(body, AppState.instance.auth);

    // Send snackbar if error
    if (context.mounted && !response.status.isSuccessful) {
      showSnackBar(context, "ERROR: ${response.errorMessage}");
    }

    return response;
  }

  @override
  void initState() {
    activityRecommendationFuture = loadApi();
    super.initState();
  }

  // uiGradients (Emerald Water)
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xEDD38312), Color(0xFEA83279)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const BackButtonAppBar(),
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Container(
          color: Colors.black,
          child: Container(
            decoration: const BoxDecoration(gradient: backgroundGradient),
            alignment: Alignment.topCenter,
            child: RefreshIndicator(
              displacement: 80,
              backgroundColor: Colors.white.withOpacity(0.2),
              color: Colors.white,
              onRefresh: () async {
                // TODO refresh logic
                setState(() {});
              },
              child: SizedBox(
                width: 370,
                child: SizedBox.expand(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(), // TODO remove if not necessary
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
                        const CaloriesMessage(),
                        padding(12),

                        // Message
                        const CategoryMarker(label: "RECOMMENDATION"),
                        const RecommendationMessage(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
