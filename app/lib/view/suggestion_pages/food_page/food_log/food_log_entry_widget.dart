import "package:activ8/extensions/date_time_day_utils.dart";
import "package:activ8/managers/food_manager.dart";
import "package:activ8/shorthands/padding.dart";
import "package:activ8/types/food/menu.dart";
import "package:activ8/view/suggestion_pages/food_page/food_log/edit_food_log_entry_page.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:intl/intl.dart";

class FoodLogEntryWidget extends StatelessWidget {
  final FoodLogEntry foodLogEntry;
  final bool showDate;
  final Function()? refresh;

  const FoodLogEntryWidget({super.key, required this.foodLogEntry, this.showDate = true, this.refresh});

  Future<void> openEditAction(context) async {
    final FoodLogEntry? entry = await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return EditFoodLogEntryPage(sourceEntry: foodLogEntry);
    }));

    if (entry == foodLogEntry) return;
    FoodManager.instance.removeFoodLogEntry(foodLogEntry);

    if (entry != null) {
      FoodManager.instance.addFoodLogEntry(entry);
    }

    if (refresh != null) refresh!();
  }

  @override
  Widget build(BuildContext context) {
    final String foodName = foodLogEntry.item.name;
    final int calories = foodLogEntry.item.calories;

    final double servings = foodLogEntry.servings;
    final int logRating = foodLogEntry.rating;
    final DateTime date = foodLogEntry.date;

    return InkWell(
      onTap: () async => await openEditAction(context),
      child: SizedBox(
        height: 80,
        child: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _getHeader(context, foodName, servings, logRating),
                padding(1),
                _getDescription(date, calories, servings),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Combines the title/servings with the rating
  Widget _getHeader(BuildContext context, String foodName, double servings, int logRating) {
    return Row(
      children: [
        Expanded(child: _getTitleAndServings(context, foodName, servings)),
        padding(8),
        _getRating(logRating),
      ],
    );
  }

  /// Displays the food name and servings as "<food name> x <servings>"
  Widget _getTitleAndServings(BuildContext context, String foodName, double servings) {
    final Widget title = Text(
      foodName,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final bool shouldTruncateServings = servings.truncateToDouble() == servings;
    final Widget servingsText = Text(
      servings.toStringAsFixed(shouldTruncateServings ? 0 : 1),
      style: GoogleFonts.poppins(
        color: Colors.white.withOpacity(0.6),
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );

    return Row(
      children: [
        // Title
        Flexible(child: title),
        padding(3),

        // Cross Icon
        Icon(Icons.close, size: 16, color: Colors.white.withOpacity(0.8)),
        padding(4),

        // Serving Size
        servingsText,
      ],
    );
  }

  /// Displays the rating with a star icon
  Widget _getRating(int rating) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rating.toString(), style: GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
        const Padding(padding: EdgeInsets.only(left: 2)),
        Icon(Icons.star_rate, size: 25, color: Colors.white.withOpacity(0.6)),
      ],
    );
  }

  /// Displays the date/time and calories as a subtitle
  Widget _getDescription(DateTime date, int calories, double servings) {
    final NumberFormat decimalFormatter = NumberFormat.decimalPattern();

    return Row(
      children: [
        (showDate) ? _getDate(date) : _getTime(date),

        // Padding
        const Expanded(child: SizedBox.shrink()),

        // Calories
        Text(
          "${decimalFormatter.format(calories * servings)} cal",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  /// Only used when [showDate] is true
  Widget _getDate(DateTime date) {
    // Special case for Today
    final DateTime today = DateTime.now();
    if (date.isSameDay(today)) {
      return Text(
        "Today",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8)),
      );
    }

    // Special case for Yesterday
    final DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (date.isSameDay(yesterday)) {
      return Text(
        "Yesterday",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8)),
      );
    }

    return Row(
      children: [
        // Day of the week
        Text(
          DateFormat.EEEE().format(DateTime.now()),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8)),
        ),
        padding(4),

        // Date
        Text(
          DateFormat.yMd().format(DateTime.now()),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.6)),
        ),
      ],
    );
  }

  /// Only used when [showDate] is false
  Widget _getTime(DateTime date) {
    return Text(
      DateFormat.jm().format(date),
      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.6)),
    );
  }
}
