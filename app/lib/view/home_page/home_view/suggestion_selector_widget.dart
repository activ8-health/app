import "package:activ8/constants.dart";
import "package:activ8/shorthands/padding.dart";
import "package:activ8/view/suggestion_pages/exercise_page/exercise_page.dart";
import "package:activ8/view/suggestion_pages/food_page/food_page.dart";
import "package:activ8/view/suggestion_pages/sleep_page/sleep_page.dart";
import "package:activ8/view/widgets/clear_card.dart";
import "package:flutter/material.dart";

const double _indent = 15;

class SuggestionSelectorWidget extends StatelessWidget {
  const SuggestionSelectorWidget({super.key});

  Widget get _divider => Divider(
        color: Colors.white.withOpacity(0.6),
        thickness: 1,
        indent: _indent,
        height: 0,
        endIndent: _indent,
      );

  @override
  Widget build(BuildContext context) {
    return ClearCard(
      child: ClipRRect(
        borderRadius: homeCardBorderRadius,
        child: Material(
          color: Colors.transparent,
          child: Column(children: [
            _SuggestionEntry(
              title: const Text("Food"),
              description: const Text("Get your energy for the day"),
              icon: const Icon(Icons.restaurant_menu),
              action: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FoodPage(),
                  ),
                );
              },
            ),
            _divider,
            _SuggestionEntry(
              title: const Text("Exercise"),
              description: const Text("Never a bad idea to get moving"),
              icon: const Icon(Icons.directions_run),
              action: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ExercisePage(),
                  ),
                );
              },
            ),
            _divider,
            _SuggestionEntry(
              title: const Text("Sleep"),
              description: const Text("Happy days start with happy sleep"),
              icon: const Icon(Icons.bedtime_outlined),
              action: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SleepPage(),
                  ),
                );
              },
            ),
          ]),
        ),
      ),
    );
  }
}

class _SuggestionEntry extends StatelessWidget {
  final Widget title;
  final Widget description;
  final Icon icon;
  final Function() action;

  const _SuggestionEntry({
    required this.title,
    required this.description,
    required this.icon,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action,
      child: SizedBox(
        height: 80,
        child: Row(
          children: [
            padding(_indent / 2 + 3),
            IconTheme(
              data: const IconThemeData(size: 32, color: Colors.white),
              child: icon,
            ),
            padding(6),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleLarge!,
                    child: title,
                  ),
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.bodySmall!,
                    child: description,
                  ),
                ],
              ),
            ),
            padding(4),
            Icon(Icons.chevron_right_rounded, size: 32, color: Colors.white.withOpacity(0.8)),
            padding(_indent / 2 + 3),
          ],
        ),
      ),
    );
  }
}
