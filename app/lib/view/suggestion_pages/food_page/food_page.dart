import "package:activ8/shorthands/gradient_scaffold.dart";
import "package:activ8/shorthands/padding.dart";
import "package:flutter/material.dart";

// uiGradients (Crazy Orange I)
const LinearGradient _backgroundGradient = LinearGradient(
  colors: [Color(0xAA348F50), Color(0x8856B4D3)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  @override
  Widget build(BuildContext context) {
    // TODO
    return GradientScaffold(
      hasBackButton: true,
      backgroundGradient: _backgroundGradient,
      child: SizedBox.expand(
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
      ),
    );
  }
}
