import "package:activ8/managers/api/api_auth.dart";
import "package:activ8/managers/api/v1/get_sleep_recommendation.dart";
import "package:activ8/managers/app_state.dart";
import "package:activ8/managers/location_manager.dart";
import "package:activ8/shorthands/gradient_scaffold.dart";
import "package:activ8/shorthands/padding.dart";
import "package:activ8/utils/future_widget_selector.dart";
import "package:activ8/utils/snackbar.dart";
import "package:activ8/view/suggestion_pages/sleep_page/sleep_time_widget.dart";
import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";

// uiGradients (Moonlit Asteroid)
const LinearGradient _backgroundGradient = LinearGradient(
  colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  // Must not be final to allow refresh, therefore cannot be stateless
  late Future<V1GetSleepRecommendationResponse> sleepRecommendationFuture = _loadApi();

  // Query for 6 hours ago, so that up to 6 AM will still count as the day before
  // Only the date of this request should matter, not the time
  DateTime dateToQuery = DateTime.now().subtract(const Duration(hours: 6));

  Future<V1GetSleepRecommendationResponse> _loadApi() async {
    dateToQuery = DateTime.now().subtract(const Duration(hours: 6));

    // Get the current location
    final Position location = await LocationManager.instance.getLocation();

    // Send the request
    final V1GetSleepRecommendationBody body = V1GetSleepRecommendationBody(date: dateToQuery, location: location);
    final Auth auth = AppState.instance.auth;
    final V1GetSleepRecommendationResponse sleepRecommendation = await v1getSleepRecommendation(body, auth);

    if (!sleepRecommendation.status.isSuccessful && mounted) {
      showSnackBar(context, "ERROR: ${sleepRecommendation.errorMessage}");
    }

    return sleepRecommendation;
  }

  @override
  Widget build(BuildContext context) {
    final Widget descriptionText = RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(0.75)),
        children: const [
          TextSpan(text: "We designed your sleep schedule around\nyour "),
          TextSpan(text: "sleeping patterns", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: " and "),
          TextSpan(text: "core hours,", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: "\ntailored to the day of the week"),
        ],
      ),
      textAlign: TextAlign.center,
    );

    return GradientScaffold(
      hasBackButton: true,
      backgroundGradient: _backgroundGradient,
      child: _allowRefresh(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            padding(58),

            // Title
            const Icon(Icons.bedtime_outlined, size: 60),
            padding(12),
            Text("Sleep Schedule", style: Theme.of(context).textTheme.headlineLarge),
            padding(8),

            // Description
            descriptionText,
            padding(16),

            // Sleep Time Widget
            FutureBuilder(
              future: sleepRecommendationFuture,
              builder: (BuildContext context, AsyncSnapshot<V1GetSleepRecommendationResponse> snapshot) {
                final Widget widget = futureWidgetSelector(
                  snapshot,
                  failureWidget: const SleepTimeWidget(key: ValueKey(1)),
                  successWidgetBuilder: (V1GetSleepRecommendationResponse response) {
                    return SleepTimeWidget(
                      key: const ValueKey(0),
                      sleepTime: response.sleepRangeStart,
                      wakeTime: response.sleepRangeEnd,
                      date: dateToQuery,
                    );
                  },
                );

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: widget,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// The wrapped widget can refresh, causing [sleepRecommendationFuture] to be reset
  Widget _allowRefresh({required Widget child}) {
    return RefreshIndicator(
      displacement: 80,
      backgroundColor: Colors.white.withOpacity(0.2),
      color: Colors.white,
      onRefresh: () async {
        sleepRecommendationFuture = _loadApi();
        await sleepRecommendationFuture;
        setState(() {});
      },
      child: SizedBox.expand(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: child,
        ),
      ),
    );
  }
}
