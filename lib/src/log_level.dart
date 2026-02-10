part of 'logger.dart';

enum LogLevel {
  verbose('v'),
  debug('d'),
  info('i'),
  warning('w'),
  error('e'),
  shout('s');

  final String shortName;

  const LogLevel(this.shortName);

  static LogLevel get all => verbose;

  static LogLevel? get off => null;
}
