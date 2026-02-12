part of '../logger.dart';

/// Function type for sub-loggers with source.
typedef LoggerWithSourceFunction = bool Function(
  Object? message, [
  Object? error,
  StackTrace? stackTrace,
]);

/// A sub-logger with predefined source and optional message formatting.
///
/// See [Logger.withSource] and [LoggerWithSource.withContext].
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

  /// Returns a sub-logger with the predefined [source] and custom message
  /// formatting function [format].
  ///
  /// The source is calculated lazily when the first message is actually
  /// logged.
  LoggerWithSource withFormatting(
    String Function(String) format,
  ) {
    final sublogger = LoggerWithSource._(
      _logger,
      level: _logger._minLevel,
      source: _source,
      format: format,
    );
    _logger._addSubLogger(sublogger);
    return sublogger;
  }

  /// Returns a sub-logger with the predefined source and custom message
  /// formatting function [format], that passes additional context from logging
  /// functions.
  ///
  /// ```dart
  /// final log = Logger('pkglog', minLevel: MinLevel.all);
  /// final subLog = log
  ///     .withSource(MyClass)
  ///     .withContext<String>((method, message) => '$method | $message');
  ///
  /// subLog.i('init', 'info');
  ///
  /// // [i] my_package | MyClass | init | info
  /// ```
  ///
  /// or:
  ///
  /// ```dart
  /// final log = Logger('pkglog', minLevel: MinLevel.all);
  /// final subLog = log //
  ///     .withSource(MyClass)
  ///     .withContext<Map<String, Object?>>(
  ///       (context, message) => '$message: ${jsonEncode(context)}',
  ///     );
  ///
  /// subLog.i({'method': 'init', 'id': 1}, 'info');
  ///
  /// // [i] my_package | MyClass | info: {"method":"init","id":1}
  /// ```
  LoggerWithSourceAndContext<T> withContext<T extends Object?>(
    String Function(T context, String message) format,
  ) {
    final sublogger = LoggerWithSourceAndContext._(
      _logger,
      source: _source,
      format: format,
      level: _logger._minLevel,
    );
    _logger._addSubLogger(sublogger);
    return sublogger;
  }

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

  LoggerWithSourceFunction _selectLog(
    Level level,
    MinLevel minLevel,
  ) =>
      minLevel <= level
          ? switch (format) {
              null => _log(_logger[level]),
              final format => _logWithFormat(_logger[level], format),
            }
          : _noLog;

  @pragma('vm:prefer-inline')
  static bool _noLog(
    Object? message, [
    Object? error,
    StackTrace? stackTrace,
  ]) =>
      true;

  LoggerWithSourceFunction _log(LevelLogger logger) =>
      (message, [error, stackTrace]) {
        _resolvedSource ??= Logger.resolveToString(_source);
        return logger._realLog(_resolvedSource, message, error, stackTrace);
      };

  LoggerWithSourceFunction _logWithFormat(
    LevelLogger logger,
    String Function(String message) format,
  ) =>
      (message, [error, stackTrace]) {
        _resolvedSource ??= Logger.resolveToString(_source);
        return logger._realLog(
          _resolvedSource,
          format(Logger.resolveToString(message) ?? ''),
          error,
          stackTrace,
        );
      };
}
