part of '../logger.dart';

/// Function type for preformatting sub-loggers.
typedef PreformattingSubLogFunction = bool Function(
  Object? message, [
  Object? error,
  StackTrace stackTrace,
]);

/// A sub-logger that pre-formats messages.
final class PreformattingSubLogger extends SubLogger {
  final String? _source;
  final String Function(String message)? format;

  PreformattingSubLogFunction _v = _noLog;
  PreformattingSubLogFunction _d = _noLog;
  PreformattingSubLogFunction _i = _noLog;
  PreformattingSubLogFunction _w = _noLog;
  PreformattingSubLogFunction _e = _noLog;
  PreformattingSubLogFunction _s = _noLog;

  PreformattingSubLogger._(
    super._logger, {
    required Object? source,
    this.format,
    required super.level,
  })  : _source = Logger.objToString(source),
        super._();

  /// Log verbose message.
  PreformattingSubLogFunction get v => _v;

  /// Log debug message.
  PreformattingSubLogFunction get d => _d;

  /// Log info message.
  PreformattingSubLogFunction get i => _i;

  /// Log warning message.
  PreformattingSubLogFunction get w => _w;

  /// Log error message.
  PreformattingSubLogFunction get e => _e;

  /// Log shout message.
  PreformattingSubLogFunction get s => _s;

  @override
  // ignore: avoid_setters_without_getters
  set _level(LogLevel? value) {
    _v = _logFunction(LogLevel.verbose, value);
    _d = _logFunction(LogLevel.debug, value);
    _i = _logFunction(LogLevel.info, value);
    _w = _logFunction(LogLevel.warning, value);
    _e = _logFunction(LogLevel.error, value);
    _s = _logFunction(LogLevel.shout, value);
  }

  PreformattingSubLogFunction _logFunction(
    LogLevel logLevel,
    LogLevel? minLevel,
  ) =>
      minLevel != null && minLevel.index <= logLevel.index
          ? switch (format) {
              null => _log(_logger[logLevel]),
              final format => _logWithFormat(_logger[logLevel], format),
            }
          : _noLog;

  static bool _noLog(
    Object? message, [
    Object? error,
    StackTrace stackTrace = StackTrace.empty,
  ]) =>
      true;

  PreformattingSubLogFunction _log(LevelLogger logger) =>
      (message, [error, stackTrace = StackTrace.empty]) =>
          logger._log(_source, message, error, stackTrace);

  PreformattingSubLogFunction _logWithFormat(
    LevelLogger logger,
    String Function(String message) format,
  ) =>
      (message, [error, stackTrace = StackTrace.empty]) => logger._log(
            _source,
            format(Logger.objToString(message) ?? ''),
            error,
            stackTrace,
          );
}
