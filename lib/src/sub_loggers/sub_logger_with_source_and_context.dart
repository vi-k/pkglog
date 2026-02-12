part of '../logger.dart';

/// Function type for sub-loggers with context.
typedef SubLoggerWithSourceAndContextFunction<T extends Object?> = bool
    Function(
  T context,
  Object? message, [
  Object? error,
  StackTrace? stackTrace,
]);

/// A sub-logger that takes a context and formats the message.
///
/// See [Logger.withSourceAndContext].
final class SubLoggerWithSourceAndContext<T extends Object?> extends SubLogger {
  final Object? _source;
  final String Function(T context, String message) format;

  String? _resolvedSource;
  SubLoggerWithSourceAndContextFunction<T> _v = _noLog;
  SubLoggerWithSourceAndContextFunction<T> _d = _noLog;
  SubLoggerWithSourceAndContextFunction<T> _i = _noLog;
  SubLoggerWithSourceAndContextFunction<T> _w = _noLog;
  SubLoggerWithSourceAndContextFunction<T> _e = _noLog;
  SubLoggerWithSourceAndContextFunction<T> _s = _noLog;

  SubLoggerWithSourceAndContext._(
    super._logger, {
    required Object? source,
    required this.format,
    required super.level,
  })  : _source = source,
        super._();

  /// Log verbose message.
  SubLoggerWithSourceAndContextFunction<T> get v => _v;

  /// Log debug message.
  SubLoggerWithSourceAndContextFunction<T> get d => _d;

  /// Log info message.
  SubLoggerWithSourceAndContextFunction<T> get i => _i;

  /// Log warning message.
  SubLoggerWithSourceAndContextFunction<T> get w => _w;

  /// Log error message.
  SubLoggerWithSourceAndContextFunction<T> get e => _e;

  /// Log shout message.
  SubLoggerWithSourceAndContextFunction<T> get s => _s;

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

  SubLoggerWithSourceAndContextFunction<T> _logFunction(
    LogLevel logLevel,
    LogLevelBase minLevel,
  ) =>
      minLevel is LogLevel && minLevel.index <= logLevel.index
          ? _log(_logger[logLevel], format)
          : _noLog;

  static bool _noLog(
    void context,
    Object? message, [
    Object? error,
    StackTrace? stackTrace,
  ]) =>
      true;

  SubLoggerWithSourceAndContextFunction<T> _log(
    LevelLogger logger,
    String Function(T context, String message) format,
  ) {
    _resolvedSource ??= Logger.objToString(_source);
    return (context, message, [error, stackTrace]) => logger._log(
          _resolvedSource,
          format(context, Logger.objToString(message) ?? ''),
          error,
          stackTrace,
        );
  }
}
