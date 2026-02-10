part of 'logger.dart';

typedef LogFormatter = String Function(
  LogLevel level,
  String package,
  String? source,
  String message,
  Object? error,
  StackTrace stackTrace,
);

typedef LogPrinter = void Function(String text);

final class LevelLogger {
  final Logger _logger;
  final LogLevel _level;

  LogFormatter _formatter = Logger.buildDefaultMessage;
  LogPrinter? _printer = Logger.defaultPrinter;

  LevelLogger(this._logger, this._level);

  // ignore: avoid_setters_without_getters
  set format(LogFormatter formatter) {
    _formatter = formatter;
  }

  // ignore: avoid_setters_without_getters
  set print(LogPrinter? printer) {
    _printer = printer;
  }

  void _log(
    Object? source,
    Object? message, [
    Object? error,
    StackTrace stackTrace = StackTrace.empty,
  ]) {
    final text = _formatter(
      _level,
      _logger.package,
      Logger.objToString(source),
      Logger.objToString(message) ?? 'null',
      error,
      stackTrace,
    );
    _printer?.call(text);
  }
}
