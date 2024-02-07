import 'package:activ8/view/setup/setup_state.dart';
import 'package:activ8/view/setup/widgets/large_icon.dart';
import 'package:activ8/view/widgets/custom_navigation_bar.dart';
import 'package:activ8/view/widgets/shorthand.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SetupLocationPermissionPage extends StatefulWidget {
  final SetupState setupState;
  final PageController pageController;

  const SetupLocationPermissionPage({
    super.key,
    required this.setupState,
    required this.pageController,
  });

  @override
  State<SetupLocationPermissionPage> createState() => _SetupLocationPermissionPageState();
}

class _SetupLocationPermissionPageState extends State<SetupLocationPermissionPage> {
  bool hasPermissions = false;
  bool showHint = false;

  void requestPermissionsAction() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please turn on location services."),
        ));
      }

      return;
    }

    // Request permission
    Future<bool> currentlyHasPermissions() async =>
        [LocationPermission.always, LocationPermission.whileInUse].contains(await Geolocator.checkPermission());
    Future<bool> grantedPermissions() async =>
        [LocationPermission.always, LocationPermission.whileInUse].contains(await Geolocator.requestPermission());
    hasPermissions = await currentlyHasPermissions() || await grantedPermissions();

    // Show failed message
    if (!hasPermissions) {
      showHint = true;
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please grant location permissions in settings."),
        ));
      }

      setState(() {});
      return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomNavigationBarWrapper(
          pageController: widget.pageController,
          enableNext: hasPermissions,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: _createContents(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _createContents(context) {
    final TextStyle? headingTheme = Theme.of(context).textTheme.headlineLarge;

    return [
      padding(48),

      // Icon
      LargeIcon(icon: Icons.near_me, color: Colors.blue.shade300),
      padding(16),

      // Title
      Text("Location Data", style: headingTheme),
      padding(8),

      // Description
      const Text(
        "To give you the most personalized"
        "\nexperience, we need to know your location",
        textAlign: TextAlign.center,
      ),
      padding(32),

      // Check Button
      _createCheckForPermissionsButton(context),
      _createHint(widget.pageController),

      // Navigation Bar
      Expanded(child: Container()),
    ];
  }

  /// Creates the [ElevatedButton] that checks for permissions if no permissions were found
  /// Creates an inactive [ElevatedButton] to report status if permissions were found
  Widget _createCheckForPermissionsButton(context) {
    // Permissions were found, create inactive button
    if (hasPermissions) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.check_outlined),
        label: const Text("Looks Good!"),
        onPressed: null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(128, 48),
        ),
      );
    }

    // Permissions were not found, create request button
    return ElevatedButton.icon(
      icon: const Icon(Icons.sync),
      label: const Text("Check for Permissions"),
      onPressed: requestPermissionsAction,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(128, 48),
      ),
    );
  }

  /// Creates the hint & actions that appear when permissions are not found
  Widget _createHint(PageController pageController) {
    return AnimatedOpacity(
      opacity: showHint ? 1 : 0,
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          padding(16),
          const Text(
            "To grant permissions manually"
            "\nSettings > Activ8 > Location > While Using the App",
            textAlign: TextAlign.center,
          ),
          padding(8),
          const TextButton(
            onPressed: AppSettings.openAppSettings,
            child: Text("Open Settings"),
          ),
        ],
      ),
    );
  }
}
