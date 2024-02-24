import "package:activ8/extensions/snapshot_loading.dart";
import "package:activ8/managers/api/v1/get_activity_recommendation.dart";
import "package:activ8/shorthands/padding.dart";
import "package:activ8/view/widgets/clear_card.dart";
import "package:flutter/material.dart";

class RecommendationMessage extends StatelessWidget {
  final Future<V1GetActivityRecommendationResponse> activityRecommendationFuture;

  const RecommendationMessage({super.key, required this.activityRecommendationFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: activityRecommendationFuture,
      builder: (BuildContext context, AsyncSnapshot<V1GetActivityRecommendationResponse> snapshot) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _getWidget(snapshot),
        );
      },
    );
  }

  Widget _getWidget(AsyncSnapshot<V1GetActivityRecommendationResponse> snapshot) {
    // Loading
    if (snapshot.isLoading) {
      return const _Widget(key: ValueKey(1));
    }

    // Interpret data
    final V1GetActivityRecommendationResponse response = snapshot.data!;

    // Error
    if (!response.status.isSuccessful) {
      return const _Widget(key: ValueKey(1));
    }

    // Success
    return _Widget(key: const ValueKey(0), message: response.message);
  }
}

class _Widget extends StatelessWidget {
  final String? message;

  const _Widget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final String message = this.message ?? "Loading...";

    return ClearCard(
      color: Colors.orange.shade400,
      padding: const EdgeInsets.only(top: 14.0, bottom: 16.0, left: 10.0, right: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Icon(
              Icons.lightbulb,
              size: 36,
              color: Colors.orange.shade500,
            ),
          ),
          padding(4),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Color.alphaBlend(Colors.orange.shade50.withOpacity(0.5), Colors.white),
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
