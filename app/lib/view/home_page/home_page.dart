import 'package:activ8/managers/api/v1/get_home_view.dart';
import 'package:activ8/managers/app_state.dart';
import 'package:activ8/utils/logger.dart';
import 'package:activ8/utils/snackbar.dart';
import 'package:activ8/view/entry_point.dart';
import 'package:activ8/view/home_page/home_view/lifestyle_score_widget.dart';
import 'package:activ8/view/home_page/home_view/message_widget.dart';
import 'package:activ8/view/home_page/home_view/suggestion_selector_widget.dart';
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

  Future<void> signOutAction() async {
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
      body: Scrollbar(
        thickness: 4,
        child: Container(
          decoration: const BoxDecoration(gradient: backgroundGradient),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: SizedBox(
              width: 370,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  padding(72),

                  // Title
                  // FittedBox allows the text to shrink to fit the container
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      "Welcome, $name",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  padding(20),

                  // Overview Category
                  const _CategoryMarker(label: "OVERVIEW"),

                  // Lifestyle Score
                  LifestyleScoreWidget(homeViewResponse: homeViewResponse),
                  padding(6),

                  MessageWidget(homeViewResponse: homeViewResponse),
                  padding(20),

                  // Suggestion Category
                  const _CategoryMarker(label: "SUGGESTIONS"),
                  const SuggestionSelectorWidget(),
                  padding(12),

                  // Sign-out Button
                  _SignOutButton(action: signOutAction),
                  padding(24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The small text above each section
class _CategoryMarker extends StatelessWidget {
  final String label;

  const _CategoryMarker({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0, bottom: 2.0),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.5),
              ),
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  final Function() action;

  const _SignOutButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: action,
          icon: const Icon(Icons.logout),
          label: const Text("Sign Out"),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: BorderSide(color: Colors.white.withOpacity(0.6), width: 1),
            ),
            backgroundColor: Colors.white.withOpacity(0.12),
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}
