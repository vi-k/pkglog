part of '../logger.dart';

/// Function type for sub-loggers with context.
typedef LoggerWithSourceAndContextFunction<T extends Object?> = bool Function(
  T context,
  Object? message, [
  Object? error,
  StackTrace? stackTrace,
]);

/// A sub-logger that takes a context and formats the message.
///
/// See [LoggerWithSource.withContext].
final class LoggerWithSourceAndContext<T extends Object?> extends SubLogger {
  final Object? _source;
  final String Function(T context, String message) format;

  String? _resolvedSource;
  LoggerWithSourceAndContextFunction<T> _v = _noLog;
  LoggerWithSourceAndContextFunction<T> _d = _noLog;
  LoggerWithSourceAndContextFunction<T> _i = _noLog;
  LoggerWithSourceAndContextFunction<T> _w = _noLog;
  LoggerWithSourceAndContextFunction<T> _e = _noLog;
  LoggerWithSourceAndContextFunction<T> _c = _noLog;

  LoggerWithSourceAndContext._(
    super._logger, {
    required Object? source,
    required this.format,
    required super.level,
  })  : _source = source,
        super._();

  /// Log verbose message.
  LoggerWithSourceAndContextFunction<T> get v => _v;

  /// Log debug message.
  LoggerWithSourceAndContextFunction<T> get d => _d;

  /// Log info message.
  LoggerWithSourceAndContextFunction<T> get i => _i;

  /// Log warning message.
  LoggerWithSourceAndContextFunction<T> get w => _w;

  /// Log error message.
  LoggerWithSourceAndContextFunction<T> get e => _e;

  /// Log critical message.
  LoggerWithSourceAndContextFunction<T> get critical => _c;

  @override
  // ignore: avoid_setters_without_getters
  void _setMinLevel(MinLevel value) {
    _v = _selectLog(Level.verbose, value);
    _d = _selectLog(Level.debug, value);
    _i = _selectLog(Level.info, value);
    _w = _selectLog(Level.warning, value);
    _e = _selectLog(Level.error, value);
    _c = _selectLog(Level.critical, value);
  }

  LoggerWithSourceAndContextFunction<T> _selectLog(
    Level level,
    MinLevel minLevel,
  ) =>
      minLevel <= level ? _log(_logger[level], format) : _noLog;

  @pragma('vm:prefer-inline')
  static bool _noLog(
    void context,
    Object? message, [
    Object? error,
    StackTrace? stackTrace,
  ]) =>
      true;

  LoggerWithSourceAndContextFunction<T> _log(
    LevelLogger logger,
    String Function(T context, String message) format,
  ) {
    _resolvedSource ??= Logger.resolveToString(_source);
    return (context, message, [error, stackTrace]) => logger._realLog(
          _resolvedSource,
          format(context, Logger.resolveToString(message) ?? ''),
          error,
          stackTrace,
        );
  }
}
