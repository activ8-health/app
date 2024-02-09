import 'package:activ8/managers/app_state.dart';
import 'package:activ8/utils/logger.dart';
import 'package:activ8/view/entry_point.dart';
import 'package:activ8/view/widgets/shorthand.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Home Page", style: Theme.of(context).textTheme.headlineMedium),
          Text("Welcome, ${AppState.instance.userProfile?.name}"),
          padding(36),
          Text("Debug: UserProfile(${AppState.instance.userProfile?.toJson()})"),
          padding(8),
          Text("Debug: UserPreferences(${AppState.instance.userPreferences?.toJson()})"),
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
    );
  }
}
