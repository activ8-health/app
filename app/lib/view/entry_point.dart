import 'package:activ8/constants.dart';
import 'package:activ8/managers/api/v1/update_health_data.dart';
import 'package:activ8/managers/app_state.dart';
import 'package:activ8/managers/health_manager.dart';
import 'package:activ8/types/health_data.dart';
import 'package:activ8/view/home_page/home_page.dart';
import 'package:activ8/view/setup_pages/setup_page.dart';
import 'package:activ8/view/widgets/shorthand.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:health/health.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  late Future<bool> data;

  @override
  void initState() {
    data = AppState.instance.initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: data,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          Widget child;
          if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
            child = const _Loading(
              key: ValueKey(3),
            );
          } else if (snapshot.data!) {
            // User found
            _updateHealthData();
            child = const HomePage(
              key: ValueKey(2),
            );
          } else {
            // User not found
            child = const SetupPage(key: ValueKey(4));
          }

          // Animate the loading screen to the target screen
          return Container(
            color: Theme.of(context).colorScheme.background,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeInQuart,
              switchOutCurve: Curves.easeOutQuart,
              child: child,
            ),
          );
        });
  }
}

class _Loading extends StatelessWidget {
  const _Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 128,
              height: 128,
              child: ClipRRect(
                borderRadius: largeIconBorderRadius,
                child: Image.asset("assets/icon.png"),
              ),
            ),
            padding(16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

Future<void> _updateHealthData() async {
  // Retrieve health points from the last 90 days
  int days = 90;

  List<SleepPoint> sleepData = (await HealthManager.instance.retrieveSleepData(days: days))
      .map((point) => SleepPoint(dateFrom: point.dateFrom, dateTo: point.dateTo))
      .toList();

  List<StepPoint> stepData = (await HealthManager.instance.retrieveStepData(days: days))
      .map((point) => StepPoint(
          dateFrom: point.dateFrom,
          dateTo: point.dateTo,
          steps: (point.value as NumericHealthValue).numericValue.toInt()))
      .toList();

  HealthData healthData = HealthData(
    stepData: stepData,
    sleepData: sleepData,
  );

  // Get the current location
  Position location = await Geolocator.getLastKnownPosition() ??
      await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  V1UpdateHealthDataBody body = V1UpdateHealthDataBody(healthData: healthData, location: location);

  await v1updateHealthData(body, AppState.instance.auth);
}
