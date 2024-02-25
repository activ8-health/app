import "package:activ8/extensions/snapshot_loading.dart";
import "package:activ8/managers/api/interfaces.dart";
import "package:flutter/cupertino.dart";

Widget futureWidgetSelector<T extends IResponse>(
  AsyncSnapshot<T> snapshot, {
  required Widget Function(T) successWidgetBuilder,
  required Widget failureWidget,
}) {
  // Handle Loading
  if (snapshot.isLoading) return failureWidget;

  // Extract data
  final T response = snapshot.data!;

  // Handle Error
  if (!response.status.isSuccessful) return failureWidget;

  // Success
  return successWidgetBuilder(response);
}
