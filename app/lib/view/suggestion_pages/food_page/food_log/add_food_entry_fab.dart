import "dart:ui";

import "package:activ8/managers/food_manager.dart";
import "package:activ8/shorthands/blur_under.dart";
import "package:activ8/shorthands/padding.dart";
import "package:activ8/types/food/menu.dart";
import "package:activ8/view/suggestion_pages/food_page/food_log/edit_food_log_entry_page.dart";
import "package:flutter/material.dart";

class AddFoodEntryFAB extends StatelessWidget {
  final Function()? refresh;

  const AddFoodEntryFAB({super.key, this.refresh});

  Future<void> _addFoodLogAction(context) async {
    final FoodLogEntry? entry = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      // Prevent the user from dismissing outside of the "back" button, which messes up return values
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: const FractionallySizedBox(
            heightFactor: 0.85,
            child: ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              child: EditFoodLogEntryPage(isEditing: false),
            ),
          ),
        );
      },
    );

    // If a new entry is to be added
    if (entry != null) {
      FoodManager.instance.addFoodLogEntry(entry);
      if (refresh != null) refresh!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "AddFoodEntryFAB",
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BlurUnder(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async => await _addFoodLogAction(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: Colors.white.withOpacity(0.12),
                  border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: Theme.of(context).floatingActionButtonTheme.iconSize,
                    ),
                    padding(4),
                    Text(
                      "Add Food Log Entry",
                      style: Theme.of(context).floatingActionButtonTheme.extendedTextStyle,
                    ),
                    padding(2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
