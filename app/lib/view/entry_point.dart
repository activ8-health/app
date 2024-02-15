import 'package:activ8/managers/app_state.dart';
import 'package:activ8/view/home_page/home_page.dart';
import 'package:activ8/view/setup_pages/setup_page.dart';
import 'package:activ8/view/widgets/shorthand.dart';
import 'package:flutter/material.dart';

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
                borderRadius: BorderRadius.circular(28),
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
