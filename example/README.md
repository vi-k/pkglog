See repository for this example: [minimal](https://github.com/vi-k/pkglog/tree/main/example/pkglog_minimal_example.dart).

See also another example for a full demo:
[pkglog_example](https://github.com/vi-k/pkglog/tree/main/example/pkglog_example).

```dart
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
```
