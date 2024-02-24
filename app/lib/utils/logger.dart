import "package:logger/logger.dart";

Logger logger = Logger(
  filter: null,
  printer: SimplePrinter(colors: false),
  output: null,
  level: Level.trace,
);
