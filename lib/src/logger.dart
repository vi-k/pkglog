import 'dart:async';

part 'log_message.dart';
part 'log_error.dart';
part 'levels.dart';
part 'level_logger.dart';
part 'sub_loggers/sub_logger.dart';
part 'sub_loggers/logger_with_source.dart';
part 'sub_loggers/logger_with_source_and_context.dart';

typedef LogFunction = bool Function(
  Object? source,
  Object? message, [
  Object? error,
  StackTrace? stackTrace,
]);

/// Main class for logging.
///
/// You can use [v], [d], [i], [w], [e], [critical] to log messages with
/// different levels.
///
/// Example:
/// ```dart
/// final log = Logger('my_package', minLevel: MinLevel.debug);
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
  late MinLevel _minLevel;

  /// Creates a new [Logger].
  ///
  /// [package] is the name of the package.
  /// [minLevel] is the minimum log level.
  Logger(this.package, {MinLevel minLevel = MinLevel.critical}) {
    _loggers = [_v, _d, _i, _w, _e, _c];
    for (final logger in _loggers) {
      logger._logger = this;
    }
    this.minLevel = minLevel;
  }

  final LevelLogger _v = LevelLogger._(Level.verbose);
  final LevelLogger _d = LevelLogger._(Level.debug);
  final LevelLogger _i = LevelLogger._(Level.info);
  final LevelLogger _w = LevelLogger._(Level.warning);
  final LevelLogger _e = LevelLogger._(Level.error);
  final LevelLogger _c = LevelLogger._(Level.critical);

  late final List<LevelLogger> _loggers;
  final List<WeakReference<SubLogger>> _subLoggers = [];

  // LogFunction _v = _noLog;
  // LogFunction _d = _noLog;
  // LogFunction _i = _noLog;
  // LogFunction _w = _noLog;
  // LogFunction _e = _noLog;
  // LogFunction _c = _noLog;

  int get $subLoggersCount => _subLoggers.length;

  bool get isEnabled => _minLevel != MinLevel.off;

  /// Returns a sub-logger with the predefined [source].
  ///
  /// The source is calculated lazily when the first message is actually
  /// logged.
  LoggerWithSource withSource(Object? source) {
    final sublogger = LoggerWithSource._(
      this, //
      level: _minLevel,
      source: source,
    );
    _addSubLogger(sublogger);
    return sublogger;
  }

  void _addSubLogger(SubLogger sublogger) {
    _subLoggers.add(WeakReference(sublogger));
    _finalizer.attach(sublogger, this);
  }

  /// Log verbose message.
  LogFunction get v => _v.log;

  /// Log debug message.
  LogFunction get d => _d.log;

  /// Log info message.
  LogFunction get i => _i.log;

  /// Log warning message.
  LogFunction get w => _w.log;

  /// Log error message.
  LogFunction get e => _e.log;

  /// Log critical message.
  LogFunction get critical => _c.log;

  /// Returns the [LevelLogger] for the given [level].
  LevelLogger operator [](Level level) => _loggers[level.index];

  /// Sets the minimum log level.
  ///
  /// ```dart
  /// // Only errors will be logged.
  /// log.minLevel = MinLevel.error;
  ///
  /// // Errors and warnings will be logged.
  /// log.minLevel = MinLevel.warning;
  /// ```
  // ignore: avoid_setters_without_getters
  set minLevel(MinLevel value) {
    _minLevel = value;
    for (final level in Level.values) {
      _loggers[level.index]._toggle(value <= level);
    }

    for (final subLogger in _subLoggers) {
      subLogger.target?._setMinLevel(value);
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
  set format(LogFormatter? formatter) {
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

  /// Resolve the [obj] to the object instance.
  ///
  /// If the object is a function, it is called and the result is returned
  ///
  /// Can be used for custom formatting in [LoggerWithSource.withContext].
  ///
  /// ```dart
  /// final _log = log
  ///     .withSource(MyClass)
  ///     .withContext<Object?>(
  ///       (context, message) {
  ///         final object = Logger.resolveToObject(context);
  ///         return '$message context=${jsonEncode(object)}';
  ///       },
  ///     );
  ///
  /// Object? evaluateContext() {
  ///   return {'method': 'init', 'id': 1};
  /// }
  ///
  /// _log.i(evaluateContext, 'info');
  ///
  /// // [i] pkglog | MyClass | info context={"method":"init","id":1}
  /// ```
  ///
  /// See also [resolveToString].
  static Object? resolveToObject(Object? obj) =>
      obj is Object? Function() ? obj() : obj;

  /// Converts an object to a string.
  ///
  /// If the object is a function, it is called and the result is converted to
  /// a string.
  ///
  /// Can be used for custom formatting in [LoggerWithSource.withContext].
  ///
  /// ```dart
  /// final _log = log
  ///     .withSource(MyClass)
  ///     .withContext<Object?>(
  ///       (context, message) {
  ///         final contextString = Logger.resolveToString(context);
  ///         return '$message context=$contextString';
  ///       },
  ///     );
  ///
  /// Object? calcContext() {
  ///   return {'method': 'init', 'id': 1};
  /// }
  ///
  /// _log.i(calcContext, 'info');
  ///
  /// // [i] my_package | MyClass | info context={method: init, id: 1}
  /// ```
  ///
  /// See also [resolveToObject].
  static String? resolveToString(Object? obj) {
    final message = resolveToObject(obj);
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
  ///   return level.isError
  ///       ? '\x1B[31m$msg\x1B[0m'
  ///       : '$msg';
  /// };
  /// ```
  static void defaultPrinter(LogMessage msg) => Zone.current.print(msg.text);
}
