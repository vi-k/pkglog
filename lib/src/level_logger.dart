part of 'logger.dart';

/// Formats a log message.
///
/// [level] is the log level.
/// [package] is the name of the package.
/// [source] is the source of the log message.
/// [message] is the log message.
/// [error] is the error object.
typedef LogFormatter = String Function(
  LogLevel level,
  String package,
  String? source,
  String message,
  LogError? error,
);

/// Prints a log message.
typedef LogPrinter = void Function(String text);

/// Logger for a specific [LogLevel].
///
/// Used for configuration:
///
/// ```dart
/// final log = Logger('my_package');
/// log[LogLevel.info] // <- LevelLogger
///   ..format = ...
///   ..print = ...;
/// ```
final class LevelLogger {
  final Logger _logger;
  final LogLevel _level;

  LogFormatter _formatter = Logger.buildDefaultMessage;
  LogPrinter? _printer = Zone.current.print;

  /// Creates a new [LevelLogger].
  LevelLogger._(this._logger, this._level);

  /// Sets the log formatter.
  ///
  /// ```dart
  /// // Use the default message formatter.
  /// log[LogLevel.debug].format = Logger.buildDefaultMessage;
  ///
  /// // Use a custom message formatter.
  /// log[LogLevel.debug].format = (level, package, source, message, error) {
  ///   return '${level.name.toUpperCase()}: $message';
  /// };
  /// ```
  // ignore: avoid_setters_without_getters
  set format(LogFormatter formatter) {
    _formatter = formatter;
  }

  /// Sets the log printer.
  ///
  /// ```dart
  /// // Use `print` by default.
  /// log[LogLevel.debug].print = print;
  ///
  /// // Use a custom log printer.
  /// log[LogLevel.error].print = stderr.writeln;
  /// log[LogLevel.shout].print = stderr.writeln;
  /// ```
  // ignore: avoid_setters_without_getters
  set print(LogPrinter? printer) {
    _printer = printer;
  }

  bool _log(
    Object? source,
    Object? message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    final text = _formatter(
      _level,
      _logger.package,
      Logger.objToString(source),
      Logger.objToString(message) ?? 'null',
      error == null
          ? null
          : LogError._(
              error,
              stackTrace ??
                  switch (error) {
                    Error(:final stackTrace?) => stackTrace,
                    _ => StackTrace.current,
                  },
            ),
    );
    _printer?.call(text);

    return true;
  }
}
