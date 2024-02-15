import 'package:activ8/managers/api/v1/get_home_view.dart';
import 'package:activ8/managers/app_state.dart';
import 'package:activ8/utils/logger.dart';
import 'package:activ8/utils/snackbar.dart';
import 'package:activ8/view/entry_point.dart';
import 'package:activ8/view/home_page/home_view/lifestyle_score_widget.dart';
import 'package:activ8/view/widgets/shorthand.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<V1GetHomeViewResponse> homeViewResponse;

  Future<V1GetHomeViewResponse> loadApi() async {
    // Get the current location
    Position location = await Geolocator.getLastKnownPosition() ??
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // Send the request
    V1GetHomeViewBody body = V1GetHomeViewBody(location: location);
    V1GetHomeViewResponse response = await v1getHomeView(body, AppState.instance.auth);

    // Send snackbar if error
    if (context.mounted && !response.status.isSuccessful) {
      showSnackBar(context, "ERROR: ${response.errorMessage}");
    }

    return response;
  }

  @override
  void initState() {
    assert(AppState.instance.userProfile != null, "User profile does not exist, perhaps we aren't logged in?");
    homeViewResponse = loadApi();
    super.initState();
  }

  // uiGradients Starfall (darkened)
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF4B1248), Color(0xFF685334)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final String name = AppState.instance.userProfile!.name;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: backgroundGradient),
        alignment: Alignment.center,
        child: SafeArea(
          child: SizedBox(
            width: 350,
            child: Column(
              children: [
                padding(48),

                // FittedBox allows the text to shrink to fit the container
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    "Welcome, $name",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                padding(12),

                // Lifestyle Score
                LifestyleScoreWidget(homeViewResponse: homeViewResponse),
                padding(36),

                // TODO do something with the sign-out workflow
                ElevatedButton(
                  onPressed: () async {
                    logger.i("Signing out and restarting app");
                    await AppState.instance.signOut();

                    if (!context.mounted) return;

                    // Pop all pages
                    Navigator.of(context).popUntil((route) => route.isFirst);

                    // Open new page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const EntryPoint()),
                    );
                  },
                  child: const Text("Sign Out"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
