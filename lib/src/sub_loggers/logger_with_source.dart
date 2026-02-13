part of '../logger.dart';

/// Function type for sub-loggers with source.
typedef LoggerWithSourceFunction = bool Function(
  Object? message, {
  Object? error,
  StackTrace? stackTrace,
});

/// A sub-logger with predefined source and optional message formatting.
///
/// See [Logger.withSource] and [Logger.withContext].
final class LoggerWithSource extends SubLogger {
  final Object? _source;
  final String Function(String message)? format;

  String? _resolvedSource;
  LoggerWithSourceFunction _v = _noLog;
  LoggerWithSourceFunction _d = _noLog;
  LoggerWithSourceFunction _i = _noLog;
  LoggerWithSourceFunction _w = _noLog;
  LoggerWithSourceFunction _e = _noLog;
  LoggerWithSourceFunction _c = _noLog;

  LoggerWithSource._(
    super._logger, {
    required Object? source,
    this.format,
    required super.level,
  })  : _source = source,
        super._();

  /// Log verbose message.
  LoggerWithSourceFunction get v => _v;

  /// Log debug message.
  LoggerWithSourceFunction get d => _d;

  /// Log info message.
  LoggerWithSourceFunction get i => _i;

  /// Log warning message.
  LoggerWithSourceFunction get w => _w;

  /// Log error message.
  LoggerWithSourceFunction get e => _e;

  /// Log critical message.
  LoggerWithSourceFunction get critical => _c;

  @override
  // ignore: avoid_setters_without_getters
  void _setLevel(LogLevel value) {
    _v = _selectLog(LoggerLevel._verbose, value);
    _d = _selectLog(LoggerLevel._debug, value);
    _i = _selectLog(LoggerLevel._info, value);
    _w = _selectLog(LoggerLevel._warning, value);
    _e = _selectLog(LoggerLevel._error, value);
    _c = _selectLog(LoggerLevel._critical, value);
  }

  LoggerWithSourceFunction _selectLog(
    LoggerLevel loggerLevel,
    LogLevel logLevel,
  ) =>
      logLevel <= loggerLevel
          ? switch (format) {
              null => _log(_logger[loggerLevel]),
              final format => _logWithFormat(_logger[loggerLevel], format),
            }
          : _noLog;

  @pragma('vm:prefer-inline')
  static bool _noLog(
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      true;

  LoggerWithSourceFunction _log(LevelLogger logger) =>
      (message, {error, stackTrace}) {
        _resolvedSource ??= Logger.resolveToString(_source);
        return logger._realLog(
          _resolvedSource,
          message,
          error: error,
          stackTrace: stackTrace,
        );
      };

  LoggerWithSourceFunction _logWithFormat(
    LevelLogger logger,
    String Function(String message) format,
  ) =>
      (message, {error, stackTrace}) {
        _resolvedSource ??= Logger.resolveToString(_source);
        return logger._realLog(
          _resolvedSource,
          format(Logger.resolveToString(message) ?? ''),
          error: error,
          stackTrace: stackTrace,
        );
      };
}
