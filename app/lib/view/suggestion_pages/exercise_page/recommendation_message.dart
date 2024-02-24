import 'package:activ8/managers/api/v1/get_activity_recommendation.dart';
import 'package:activ8/view/widgets/clear_card.dart';
import 'package:activ8/view/widgets/shorthand.dart';
import 'package:flutter/material.dart';

class RecommendationMessage extends StatelessWidget {
  final Future<V1GetActivityRecommendationResponse> activityRecommendationFuture;

  const RecommendationMessage({super.key, required this.activityRecommendationFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: activityRecommendationFuture,
      builder: (BuildContext context, AsyncSnapshot<V1GetActivityRecommendationResponse> snapshot) {
        // Loading
        if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
          return const _Widget();
        }
        // Interpret data
        V1GetActivityRecommendationResponse response = snapshot.data!;

        // Error
        if (!response.status.isSuccessful) {
          return const _Widget();
        }

        // Success
        return _Widget(message: response.message);
      },
    );
  }
}

class _Widget extends StatelessWidget {
  final String? message;

  const _Widget({this.message});

  @override
  Widget build(BuildContext context) {
    String message = this.message ?? "Loading...";

    return ClearCard(
      color: Colors.orange.shade400,
      child: Padding(
        padding: const EdgeInsets.only(top: 14.0, bottom: 16.0, left: 10.0, right: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Icon(
                Icons.lightbulb,
                size: 28,
                color: Colors.orange.shade500,
              ),
            ),
            padding(4),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.orange.shade50, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
