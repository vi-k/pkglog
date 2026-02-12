part of 'logger.dart';

sealed class LevelBase {
  int get index;
}

/// Log min levels.
enum MinLevel implements LevelBase {
  verbose,
  debug,
  info,
  warning,
  error,
  critical,
  off;

  /// All log levels.
  static const MinLevel all = verbose;

  bool operator <(LevelBase other) => index < other.index;
  bool operator <=(LevelBase other) => index <= other.index;
  bool operator >(LevelBase other) => index > other.index;
  bool operator >=(LevelBase other) => index >= other.index;
}

/// Logger levels.
enum Level implements LevelBase {
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

  /// Critical log level.
  critical('!');

  /// Short name of the log level.
  final String shortName;

  const Level(this.shortName);

  bool get isError => this == error || this == critical;

  bool operator <(LevelBase other) => index < other.index;
  bool operator <=(LevelBase other) => index <= other.index;
  bool operator >(LevelBase other) => index > other.index;
  bool operator >=(LevelBase other) => index >= other.index;
}
