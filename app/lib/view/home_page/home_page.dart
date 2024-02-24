import "package:activ8/managers/api/v1/get_home_view.dart";
import "package:activ8/managers/app_state.dart";
import "package:activ8/managers/location_manager.dart";
import "package:activ8/utils/logger.dart";
import "package:activ8/shorthands/gradient_scaffold.dart";
import "package:activ8/shorthands/padding.dart";
import "package:activ8/utils/snackbar.dart";
import "package:activ8/view/entry_point.dart";
import "package:activ8/view/home_page/home_view/lifestyle_score_widget.dart";
import "package:activ8/view/home_page/home_view/message_widget.dart";
import "package:activ8/view/home_page/home_view/suggestion_selector_widget.dart";
import "package:activ8/view/widgets/category_marker.dart";
import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";

// uiGradients (Starfall, manually darkened)
const LinearGradient _backgroundGradient = LinearGradient(
  colors: [Color(0xFF4B1248), Color(0xFF685334)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<V1GetHomeViewResponse> homeViewFuture = _loadApi();

  Future<V1GetHomeViewResponse> _loadApi() async {
    // Get the current location
    final Position location = await LocationManager.instance.getLocation();

    // Send the request
    final V1GetHomeViewBody body = V1GetHomeViewBody(location: location);
    final V1GetHomeViewResponse response = await v1getHomeView(body, AppState.instance.auth);

    // Send snackbar if error
    if (mounted && !response.status.isSuccessful) {
      showSnackBar(context, "ERROR: ${response.errorMessage}");
    }

    return response;
  }

  Future<void> signOutAction() async {
    logger.i("Signing out and restarting app");
    await AppState.instance.signOut();

    if (!mounted) return;

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
    super.initState();
    assert(AppState.instance.userProfile != null, "User profile does not exist, perhaps we aren't logged in?");
  }

  @override
  Widget build(BuildContext context) {
    final String name = AppState.instance.userProfile!.name;
    return Scrollbar(
      thickness: 4,
      child: GradientScaffold(
        backgroundGradient: _backgroundGradient,
        hasBackButton: false,
        child: _allowRefresh(
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
              const CategoryMarker(label: "OVERVIEW"),

              // Lifestyle Score
              LifestyleScoreWidget(homeViewResponse: homeViewFuture),
              padding(6),

              MessageWidget(homeViewResponse: homeViewFuture),
              padding(20),

              // Suggestion Category
              const CategoryMarker(label: "SUGGESTIONS"),
              const SuggestionSelectorWidget(),
              padding(12),

              // Sign-out Button
              _SignOutButton(action: signOutAction),
              padding(24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _allowRefresh({required Widget child}) {
    return RefreshIndicator(
      displacement: 80,
      backgroundColor: Colors.white.withOpacity(0.2),
      color: Colors.white,
      onRefresh: () async {
        homeViewFuture = _loadApi();
        await homeViewFuture;
        setState(() {});
      },
      child: SingleChildScrollView(
        child: SizedBox(
          width: 370,
          child: child,
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
