import "package:activ8/constants.dart";
import "package:activ8/extensions/date_time_day_utils.dart";
import "package:activ8/managers/food_manager.dart";
import "package:activ8/shorthands/blur_under.dart";
import "package:activ8/shorthands/gradient_scaffold.dart";
import "package:activ8/shorthands/padding.dart";
import "package:activ8/types/food/menu.dart";
import "package:activ8/view/suggestion_pages/food_page/shared.dart";
import "package:activ8/view/widgets/custom_text_field.dart";
import "package:flutter/material.dart";
import "package:flutter_rating_bar/flutter_rating_bar.dart";
import "package:intl/intl.dart";

/// ON POP: Returns a NULLABLE [FoodLogEntry] object
///
/// Edit:
///   Cancel -> source entry
///   Save -> new entry
///   Delete -> null
/// Add:
///   Cancel -> null
///   Add -> new entry
class EditFoodLogEntryPage extends StatefulWidget {
  final FoodLogEntry? sourceEntry;
  final bool isEditing;

  const EditFoodLogEntryPage({super.key, this.sourceEntry, required this.isEditing});

  @override
  State<EditFoodLogEntryPage> createState() => _EditFoodLogEntryPageState();
}

class _EditFoodLogEntryPageState extends State<EditFoodLogEntryPage> {
  // Fields to fill
  late FoodMenuItem? item = widget.sourceEntry?.item;
  late DateTime date = widget.sourceEntry?.date ?? DateTime.now();
  late double? servings = widget.sourceEntry?.servings ?? 1.0;
  late int rating = widget.sourceEntry?.rating ?? defaultRatingStars;

  bool get isComplete => item != null && servings != null;

  void save() {
    Navigator.pop(
      context,
      FoodLogEntry(
        item: item!,
        date: date,
        servings: servings!,
        rating: rating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String appBarTitle = (widget.isEditing) ? "Edit Food Log Entry" : "Add Food Log Entry";

    return GestureDetector(
      // Allow tapping outside to dismiss keyboard
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: GradientScaffold(
        title: Text(appBarTitle),
        hasBackButton: true,
        backIcon: const Icon(Icons.close_rounded, size: 32),
        onBack: () {
          if (widget.isEditing) {
            Navigator.pop(context, widget.sourceEntry);
          } else {
            Navigator.pop(context, null);
          }
        },
        backgroundGradient: backgroundGradient,
        child: SizedBox(
          width: 370,
          child: ListView(
            children: [
              padding(12),

              // Food Item Selector
              _createFoodItemSelector(),
              padding(12),

              // Date and Time Picker
              Row(
                children: [
                  Flexible(child: _createDatePicker()),
                  padding(6),
                  SizedBox(
                    width: 150,
                    child: _createTimePicker(),
                  ),
                ],
              ),
              padding(8),

              // Servings and Rating
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 100, child: _createServingInput()),
                  _createRatingInput(),
                ],
              ),
              padding(16),

              // Action Row (Save/Delete)
              _createActionRow(),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates a dropdown input field to select food item
  Widget _createFoodItemSelector() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Autocomplete<FoodMenuItem>(
          optionsBuilder: (TextEditingValue value) => FoodManager.instance.searchFoodItems(value.text),
          onSelected: (FoodMenuItem item) {
            this.item = item;
            setState(() {});
          },
          displayStringForOption: (FoodMenuItem item) => item.name,
          initialValue: TextEditingValue(text: item?.name ?? ""),
          optionsViewBuilder: (context, onSelected, items) {
            final double width = constraints.maxWidth;
            return _buildOptionDropdown(context, onSelected, items, width);
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextFormField(
              decoration: createInputDecoration(context, "Food").copyWith(
                hintText: "What did you eat?",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    item = null;
                  },
                ),
              ),
              onEditingComplete: onFieldSubmitted,
              controller: controller,
              focusNode: focusNode,
            );
          },
        );
      },
    );
  }

