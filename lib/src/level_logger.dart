part of 'logger.dart';

/// Formats a log message.
///
/// [level] is the log level.
/// [package] is the name of the package.
/// [source] is the source of the log message.
/// [message] is the log message.
/// [error] is the error object.
/// [stackTrace] is the stack trace.
typedef LogFormatter = String Function(
  LogLevel level,
  String package,
  String? source,
  String message,
  Object? error,
  StackTrace stackTrace,
);

/// Prints a log message.
typedef LogPrinter = void Function(String text);

/// Logger for a specific [LogLevel].
final class LevelLogger {
  final Logger _logger;
  final LogLevel _level;

  LogFormatter _formatter = Logger.buildDefaultMessage;
  LogPrinter? _printer = Zone.current.print;

  /// Creates a new [LevelLogger].
  LevelLogger._(this._logger, this._level);

  /// Sets the log formatter.
  // ignore: avoid_setters_without_getters
  set format(LogFormatter formatter) {
    _formatter = formatter;
  }

  /// Sets the log printer.
  // ignore: avoid_setters_without_getters
  set print(LogPrinter? printer) {
    _printer = printer;
  }

  bool _log(
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

    return true;
  }
}
