import "package:activ8/extensions/date_time_day_utils.dart";
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
    // Sort headers
    final List<DateTime> dates = logByDate.keys.toList().sorted((a, b) => b.compareTo(a));

    return GradientScaffold(
      title: const Text("Food Log"),
      floatingActionButton: AddFoodEntryFAB(refresh: () => setState(() {})),
      hasBackButton: true,
      backgroundGradient: backgroundGradient,
      child: _allowRefresh(
        child: ListView(
          // For padding
          children: [
            // The whole list
            ListView.separated(
              itemCount: dates.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                // Calculate features for the group (date)
                final DateTime date = dates[index];
                final List<FoodLogEntry> logSubset = logByDate[date]!;

                return _createLogSection(context, date, logSubset);
              },
              separatorBuilder: (_, __) => padding(16),
            ),

            // Bottom padding to prevent the FAB from cutting off items
            padding(52),
          ],
        ),
      ),
    );
  }

  Widget _allowRefresh({required Widget child}) {
    return Align(
      alignment: Alignment.topCenter,
      child: RefreshIndicator(
        color: Colors.white,
        displacement: 80,
        backgroundColor: Colors.white.withOpacity(0.2),
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

  /// One section of the food log under one day
  Widget _createLogSection(BuildContext context, DateTime date, List<FoodLogEntry> logs) {
    String label = DateFormat.yMMMMEEEEd().format(date);
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
            itemBuilder: (BuildContext context, int index) {
              return FoodLogEntryWidget(
                foodLogEntry: logs[index],
                showDate: false,
                refresh: () => setState(() {}),
              );
            },
            separatorBuilder: (_, __) => const ClearCardDivider(),
            itemCount: logs.length,
          ),
        ),
      ],
    );
  }
}
