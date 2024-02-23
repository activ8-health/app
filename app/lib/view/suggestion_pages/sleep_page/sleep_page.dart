import 'package:activ8/managers/api/v1/get_sleep_recommendation.dart';
import 'package:activ8/managers/app_state.dart';
import 'package:activ8/utils/snackbar.dart';
import 'package:activ8/view/suggestion_pages/sleep_page/sleep_time_widget.dart';
import 'package:activ8/view/widgets/shorthand.dart';
import 'package:activ8/view/widgets/back_button_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  late Future<V1GetSleepRecommendationResponse> sleepRecommendationResponse;

  // Query for 6 hours ago, so that up to 6 AM will still count as the day before
  final DateTime date = DateTime.now().subtract(const Duration(hours: 6));

  // uiGradients (Moonlit Asteroid)
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    sleepRecommendationResponse = loadApi();

    super.initState();
  }

  Future<V1GetSleepRecommendationResponse> loadApi() async {
    // Get the current location
    Position location = await Geolocator.getLastKnownPosition() ??
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // Send the request
    V1GetSleepRecommendationBody body = V1GetSleepRecommendationBody(date: date, location: location);
    V1GetSleepRecommendationResponse sleepRecommendation = await v1getSleepRecommendation(body, AppState.instance.auth);

    if (!sleepRecommendation.status.isSuccessful && context.mounted) {
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

    return Container(
      decoration: const BoxDecoration(gradient: backgroundGradient),
      child: Scaffold(
        appBar: const BackButtonAppBar(),
        backgroundColor: Colors.transparent,
        body: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              padding(8),
              const Icon(Icons.bedtime_outlined, size: 60),
              padding(12),
              Text(
                "Sleep Schedule",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              padding(8),
              descriptionText,
              padding(16),
              FutureBuilder(
                future: sleepRecommendationResponse,
                builder: (BuildContext context, AsyncSnapshot<V1GetSleepRecommendationResponse> snapshot) {
                  Widget widget;
                  // Loading or error
                  if (snapshot.connectionState != ConnectionState.done ||
                      !snapshot.hasData ||
                      !snapshot.data!.status.isSuccessful) {
                    widget = const SleepTimeWidget(key: ValueKey(0));
                  } else {
                    // Get data from the API
                    V1GetSleepRecommendationResponse data = snapshot.data!;

                    widget = SleepTimeWidget(
                      key: const ValueKey(1),
                      sleepTime: data.sleepRangeStart,
                      wakeTime: data.sleepRangeEnd,
                      date: date,
                    );
                  }

                  // Animate between the pre- and post-loading screens
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: widget,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
