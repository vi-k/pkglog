import 'dart:async';
import 'dart:core';

import 'package:meta/meta.dart';

part 'log_message.dart';
part 'log_error.dart';
part 'levels.dart';
part 'level_logger.dart';
part 'sub_loggers/sub_logger.dart';
part 'sub_loggers/logger_with_source.dart';
part 'sub_loggers/logger_with_source_and_context.dart';

typedef LogFunction = bool Function(
  Object? source,
  Object? message, {
  Object? error,
  StackTrace? stackTrace,
});

/// Main class for logging.
///
/// You can use [v], [d], [i], [w], [e], [critical] to log messages with
/// different levels.
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
  late LogLevel _level;

  /// Creates a new [Logger].
  ///
  /// [package] is the name of the package.
  /// [level] is the minimum log level.
  Logger(this.package, {LogLevel level = LogLevel.critical}) {
    _loggers = [_v, _d, _i, _w, _e, _c];
    for (final logger in _loggers) {
      logger._logger = this;
    }
    this.level = level;
  }

  final LevelLogger _v = LevelLogger._(LogLevel.verbose);
  final LevelLogger _d = LevelLogger._(LogLevel.debug);
  final LevelLogger _i = LevelLogger._(LogLevel.info);
  final LevelLogger _w = LevelLogger._(LogLevel.warning);
  final LevelLogger _e = LevelLogger._(LogLevel.error);
  final LevelLogger _c = LevelLogger._(LogLevel.critical);

  late final List<LevelLogger> _loggers;
  final List<WeakReference<SubLogger>> _subLoggers = [];

  @visibleForTesting
  int get subLoggersCount => _subLoggers.length;

  bool get isEnabled => _level != LogLevel.off;

  /// Returns a sub-logger with the predefined source and custom message
  /// formatting.
  ///
  /// The source is calculated lazily when the first message is actually
  /// logged.
  LoggerWithSource withSource(
    Object? source, {
    String Function(String)? format,
  }) {
    final sublogger = LoggerWithSource._(
      this, //
      level: _level,
      source: source,
      format: format,
    );
    _addSubLogger(sublogger);
    return sublogger;
  }

  /// Returns a sub-logger with the predefined source and custom message
  /// formatting with additional context from logging functions.
  ///
  /// ```dart
  /// final log = Logger('pkglog', level: LogLevel.all);
  /// final subLog = log.withContext<String>(
  ///     MyClass,
  ///     (method, message) => '$method | $message',
  /// );
  ///
  /// subLog.i('init', 'info');
  ///
  /// // [i] my_package | MyClass | init | info
  /// ```
  ///
  /// or:
  ///
  /// ```dart
  /// final log = Logger('pkglog', level: LogLevel.all);
  /// final subLog = log.withContext<Map<String, Object?>>(
  ///     MyClass,
  ///     (context, message) => '$message: ${jsonEncode(context)}',
  /// );
  ///
  /// subLog.i({'method': 'init', 'id': 1}, 'info');
  ///
  /// // [i] my_package | MyClass | info: {"method":"init","id":1}
  /// ```
  LoggerWithSourceAndContext<T> withContext<T extends Object?>(
    Object? source,
    String Function(T context, String message) format,
  ) {
    final sublogger = LoggerWithSourceAndContext._(
      this,
      source: source,
      format: format,
      level: _level,
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
  LevelLogger operator [](LoggerLevel level) => _loggers[level.index];

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
  set level(LogLevel value) {
    _level = value;
    for (final level in LoggerLevel.values) {
      _loggers[level.index]._toggle(value <= level);
    }

    for (final subLogger in _subLoggers) {
      subLogger.target?._setLevel(value);
    }
  }

  /// Sets the log message builder.
  ///
  /// ```dart
  /// // Use the default message builder.
  /// log.builder = LogMessage.defaultBuilder;
  ///
  /// // Use a custom message builder.
  /// log.builder = (msg) {
  ///   return '${msg.level.name.toUpperCase()}: ${msg.message}';
  /// };
  /// ```
  // ignore: avoid_setters_without_getters
  set builder(LogBuilder builder) {
    for (final logger in _loggers) {
      logger.builder = builder;
    }
  }

  /// Sets the log printer.
  ///
  /// ```dart
  /// // Use `printer` by default.
  /// log.printer = print;
  ///
  /// // Use a custom log printer.
  /// log.printer = stderr.writeln;
  ///
  /// // Colorize log messages.
  /// log.printer =
  ///     (text) => print(
  ///       text.split('\n').map((line) => '\x1B[32m$line\x1B[0m').join('\n'),
  ///     );
  /// ```
  // ignore: avoid_setters_without_getters
  set printer(LogPrinter? printer) {
    for (final logger in _loggers) {
      logger.printer = printer;
    }
  }

  R scope<R>(
    R Function() callback, {
    LogLevel? level,
    LogBuilder? builder,
    LogPrinter? printer = _defaultPrinter,
  }) =>
      runZoned(
        callback,
        zoneValues: {
          if (level != null)
            (_zoneLevelTag, this): switch (
                Zone.current[(_zoneLevelTag, this)]) {
              final LogLevel zoneLevel => zoneLevel > level ? zoneLevel : level,
              _ => level,
            },
          if (builder != null) (_zoneBuilderTag, this): builder,
          if (printer != _defaultPrinter)
            (_zonePrinterTag, this): printer ?? 42,
        },
      );

  R silent<R>(R Function() callback) => scope(callback, level: LogLevel.off);

  static R commonScope<R>(
    R Function() callback, {
    LogLevel? level,
    LogBuilder? builder,
    LogPrinter? printer = _defaultPrinter,
  }) =>
      runZoned(
        callback,
        zoneValues: {
          if (level != null)
            _zoneLevelTag: switch (Zone.current[_zoneLevelTag]) {
              final LogLevel zoneLevel => zoneLevel > level ? zoneLevel : level,
              _ => level,
            },
          if (builder != null) _zoneBuilderTag: builder,
          if (printer != _defaultPrinter) _zonePrinterTag: printer ?? 42,
        },
      );

  /// Resolve the [obj] to the object instance.
  ///
  /// If the object is a function, it is called and the result is returned
  ///
  /// Can be used for custom formatting in [Logger.withContext].
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
  /// Can be used for custom formatting in [Logger.withContext].
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
}
