import "package:activ8/shorthands/padding.dart";
import "package:activ8/types/food/menu.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:intl/intl.dart";

class FoodLogEntryWidget extends StatelessWidget {
  final FoodLogEntry foodLogItem;

  const FoodLogEntryWidget({super.key, required this.foodLogItem});

  void openEditAction() {
    // TODO open edit action
  }

  @override
  Widget build(BuildContext context) {
    final String foodName = foodLogItem.item.name;
    final int calories = foodLogItem.item.calories;

    final double servingSize = foodLogItem.servingSize;
    final int logRating = foodLogItem.rating;
    final DateTime date = foodLogItem.date;

    final NumberFormat decimalFormatter = NumberFormat.decimalPattern();

    return InkWell(
      onTap: openEditAction,
      child: SizedBox(
        height: 80,
        child: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _getHeading(context, foodName, servingSize)),

                    // Emergency Padding
                    padding(8),

                    _getRating(logRating),
                  ],
                ),
                padding(1),
                Row(
                  children: [
                    _getDate(date),

                    // Padding
                    const Expanded(child: SizedBox.shrink()),

                    // Calories
                    Text(
                      "${decimalFormatter.format(calories)} cal",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getHeading(BuildContext context, String foodName, double servingSize) {
    return Row(
      children: [
        // Title
        Flexible(child: _getTitle(context, foodName)),
        padding(3),

        // Cross Icon
        Icon(Icons.close, size: 16, color: Colors.white.withOpacity(0.8)),
        padding(4),

        // Serving Size
        _getServingSize(servingSize),
      ],
    );
  }

  Widget _getTitle(context, String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _getServingSize(double servingSize) {
    final bool shouldTruncate = servingSize.truncateToDouble() == servingSize;

    return Text(
      servingSize.toStringAsFixed(shouldTruncate ? 0 : 1),
      style: GoogleFonts.poppins(
        color: Colors.white.withOpacity(0.6),
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

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

  Widget _getDate(DateTime date) {
    // Special case for Today
    final DateTime now = DateTime.now();
    if (now.day == date.day && now.month == date.month && now.year == date.year) {
      return Text(
        "Today",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8)),
      );
    }

    // Special case for Yesterday
    final DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (yesterday.day == date.day && yesterday.month == date.month && yesterday.year == date.year) {
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
}
