part of 'logger.dart';

/// Log levels.
enum LogLevel {
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
  static LogLevel get all => verbose;

  /// No log level.
  static LogLevel? get off => null;
}
