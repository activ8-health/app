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
    return Container(
      color: Colors.black,
      child: Container(
        decoration: const BoxDecoration(gradient: backgroundGradient),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const BackButtonAppBar(),
          body: SizedBox.expand(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                padding(8),
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
    );
  }
}
