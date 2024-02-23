import 'package:activ8/view/widgets/back_button_app_bar.dart';
import 'package:activ8/view/widgets/shorthand.dart';
import 'package:flutter/material.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  // uiGradients (Crazy Orange I)
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xAA348F50), Color(0x8856B4D3)],
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
                const Icon(Icons.restaurant_menu, size: 60),
                padding(12),
                Text(
                  "Food & Nutrition",
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
