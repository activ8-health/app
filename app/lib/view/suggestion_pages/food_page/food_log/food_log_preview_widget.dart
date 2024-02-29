import "dart:math";

import "package:activ8/managers/food_manager.dart";
import "package:activ8/shorthands/padding.dart";
import "package:activ8/types/food/menu.dart";
import "package:activ8/view/suggestion_pages/food_page/food_log/food_log_entry_widget.dart";
import "package:activ8/view/suggestion_pages/food_page/food_log/food_log_page.dart";
import "package:activ8/view/widgets/clear_card.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

// Shows 3 most recent food items
class FoodLogPreviewWidget extends StatelessWidget {
  final int numberToDisplay;
  final Function()? refresh;

  const FoodLogPreviewWidget({super.key, this.numberToDisplay = 3, this.refresh});

  void _seeFoodLogAction(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => const FoodLogPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<FoodLogEntry> foodLog = FoodManager.instance.log;
    final int stopIndex = min(numberToDisplay, foodLog.length);
    final Iterable<FoodLogEntry> items = foodLog.sublist(0, stopIndex);

    return ClearCard(
      child: Column(
        children: [
          for (FoodLogEntry item in items) ...[
            FoodLogEntryWidget(foodLogEntry: item, refresh: refresh),
            if (item != items.last) const ClearCardDivider(),
          ],

          // Show notice if food log is empty
          if (foodLog.isEmpty) _createEmptyFoodLogNotice(),

          // Show the See More button if there is more to see
          if (stopIndex != foodLog.length) ...[
            const ClearCardDivider(),
            _createSeeMoreButton(context),
          ],
        ],
      ),
    );
  }

  Widget _createSeeMoreButton(BuildContext context) {
    return InkWell(
      onTap: () => _seeFoodLogAction(context),
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

  Widget _createEmptyFoodLogNotice() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RichText(
            text: TextSpan(
              children: const [
                TextSpan(text: "Your food log is empty. Tap the"),
                WidgetSpan(child: Icon(Icons.add)),
                TextSpan(text: "button at the bottom to get started."),
              ],
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
