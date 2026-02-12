part of '../logger.dart';

/// Function type for sub-loggers with source.
typedef SubLoggerWithSourceFunction = bool Function(
  Object? message, [
  Object? error,
  StackTrace? stackTrace,
]);

/// A sub-logger with predefined source and optional message formatting.
///
/// See [Logger.withSource] and [Logger.withSourceAndContext].
final class SubLoggerWithSource extends SubLogger {
  final Object? _source;
  final String Function(String message)? format;

  String? _resolvedSource;
  SubLoggerWithSourceFunction _v = _noLog;
  SubLoggerWithSourceFunction _d = _noLog;
  SubLoggerWithSourceFunction _i = _noLog;
  SubLoggerWithSourceFunction _w = _noLog;
  SubLoggerWithSourceFunction _e = _noLog;
  SubLoggerWithSourceFunction _s = _noLog;

  SubLoggerWithSource._(
    super._logger, {
    required Object? source,
    this.format,
    required super.level,
  })  : _source = source,
        super._();

  /// Log verbose message.
  SubLoggerWithSourceFunction get v => _v;

  /// Log debug message.
  SubLoggerWithSourceFunction get d => _d;

  /// Log info message.
  SubLoggerWithSourceFunction get i => _i;

  /// Log warning message.
  SubLoggerWithSourceFunction get w => _w;

  /// Log error message.
  SubLoggerWithSourceFunction get e => _e;

  /// Log shout message.
  SubLoggerWithSourceFunction get s => _s;

  @override
  // ignore: avoid_setters_without_getters
  void _setLevel(LogLevelBase value) {
    _v = _logFunction(LogLevel.verbose, value);
    _d = _logFunction(LogLevel.debug, value);
    _i = _logFunction(LogLevel.info, value);
    _w = _logFunction(LogLevel.warning, value);
    _e = _logFunction(LogLevel.error, value);
    _s = _logFunction(LogLevel.shout, value);
  }

  SubLoggerWithSourceFunction _logFunction(
    LogLevel logLevel,
    LogLevelBase minLevel,
  ) =>
      minLevel is LogLevel && minLevel.index <= logLevel.index
          ? switch (format) {
              null => _log(_logger[logLevel]),
              final format => _logWithFormat(_logger[logLevel], format),
            }
          : _noLog;

  static bool _noLog(
    Object? message, [
    Object? error,
    StackTrace? stackTrace,
  ]) =>
      true;

  SubLoggerWithSourceFunction _log(LevelLogger logger) {
    _resolvedSource ??= Logger.objToString(_source);
    return (message, [error, stackTrace]) =>
        logger._log(_resolvedSource, message, error, stackTrace);
  }

  SubLoggerWithSourceFunction _logWithFormat(
    LevelLogger logger,
    String Function(String message) format,
  ) {
    _resolvedSource ??= Logger.objToString(_source);
    return (message, [error, stackTrace]) => logger._log(
          _resolvedSource,
          format(Logger.objToString(message) ?? ''),
          error,
          stackTrace,
        );
  }
}
