import "package:activ8/managers/api/v1/get_activity_recommendation.dart";
import "package:activ8/shorthands/padding.dart";
import "package:activ8/utils/future_widget_selector.dart";
import "package:activ8/view/widgets/clear_card.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:url_launcher/url_launcher_string.dart";

const String _articleLabel = "Physical Activity for a Healthy Weight";
const String _articleUrl = "https://www.cdc.gov/healthyweight/physical_activity/index.html";

class CaloriesMessage extends StatelessWidget {
  final Future<V1GetActivityRecommendationResponse> activityRecommendationFuture;

  const CaloriesMessage({super.key, required this.activityRecommendationFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: activityRecommendationFuture,
      builder: (BuildContext context, AsyncSnapshot<V1GetActivityRecommendationResponse> snapshot) {
        final Widget widget = futureWidgetSelector(
          snapshot,
          failureWidget: const _Widget(key: ValueKey(1)),
          successWidgetBuilder: (V1GetActivityRecommendationResponse response) {
            return _Widget(key: const ValueKey(0), caloriesBurned: response.caloriesBurned);
          },
        );

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: widget,
        );
      },
    );
  }
}

class _Widget extends StatelessWidget {
  final int? caloriesBurned;

  const _Widget({super.key, this.caloriesBurned});

  @override
  Widget build(BuildContext context) {
    return ClearCard(
      color: Colors.orange.shade200,
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, left: 10.0, right: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Icon(
              Icons.local_fire_department,
              size: 36,
              color: Colors.orange.shade300,
            ),
          ),
          padding(4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _getBurnedText(context, caloriesBurned),
                padding(12),
                _getReadMore(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getBurnedText(BuildContext context, [int? caloriesBurned]) {
    if (caloriesBurned == null) {
      return Text(
        "Loading...",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18),
      );
    }

    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(text: "You have burned "),
          TextSpan(
            text: caloriesBurned.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const TextSpan(text: " calories today!"),
        ],
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18),
      ),
    );
  }

  Widget _getReadMore(BuildContext context) {
    final TapGestureRecognizer readArticleTapRecognizer = TapGestureRecognizer();
    readArticleTapRecognizer.onTap = () => launchUrlString(_articleUrl);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "Read more from CDC: ",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.orange.shade100),
          ),
          TextSpan(
            text: _articleLabel,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Colors.orange.shade100, decoration: TextDecoration.underline),
            recognizer: readArticleTapRecognizer,
          ),
        ],
      ),
    );
  }
}
