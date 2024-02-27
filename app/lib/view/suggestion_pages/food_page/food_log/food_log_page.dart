import "package:activ8/extensions/date_time_same_day.dart";
import "package:activ8/managers/food_manager.dart";
import "package:activ8/shorthands/gradient_scaffold.dart";
import "package:activ8/shorthands/padding.dart";
import "package:activ8/types/food/menu.dart";
import "package:activ8/view/suggestion_pages/food_page/food_log/add_food_entry_fab.dart";
import "package:activ8/view/suggestion_pages/food_page/food_log/food_log_entry_widget.dart";
import "package:activ8/view/suggestion_pages/food_page/shared.dart";
import "package:activ8/view/widgets/category_marker.dart";
import "package:activ8/view/widgets/clear_card.dart";
import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

class FoodLogPage extends StatefulWidget {
  const FoodLogPage({super.key});

  @override
  State<FoodLogPage> createState() => _FoodLogPageState();
}

class _FoodLogPageState extends State<FoodLogPage> {
  @override
  Widget build(BuildContext context) {
    // Prepare food log items, grouped by date
    final List<FoodLogEntry> foodLog = FoodManager.instance.log;
    final Map<DateTime, List<FoodLogEntry>> logByDate = foodLog.groupListsBy((entry) => entry.date.extractDate());
    final List<DateTime> dates = logByDate.keys.toList().sorted((a, b) => b.compareTo(a));

    return GradientScaffold(
      title: const Text("Food Log"),
      floatingActionButton: const AddFoodEntryFAB(),
      hasBackButton: true,
      backgroundGradient: backgroundGradient,
      child: _allowRefresh(
        child: ListView.separated(
          itemCount: dates.length,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            // Calculate features for the group (date)
            final DateTime date = dates[index];
            final List<FoodLogEntry> logSubset = logByDate[date]!;

            String label = DateFormat.EEEE().add_yMd().format(date);
            if (DateTime.now().isSameDay(date)) label = "Today";
            if (DateTime.now().subtract(const Duration(days: 1)).isSameDay(date)) label = "Yesterday";

            return Column(
              children: [
                // Date
                CategoryMarker(label: label),

                // Section
                ClearCard(
                  child: ListView.separated(
                    // because nested
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index2) {
                      return FoodLogEntryWidget(foodLogEntry: logSubset[index2], showDate: false);
                    },
                    separatorBuilder: (_, __) => const ClearCardDivider(),
                    itemCount: logSubset.length,
                  ),
                ),
              ],
            );
          },
          separatorBuilder: (_, __) => padding(16),
        ),
      ),
    );
  }

  Widget _allowRefresh({required Widget child}) {
    return Align(
      alignment: Alignment.topCenter,
      child: RefreshIndicator(
        displacement: 80,
        backgroundColor: Colors.white.withOpacity(0.2),
        color: Colors.white,
        onRefresh: () async => setState(() {}),
        child: SizedBox(
          width: 370,
          child: SizedBox.expand(
            child: child,
          ),
        ),
      ),
    );
  }
}
