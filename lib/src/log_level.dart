part of 'logger.dart';

final class LogLevelBase {
  const LogLevelBase();
}

/// Log levels.
enum LogLevel implements LogLevelBase {
  /// Verbose log level.
  verbose('v'),

  /// Debug log level.
  debug('d'),

  /// Info log level.
  info('i'),

  /// Warning log level.
  warning('w'),

  /// Error log level.
  error('e'),

  /// Shout log level.
  shout('s');

  /// Short name of the log level.
  final String shortName;

  const LogLevel(this.shortName);

  /// All log levels.
  static const LogLevel all = verbose;

  /// Logging off.
  static const LogLevelBase off = LogLevelBase();
}