  /// The dropdown that displays options
  Widget _buildOptionDropdown(
    BuildContext context,
    Function(FoodMenuItem) onSelected,
    Iterable<FoodMenuItem> items,
    double width,
  ) {
    final List<FoodMenuItem> menuItems = items.toList();

    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: width,
        child: BlurUnder(
          strength: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.0).copyWith(topLeft: Radius.zero, topRight: Radius.zero),
            child: Material(
              color: Colors.white.withOpacity(0.1),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: menuItems.length,
                itemBuilder: (context, index) => _buildOption(context, onSelected, menuItems[index]),
                separatorBuilder: (BuildContext context, int index) => Divider(
                  color: Colors.white.withOpacity(0.3),
                  thickness: 1,
                  height: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Each option inside the dropdown
  Widget _buildOption(BuildContext context, Function(FoodMenuItem) onSelected, FoodMenuItem item) {
    final NumberFormat decimalFormatter = NumberFormat.decimalPattern();

    return InkWell(
      onTap: () => onSelected(item),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis)),
            Text(
              "${decimalFormatter.format(item.calories)} cal",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates a date picker input field
  Widget _createDatePicker() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          // Open date picker
          final DateTime? newDate = await showDatePicker(
            context: context,
            firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)), // 10 years back
            lastDate: DateTime.now().add(const Duration(days: 1)), // 1 day ahead
            initialDate: date,
          );

          // Update date
          if (newDate != null) {
            date = date.copyWith(year: newDate.year, month: newDate.month, day: newDate.day);
          }

          setState(() {});
        },
        child: InputDecorator(
          decoration: createInputDecoration(context, "Date"),
          child: Text(DateFormat.yMMMEd().format(date)),
        ),
      ),
    );
  }

  /// Creates a time picker input field
  Widget _createTimePicker() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          // Open date picker
          final TimeOfDay? newTime = await showTimePicker(
            context: context,
            initialTime: date.extractTime(),
          );

          // Update date
          if (newTime != null) {
            date = date.copyWith(hour: newTime.hour, minute: newTime.minute);
          }

          setState(() {});
        },
        child: InputDecorator(
          decoration: createInputDecoration(context, "Time"),
          child: Text(DateFormat.jm().format(date)),
        ),
      ),
    );
  }

  /// Creates a serving text input field
  _createServingInput() {
    return TextFormField(
      decoration: createInputDecoration(context, "Servings").copyWith(errorMaxLines: 2),
      initialValue: servings.toString(),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      autovalidateMode: AutovalidateMode.always,
      validator: (String? text) {
        final double? value = double.tryParse(text ?? "");
        if (value == null) return "Invalid number";
        if (value < 0.1 || value > 10.0) return "Between 0.1 to 10.0";
        return null;
      },
      onChanged: (String value) {
        servings = double.tryParse(value);
        if (servings != null) {
          // Truncate (or round) to 1 decimal place
          servings = double.parse(servings!.toStringAsFixed(1));
        }
        setState(() {});
      },
    );
  }

  /// Creates a rating input field as selectable stars
  Widget _createRatingInput() {
    return Column(
      children: [
        Text("How did you enjoy your meal?", style: TextStyle(color: Colors.white.withOpacity(0.9))),
        RatingBar(
          initialRating: rating.toDouble(),
          direction: Axis.horizontal,
          allowHalfRating: false,
          glow: false,
          itemCount: 5,
          ratingWidget: RatingWidget(
            full: const Icon(Icons.star_rate),
            half: const Icon(Icons.star_rate_outlined),
            empty: Icon(
              Icons.star_outline,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          onRatingUpdate: (rating) => this.rating = rating.toInt(),
          minRating: 1,
        ),
      ],
    );
  }

  /// Creates the action row with options to delete or save
  Widget _createActionRow() {
    return Row(
      children: [
        if (widget.isEditing)
          TextButton.icon(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => Navigator.pop(context, null),
            label: const Text("Delete"),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade200),
          ),
        Expanded(child: Container()),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.12),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.white.withOpacity(0.6), width: 1),
            ),
          ),
          onPressed: !isComplete ? null : save,
          child: Text(widget.isEditing ? "Save" : "Add"),
        ),
      ],
    );
  }
}
