import 'package:logger/logger.dart';

var logger = Logger(
  filter: null,
  printer: SimplePrinter(colors: false),
  output: null,
  level: Level.trace,
);
