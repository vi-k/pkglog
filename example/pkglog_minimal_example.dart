import 'package:pkglog/pkglog.dart';

void main() {
  final log = Logger('pkglog', level: LogLevel.all);

  print('\nDefaults:\n');

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e('main', 'error');
  log.s('main', 'shout');

  print('\nCustom formatting:\n');

  log.format =
      (level, package, source, message, error) => '[${level.shortName}]'
          ' $package'
          ' | ${DateTime.now()}'
          ' | $source'
          ' | $message'
          '${error == null ? '' : ': $error'}';

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e('main', 'error');
  log.s('main', 'shout');

  print('\nOnly errors:\n');

  log.level = LogLevel.error;

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e('main', 'error', Exception('error'), StackTrace.current);
  log.s('main', 'shout', Exception('shout'), StackTrace.current);
}
