import 'dart:async';

part 'log_level.dart';
part 'level_logger.dart';
part 'sub_loggers/sub_logger.dart';
part 'sub_loggers/preformatting_sub_logger.dart';
part 'sub_loggers/parameterized_sub_logger.dart';

typedef LogFunction = bool Function(
  Object? source,
  Object? message, [
  Object? error,
  StackTrace stackTrace,
]);

/// Main class for logging.
///
/// You can use [v], [d], [i], [w], [e], [s] to log messages with different
/// levels.
///
/// Example:
/// ```dart
/// final logger = Logger('my_package', level: LogLevel.debug);
/// logger.d('source', 'message');
/// ```
final class Logger {
  final String package;

  late LogLevel? _level;
  late final List<LevelLogger> _loggers;
  final List<LogFunction> _logFunctions =
      List.filled(LogLevel.values.length, _noLog);
  final List<WeakReference<SubLogger>> _subLoggers = [];

  LogFunction _v = _noLog;
  LogFunction _d = _noLog;
  LogFunction _i = _noLog;
  LogFunction _w = _noLog;
  LogFunction _e = _noLog;
  LogFunction _s = _noLog;

  /// Creates a new [Logger].
  ///
  /// [package] is the name of the package.
  /// [level] is the minimum log level.
  Logger(this.package, {required LogLevel? level}) {
    _loggers = List.generate(
      LogLevel.values.length,
      (index) => LevelLogger._(this, LogLevel.values[index]),
      growable: false,
    );

    this.level = level;
  }

  /// Returns a new [PreformattingSubLogger] with the given [source].
  PreformattingSubLogger withSource(Object? source) {
    _removeOldSubLoggers();
    final sublogger =
        PreformattingSubLogger._(this, source: source, level: _level);
    _subLoggers.add(WeakReference(sublogger));
    return sublogger;
  }

  /// Returns a new [PreformattingSubLogger] with the given [source] and
  /// [format].
  PreformattingSubLogger withSourceAndFormatting(
    Object? source,
    String Function(String) format,
  ) {
    _removeOldSubLoggers();
    final sublogger = PreformattingSubLogger._(
      this,
      source: source,
      format: format,
      level: _level,
    );
    _subLoggers.add(WeakReference(sublogger));
    return sublogger;
  }

  /// Returns a new [ParameterizedSubLogger] with the given [source] and
  /// [format].
  ParameterizedSubLogger<T> withSourceAndParam<T extends Object?>(
    Object? source,
    String Function(T param, String message) format,
  ) {
    _removeOldSubLoggers();
    final sublogger = ParameterizedSubLogger._(
      this,
      source: source,
      format: format,
      level: _level,
    );
    _subLoggers.add(WeakReference(sublogger));
    return sublogger;
  }

  /// Log verbose message.
  LogFunction get v => _v;

  /// Log debug message.
  LogFunction get d => _d;

  /// Log info message.
  LogFunction get i => _i;

  /// Log warning message.
  LogFunction get w => _w;

  /// Log error message.
  LogFunction get e => _e;

  /// Log shout message.
  LogFunction get s => _s;

  /// Returns the [LevelLogger] for the given [level].
  LevelLogger operator [](LogLevel level) => _loggers[level.index];

  /// Sets the minimum log level.
  // ignore: avoid_setters_without_getters
  set level(LogLevel? value) {
    _level = value;
    for (final level in LogLevel.values) {
      _logFunctions[level.index] = _logFunction(level, value);
    }

    _v = _logFunctions[LogLevel.verbose.index];
    _d = _logFunctions[LogLevel.debug.index];
    _i = _logFunctions[LogLevel.info.index];
    _w = _logFunctions[LogLevel.warning.index];
    _e = _logFunctions[LogLevel.error.index];
    _s = _logFunctions[LogLevel.shout.index];

    for (final subLogger in _subLoggers) {
      subLogger.target?._level = value;
    }
    _removeOldSubLoggers();
  }

  void _removeOldSubLoggers() {
    _subLoggers.removeWhere((subLogger) => subLogger.target == null);
  }

  /// Sets the log formatter.
  // ignore: avoid_setters_without_getters
  set format(LogFormatter formatter) {
    for (final logger in _loggers) {
      logger.format = formatter;
    }
  }

  /// Sets the log printer.
  // ignore: avoid_setters_without_getters
  set print(LogPrinter? printer) {
    for (final logger in _loggers) {
      logger.print = printer;
    }
  }

  /// Logs a message with the given [level], [source], [message], [error] and
  /// [stackTrace].
  bool log(
    LogLevel level,
    Object? source,
    Object? message, [
    Object? error,
    StackTrace stackTrace = StackTrace.empty,
  ]) =>
      _logFunctions[level.index](source, message, error, stackTrace);

  LogFunction _logFunction(LogLevel logLevel, LogLevel? minLevel) =>
      minLevel != null && minLevel.index <= logLevel.index
          ? _loggers[logLevel.index]._log
          : _noLog;

  static bool _noLog(
    Object? source,
    Object? message, [
    Object? error,
    StackTrace stackTrace = StackTrace.empty,
  ]) =>
      true;

  /// Converts an object to a string.
  ///
  /// If the object is a function, it is called and the result is converted to
  /// a string.
  static String? objToString(Object? obj) =>
      obj == null ? null : '${obj is Object? Function() ? obj() : obj}';

  /// Builds the default log message.
  static String buildDefaultMessage(
    LogLevel level,
    String package,
    String? source,
    String message, [
    Object? error,
    StackTrace stackTrace = StackTrace.empty,
  ]) =>
      '[${level.shortName}]'
      ' $package |'
      '${source == null ? '' : ' $source |'}'
      ' $message'
      '${error == null ? '' : ': $error'}'
      '${stackTrace == StackTrace.empty ? '' : '\n$stackTrace'}';
}
