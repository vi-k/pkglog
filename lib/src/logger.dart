import 'dart:async';

part 'log_error.dart';
part 'log_level.dart';
part 'level_logger.dart';
part 'sub_loggers/sub_logger.dart';
part 'sub_loggers/sub_logger_with_source.dart';
part 'sub_loggers/sub_logger_with_source_and_context.dart';

typedef LogFunction = bool Function(
  Object? source,
  Object? message, [
  Object? error,
  StackTrace? stackTrace,
]);

/// Main class for logging.
///
/// You can use [v], [d], [i], [w], [e], [s] to log messages with different
/// levels.
///
/// Example:
/// ```dart
/// final log = Logger('my_package', level: LogLevel.debug);
/// log.d('source', 'message');
/// ```
final class Logger {
  static final Finalizer<Logger> _finalizer = Finalizer((logger) {
    // final countBefore = logger._subLoggers.length;
    logger._subLoggers.removeWhere((subLogger) => subLogger.target == null);
    // final countAfter = logger._subLoggers.length;
    // Zone.current.print('finalize: $countBefore -> $countAfter');
  });

  final String package;

  late LogLevelBase _level;
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
  Logger(this.package, {required LogLevelBase level}) {
    _loggers = List.generate(
      LogLevel.values.length,
      (index) => LevelLogger._(this, LogLevel.values[index]),
      growable: false,
    );

    this.level = level;
  }

  int get $subLoggersCount => _subLoggers.length;

  /// Returns a sub-logger with the predefined [source].
  ///
  /// The source is calculated lazily when the first message is actually
  /// logged.
  SubLoggerWithSource withSource(Object? source) {
    final sublogger = SubLoggerWithSource._(
      this, //
      level: _level,
      source: source,
    );
    _subLoggers.add(WeakReference(sublogger));
    _finalizer.attach(sublogger, this);
    return sublogger;
  }

  /// Returns a sub-logger with the predefined [source] and custom message
  /// formatting function [format].
  ///
  /// The source is calculated lazily when the first message is actually
  /// logged.
  SubLoggerWithSource withSourceAndFormatting(
    Object? source,
    String Function(String) format,
  ) {
    final sublogger = SubLoggerWithSource._(
      this, //
      level: _level,
      source: source,
      format: format,
    );
    _subLoggers.add(WeakReference(sublogger));
    _finalizer.attach(sublogger, this);
    return sublogger;
  }

  /// Returns a sub-logger with the predefined [source] and custom message
  /// formatting function [format], that passes additional context from logging
  /// functions.
  ///
  /// ```dart
  /// final _log = log.withSourceAndContext<String>(
  ///   'MyClass',
  ///   (method, message) => '$method | $message',
  /// );
  ///
  /// _log.i('init', 'info');
  ///
  /// // [i] my_package | MyClass | init | info
  /// ```
  ///
  /// or:
  ///
  /// ```dart
  /// final _log = log.withSourceAndContext<Map<String, Object?>(
  ///   'MyClass',
  ///   (context, message) => '$message: ${jsonEncode(context}',
  /// );
  ///
  /// _log.i({'method': 'init', 'id': 1}, 'info');
  ///
  /// // [i] my_package | MyClass | info: {'method': 'init', 'id': 1}
  /// ```
  SubLoggerWithSourceAndContext<T> withSourceAndContext<T extends Object?>(
    Object? source,
    String Function(T context, String message) format,
  ) {
    final sublogger = SubLoggerWithSourceAndContext._(
      this,
      source: source,
      format: format,
      level: _level,
    );
    _subLoggers.add(WeakReference(sublogger));
    _finalizer.attach(sublogger, this);
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
  ///
  /// ```dart
  /// // Only errors will be logged.
  /// log.level = LogLevel.error;
  ///
  /// // Errors and warnings will be logged.
  /// log.level = LogLevel.warning;
  /// ```
  // ignore: avoid_setters_without_getters
  set level(LogLevelBase value) {
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
      subLogger.target?._setLevel(value);
    }
  }

  /// Sets the log formatter.
  ///
  /// ```dart
  /// // Use the default message formatter.
  /// log.format = Logger.buildDefaultMessage;
  ///
  /// // Use a custom message formatter.
  /// log.format = (level, package, source, message, error) {
  ///   return '${level.name.toUpperCase()}: $message';
  /// };
  /// ```
  // ignore: avoid_setters_without_getters
  set format(LogFormatter formatter) {
    for (final logger in _loggers) {
      logger.format = formatter;
    }
  }

  /// Sets the log printer.
  ///
  /// ```dart
  /// // Use `print` by default.
  /// log.print = print;
  ///
  /// // Use a custom log printer.
  /// log.print = stderr.writeln;
  /// ```
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
    StackTrace? stackTrace,
  ]) =>
      _logFunctions[level.index](source, message, error, stackTrace);

  LogFunction _logFunction(LogLevel logLevel, LogLevelBase minLevel) =>
      minLevel is LogLevel && minLevel.index <= logLevel.index
          ? _loggers[logLevel.index]._log
          : _noLog;

  static bool _noLog(
    Object? source,
    Object? message, [
    Object? error,
    StackTrace? stackTrace,
  ]) =>
      true;

  /// Converts an object to a string.
  ///
  /// If the object is a function, it is called and the result is converted to
  /// a string.
  ///
  /// Can be used for custom formatting in [withSourceAndContext].
  ///
  /// ```dart
  /// final _log = log.withSourceAndContext<Object?>(
  ///   'MyClass',
  ///   (context, message) {
  ///     final contextString = Logger.objToString(context);
  ///     return '$message context=$contextString';
  ///   },
  /// );
  ///
  /// Object? calcContext() {
  ///   return {'method': 'init', 'id': 1};
  /// }
  ///
  /// _log.i(calcContext, 'info');
  ///
  /// // [i] my_package | MyClass | info context={method: init, id: 1}
  /// ```
  static String? objToString(Object? obj) {
    final message = obj is Object? Function() ? obj() : obj;
    return switch (message) {
      String() => message,
      Object() => message.toString(),
      null => null,
    };
  }

  /// Builds the default log message.
  ///
  /// ```dart
  /// log.format = (level, package, source, message, error) {
  ///   final msg =
  ///       Logger.buildDefaultMessage(level, package, source, message, error);
  ///   return level == LogLevel.error || level == LogLevel.shout
  ///       ? '\x1B[31m$msg\x1B[0m'
  ///       : '$msg';
  /// };
  /// ```
  static String buildDefaultMessage(
    LogLevel level,
    String package,
    String? source,
    String message, [
    LogError? error,
  ]) =>
      '[${level.shortName}]'
      ' $package |'
      '${source == null ? '' : ' $source |'}'
      ' $message'
      '${error == null ? '' : ': $error'}';
}
