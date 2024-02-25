abstract class IStatus {
  bool get isSuccessful;
}

abstract class IResponse {
  IStatus get status;

  String? get errorMessage;
}

abstract class IBody {}
