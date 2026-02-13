part of 'logger.dart';

/// Уровень логирования.
///
/// При установке уровня в конструкторе [Logger] или через [Logger.level]
/// этот уровень означает минимальный порог, с которого будут выводиться логи:
///
/// ```dart
/// // Only error and critical logs will be displayed.
/// log.level = LogLevel.error;
/// ```
///
/// При обращении к логеру, отвечающему за вывод лога, этот уровень означает
/// уровень логера:
///
/// ```dart
/// if (log[LogLevel.error].isEnabled) ...
/// ```
abstract final class LogLevel {
  const LogLevel._();

  int get index;

  static const LogLevel all = LogLevelAll._();
  static const LoggerLevel verbose = LoggerLevel._verbose;
  static const LoggerLevel debug = LoggerLevel._debug;
  static const LoggerLevel info = LoggerLevel._info;
  static const LoggerLevel warning = LoggerLevel._warning;
  static const LoggerLevel error = LoggerLevel._error;
  static const LoggerLevel critical = LoggerLevel._critical;
  static const LogLevel off = LogLevelOff._();

  bool operator <(LogLevel other) => index < other.index;
  bool operator <=(LogLevel other) => index <= other.index;
  bool operator >(LogLevel other) => index > other.index;
  bool operator >=(LogLevel other) => index >= other.index;
}

@immutable
final class LogLevelAll extends LogLevel {
  const LogLevelAll._() : super._();

  @override
  int get index => 0;

  @override
  String toString() => '$LogLevel.all';
}

@immutable
final class LogLevelOff extends LogLevel {
  const LogLevelOff._() : super._();

  @override
  int get index => LoggerLevel.values.length;

  @override
  String toString() => '$LogLevel.off';
}

/// Logger levels.
enum LoggerLevel implements LogLevel {
  /// Verbose log level.
  _verbose('verbose', 'v'),

  /// Debug log level.
  _debug('debug', 'd'),

  /// Info log level.
  _info('info', 'i'),

  /// Warning log level.
  _warning('warning', 'w'),

  /// Error log level.
  _error('error', 'e'),

  /// Critical log level.
  _critical('critical', '!');

  /// Name of the log level.
  final String name;

  /// Short name of the log level.
  final String shortName;

  const LoggerLevel(this.name, this.shortName);

  bool get isError => this == _error || this == _critical;

  @override
  bool operator <(LogLevel other) => index < other.index;

  @override
  bool operator <=(LogLevel other) => index <= other.index;

  @override
  bool operator >(LogLevel other) => index > other.index;

  @override
  bool operator >=(LogLevel other) => index >= other.index;

  @override
  String toString() => '$LogLevel.$name';
}
