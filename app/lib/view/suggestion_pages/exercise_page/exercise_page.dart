import 'package:activ8/view/widgets/back_button_app_bar.dart';
import 'package:activ8/view/widgets/shorthand.dart';
import 'package:flutter/material.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  // uiGradients (Emerald Water)
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xBBD38312), Color(0xCCA83279)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    // TODO
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const BackButtonAppBar(),
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Container(
          color: Colors.black,
          child: Container(
            decoration: const BoxDecoration(gradient: backgroundGradient),
            child: RefreshIndicator(
              displacement: 80,
              backgroundColor: Colors.white.withOpacity(0.2),
              color: Colors.white,
              onRefresh: () async {
                // TODO refresh logic
                setState(() {});
              },
              child: SizedBox.expand(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(), // TODO remove if not necessary
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      padding(58),
                      const Icon(Icons.directions_run, size: 60),
                      padding(12),
                      Text(
                        "Exercise",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      padding(8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
