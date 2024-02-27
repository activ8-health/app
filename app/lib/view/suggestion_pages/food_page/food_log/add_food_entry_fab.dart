import "package:activ8/shorthands/padding.dart";
import "package:flutter/material.dart";

class AddFoodEntryFAB extends StatelessWidget {
  const AddFoodEntryFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "AddFoodEntryFAB",
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: () {
                // TODO go to food log adding page
              },
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
              )),
        ),
      ),
    );
  }
}
