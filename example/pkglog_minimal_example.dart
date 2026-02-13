import 'package:pkglog/pkglog.dart';

void main() {
  final log = Logger('pkglog', level: LogLevel.all);

  print('\nDefaults:\n');

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e('main', 'error');
  log.critical('main', 'critical');

  print('\nCustom building:\n');

  log.builder = (msg) => '${DateTime.now()} [${msg.level.shortName}]'
      ' ${msg.package}'
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

  log.level = LogLevel.error;

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  try {
    throw Exception('test');
  } on Object catch (error, stackTrace) {
    log.e('main', 'error', error: error, stackTrace: stackTrace);
  }
  try {
    throw StateError('test');
    // ignore: avoid_catching_errors
  } on Error catch (error) {
    log.critical(
      'main',
      'critical',
      error: error, // The stack trace will be taken from `Error`.
    );
  }
}
