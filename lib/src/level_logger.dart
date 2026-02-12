part of 'logger.dart';

/// Formats a log message.
typedef LogFormatter = String Function(LogMessage context);

/// Prints a log message.
typedef LogPrinter = void Function(LogMessage context);

/// Logger for a specific [Level].
///
/// Used for configuration:
///
/// ```dart
/// final log = Logger('my_package');
/// log[Level.info] // <- LevelLogger
///   ..format = ...
///   ..print = ...;
/// ```
final class LevelLogger {
  final Level _level;

  /// Creates a new [LevelLogger].
  LevelLogger._(this._level);

  Logger? _logger;
  Logger get _requireLogger =>
      _logger ?? (throw StateError('Logger is not attached'));

  LogMessageBuilder _messageBuilder = LogMessage.new;

  LogFormatter? _formatter;

  LogPrinter? _printer = Logger.defaultPrinter;

  LogFunction _log = _noLog;
  LogFunction get log => _log;

  bool isEnabled(Level level) => !identical(_log, _noLog);

  void _toggle(bool enabled) {
    _log = enabled ? _realLog : _noLog;
  }

  /// Sets the context builder.
  // ignore: avoid_setters_without_getters
  set contextBuilder(LogMessageBuilder builder) {
    _messageBuilder = builder;
  }

  /// Sets the log formatter.
  ///
  /// ```dart
  /// // Use the default message formatter.
  /// log[Level.debug].format = Logger.buildDefaultMessage;
  ///
  /// // Use a custom message formatter.
  /// log[Level.debug].format = (level, package, source, message, error) {
  ///   return '${level.name.toUpperCase()}: $message';
  /// };
  /// ```
  // ignore: avoid_setters_without_getters
  set format(LogFormatter? formatter) {
    _formatter = formatter;
  }

  /// Sets the log printer.
  ///
  /// ```dart
  /// // Use `print` by default.
  /// log[Level.debug].print = print;
  ///
  /// // Use a custom log printer.
  /// log[Level.error].print = stderr.writeln;
  /// log[Level.critical].print = stderr.writeln;
  /// ```
  // ignore: avoid_setters_without_getters
  set print(LogPrinter? printer) {
    _printer = printer;
  }

  @pragma('vm:prefer-inline')
  static bool _noLog(
    Object? source,
    Object? message, [
    Object? error,
    StackTrace? stackTrace,
  ]) =>
      true;

  bool _realLog(
    Object? source,
    Object? message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    final context = _messageBuilder(
      _level,
      _requireLogger.package,
      Logger.resolveToString(source),
      Logger.resolveToString(message) ?? 'null',
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

    if (_formatter case final formatter?) {
      context._text = formatter(context);
    }

    _printer?.call(context);

    return true;
  }
}
