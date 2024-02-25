import "package:activ8/extensions/snapshot_loading.dart";
import "package:activ8/managers/api/v1/update_health_data.dart";
import "package:activ8/managers/app_state.dart";
import "package:activ8/managers/health_manager.dart";
import "package:activ8/managers/location_manager.dart";
import "package:activ8/shorthands/padding.dart";
import "package:activ8/types/health_data.dart";
import "package:activ8/view/home_page/home_page.dart";
import "package:activ8/view/setup_pages/setup_page.dart";
import "package:activ8/view/setup_pages/widgets/large_icon.dart";
import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  late Future<bool> hasUserFuture = AppState.instance.initialize();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: hasUserFuture,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        // Animate the loading screen to the target screen
        return Container(
          color: Theme.of(context).colorScheme.background,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeInQuart,
            switchOutCurve: Curves.easeOutQuart,
            child: _getWidget(snapshot),
          ),
        );
      },
    );
  }

  Widget _getWidget(AsyncSnapshot<bool> snapshot) {
    if (snapshot.isLoading) return const _Loading(key: ValueKey(3));

    final bool userFound = snapshot.data!;
    if (!userFound) {
      return const SetupPage(key: ValueKey(4));
    }

    _updateHealthData();
    return const HomePage(key: ValueKey(2));
  }
}

class _Loading extends StatelessWidget {
  const _Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LargeIcon(child: Image.asset("assets/icon.png")),
            padding(16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

Future<void> _updateHealthData() async {
  final HealthData healthData = await HealthManager.instance.retrieveHealthData();
  final Position location = await LocationManager.instance.getLocation();

  final V1UpdateHealthDataBody body = V1UpdateHealthDataBody(
    healthData: healthData,
    location: location,
  );

  await v1updateHealthData(body, AppState.instance.auth);
}
