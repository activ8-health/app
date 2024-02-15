import 'package:activ8/managers/api/v1/get_home_view.dart';
import 'package:activ8/view/home_page/home_view/lifestyle_score_content.dart';
import 'package:flutter/material.dart';

class LifestyleScoreWidget extends StatelessWidget {
  final Future<V1GetHomeViewResponse> homeViewResponse;

  const LifestyleScoreWidget({super.key, required this.homeViewResponse});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: homeViewResponse,
      builder: (BuildContext context, AsyncSnapshot<V1GetHomeViewResponse> snapshot) {
        Widget lifestyleScoreWidget;

        // Loading
        if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
          lifestyleScoreWidget = const LifestyleScoreContent();
        } else {
          // Interpret data
          V1GetHomeViewResponse response = snapshot.data!;
          if (response.status.isSuccessful) {
            lifestyleScoreWidget = LifestyleScoreContent(
              fitnessScore: response.fitnessScore,
            );
          } else {
            lifestyleScoreWidget = const LifestyleScoreContent();
          }
        }

        // Craft widget
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: lifestyleScoreWidget,
        );
      },
    );
  }
}
