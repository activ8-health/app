import "package:flutter/cupertino.dart";

extension SnapshotLoading<T> on AsyncSnapshot<T> {
  bool get isLoading => connectionState != ConnectionState.done || !hasData;
}
