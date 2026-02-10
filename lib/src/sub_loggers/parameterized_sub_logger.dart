part of '../logger.dart';

typedef ParameterizedSubLogFunction<T extends Object?> = void Function(
  T param,
  Object? message, [
  Object? error,
  StackTrace stackTrace,
]);

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

  ParameterizedSubLogFunction<T> get v => _v;
  ParameterizedSubLogFunction<T> get d => _d;
  ParameterizedSubLogFunction<T> get i => _i;
  ParameterizedSubLogFunction<T> get w => _w;
  ParameterizedSubLogFunction<T> get e => _e;
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
