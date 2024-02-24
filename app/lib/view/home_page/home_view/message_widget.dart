import "package:activ8/extensions/snapshot_loading.dart";
import "package:activ8/managers/api/v1/get_home_view.dart";
import "package:activ8/shorthands/padding.dart";
import "package:activ8/view/widgets/clear_card.dart";
import "package:flutter/material.dart";

class MessageWidget extends StatelessWidget {
  final Future<V1GetHomeViewResponse> homeViewResponse;

  const MessageWidget({super.key, required this.homeViewResponse});

  Widget _getWidget(AsyncSnapshot<V1GetHomeViewResponse> snapshot) {
    // Loading
    if (snapshot.isLoading) {
      return const SizedBox(height: 0, child: SizedBox.expand());
    }

    // Interpret data
    final V1GetHomeViewResponse response = snapshot.data!;

    // Error
    if (!response.status.isSuccessful || response.message == null) {
      return const SizedBox(height: 0, child: SizedBox.expand());
    }

    // Success
    return ClearCard(
      color: Colors.orange.shade400,
      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 10.0, right: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.eco_sharp,
            size: 36,
            color: Colors.orange.shade100,
          ),
          padding(4),
          Expanded(
            child: Text(
              response.message!,
              style: TextStyle(color: Colors.orange.shade50),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: homeViewResponse,
      builder: (BuildContext context, AsyncSnapshot<V1GetHomeViewResponse> snapshot) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuart,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            child: _getWidget(snapshot),
          ),
        );
      },
    );
  }
}
