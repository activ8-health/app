import 'package:activ8/managers/api/v1/get_home_view.dart';
import 'package:activ8/view/home_page/home_view/lifestyle_score_content.dart';
import 'package:activ8/view/widgets/clear_card.dart';
import 'package:flutter/material.dart';

class LifestyleScoreWidget extends StatelessWidget {
  final Future<V1GetHomeViewResponse> homeViewResponse;

  const LifestyleScoreWidget({super.key, required this.homeViewResponse});

  @override
  Widget build(BuildContext context) {
    return ClearCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: FutureBuilder(
          future: homeViewResponse,
          builder: (BuildContext context, AsyncSnapshot<V1GetHomeViewResponse> snapshot) {
            // Loading
            if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
              return const LifestyleScoreContent();
            }
            // Interpret data
            V1GetHomeViewResponse response = snapshot.data!;

            // Error
            if (!response.status.isSuccessful) {
              return const LifestyleScoreContent();
            }

            // Success
            return LifestyleScoreContent(fitnessScore: response.fitnessScore);
          },
        ),
      ),
    );
  }
}
