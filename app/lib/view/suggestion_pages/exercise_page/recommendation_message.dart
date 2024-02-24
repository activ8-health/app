import 'package:activ8/view/widgets/clear_card.dart';
import 'package:activ8/view/widgets/shorthand.dart';
import 'package:flutter/material.dart';

class RecommendationMessage extends StatefulWidget {
  const RecommendationMessage({super.key});

  @override
  State<RecommendationMessage> createState() => _RecommendationMessageState();
}

class _RecommendationMessageState extends State<RecommendationMessage> {
  @override
  Widget build(BuildContext context) {
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
                "Remember to get in your steps today. You still have 11000 steps left until you reach your step goal. It might be chilly today, so make sure to wear more when going for a run outside.",
                style: TextStyle(color: Colors.orange.shade50, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
