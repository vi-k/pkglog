part of '../logger.dart';

/// Function type for parameterized sub-loggers.
typedef ParameterizedSubLogFunction<T extends Object?> = void Function(
  T param,
  Object? message, [
  Object? error,
  StackTrace stackTrace,
]);

/// A sub-logger that takes a parameter and formats the message.
final class ParameterizedSubLogger<T extends Object?> extends SubLogger {
  final String? _source;
  final String Function(T param, String message) format;

  ParameterizedSubLogFunction<T> _v = _noLog;
  ParameterizedSubLogFunction<T> _d = _noLog;
  ParameterizedSubLogFunction<T> _i = _noLog;
  ParameterizedSubLogFunction<T> _w = _noLog;
  ParameterizedSubLogFunction<T> _e = _noLog;
  ParameterizedSubLogFunction<T> _s = _noLog;

  ParameterizedSubLogger._(
    super._logger, {
    required Object? source,
    required this.format,
    required super.level,
  })  : _source = Logger.objToString(source),
        super._();

  /// Log verbose message.
  ParameterizedSubLogFunction<T> get v => _v;

  /// Log debug message.
  ParameterizedSubLogFunction<T> get d => _d;

  /// Log info message.
  ParameterizedSubLogFunction<T> get i => _i;

  /// Log warning message.
  ParameterizedSubLogFunction<T> get w => _w;

  /// Log error message.
  ParameterizedSubLogFunction<T> get e => _e;

  /// Log shout message.
  ParameterizedSubLogFunction<T> get s => _s;

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

  ParameterizedSubLogFunction<T> _logFunction(
    LogLevel logLevel,
    LogLevel? minLevel,
  ) =>
      minLevel != null && minLevel.index <= logLevel.index
          ? _realLog(_logger[logLevel], format)
          : _noLog;

  static void _noLog(
    void param,
    Object? message, [
    Object? error,
    StackTrace stackTrace = StackTrace.empty,
  ]) {}

  ParameterizedSubLogFunction<T> _realLog(
    LevelLogger logger,
    String Function(T param, String message) format,
  ) =>
      (param, message, [error, stackTrace = StackTrace.empty]) => logger._log(
            _source,
            format(
              param,
              Logger.objToString(message) ?? '',
            ),
            error,
            stackTrace,
          );
}
