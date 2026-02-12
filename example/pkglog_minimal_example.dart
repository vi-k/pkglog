import 'package:pkglog/pkglog.dart';

void main() {
  final log = Logger('pkglog', minLevel: MinLevel.all);

  print('\nDefaults:\n');

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e('main', 'error');
  log.critical('main', 'critical');

  print('\nCustom formatting:\n');

  log.format = (msg) => '[${msg.level.shortName}]'
      ' ${msg.package}'
      ' | ${DateTime.now()}'
      ' | ${msg.source}'
      ' | ${msg.message}'
      '${msg.error == null ? '' : ': ${msg.error}'}';

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e('main', 'error');
  log.critical('main', 'critical');

  print('\nOnly errors:\n');

  log.minLevel = MinLevel.error;

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e('main', 'error', Exception('test')); // StackTrace.current
  try {
    throw StateError('test');
  } on Object catch (error) {
    // The stack trace will be taken from Error.
    log.critical('main', 'critical', error);
  }
}
