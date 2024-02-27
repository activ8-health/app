import "dart:math";

import "package:activ8/constants.dart";
import "package:activ8/managers/food_manager.dart";
import "package:activ8/shorthands/padding.dart";
import "package:activ8/types/food/menu.dart";
import "package:activ8/view/suggestion_pages/food_page/food_log/entry.dart";
import "package:activ8/view/widgets/clear_card.dart";
import "package:flutter/material.dart";

// Shows 3 most recent food items
class FoodLogPreviewWidget extends StatelessWidget {
  final int numberToDisplay;

  const FoodLogPreviewWidget({super.key, this.numberToDisplay = 3});

  @override
  Widget build(BuildContext context) {
    final int startIndex = max(0, FoodManager.instance.log.length - numberToDisplay);
    final Iterable<FoodLogEntry> items = FoodManager.instance.log.sublist(startIndex).reversed;

    return ClearCard(
      child: ClipRRect(
        borderRadius: homeCardBorderRadius,
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              for (FoodLogEntry item in items) ...[
                FoodLogEntryWidget(foodLogItem: item),
                const ClearCardDivider(),
              ],
              _createSeeMoreButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createSeeMoreButton() {
    return InkWell(
      onTap: () {
        // TODO go to food log page
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            const Expanded(child: SizedBox.shrink()),
            const Text(
              "See older food log items",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            padding(4),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
