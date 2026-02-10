import 'dart:async';

part 'log_level.dart';
part 'level_logger.dart';
part 'sub_loggers/sub_logger.dart';
part 'sub_loggers/preformatting_sub_logger.dart';
part 'sub_loggers/parameterized_sub_logger.dart';

typedef LogFunction = void Function(
  Object? source,
  Object? message, [
  Object? error,
  StackTrace stackTrace,
]);

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

  Logger(this.package, {required LogLevel? level}) {
    _loggers = List.generate(
      LogLevel.values.length,
      (index) => LevelLogger(this, LogLevel.values[index]),
      growable: false,
    );

    this.level = level;
  }

  PreformattingSubLogger withSource(Object? source) {
    _removeOldSubLoggers();
    final sublogger =
        PreformattingSubLogger._(this, source: source, level: _level);
    _subLoggers.add(WeakReference(sublogger));
    return sublogger;
  }

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

  LogFunction get v => _v;
  LogFunction get d => _d;
  LogFunction get i => _i;
  LogFunction get w => _w;
  LogFunction get e => _e;
  LogFunction get s => _s;

  LevelLogger operator [](LogLevel level) => _loggers[level.index];

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

  // ignore: avoid_setters_without_getters
  set format(LogFormatter formatter) {
    for (final logger in _loggers) {
      logger.format = formatter;
    }
  }

  // ignore: avoid_setters_without_getters
  set print(LogPrinter? printer) {
    for (final logger in _loggers) {
      logger.print = printer;
    }
  }

  void log(
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

  static void _noLog(
    Object? source,
    Object? message, [
    Object? error,
    StackTrace stackTrace = StackTrace.empty,
  ]) {}

  static String? objToString(Object? obj) =>
      obj == null ? null : '${obj is Object? Function() ? obj() : obj}';

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

  static void defaultPrinter(String text) {
    Zone.current.print(text);
  }
}
