See repository for this example: [minimal](https://github.com/vi-k/pkglog/tree/main/example/pkglog_minimal_example.dart).

See also another example for a full demo:
[pkglog_example](https://github.com/vi-k/pkglog/tree/main/example/pkglog_example).

```dart
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

  log.format = (level, package, source, message, error, stackTrace) =>
      '[${level.shortName}]'
      ' $package'
      ' | ${DateTime.now()}'
      ' | $source'
      ' | $message'
      '${error == null ? '' : ': $error'}'
      '${stackTrace == StackTrace.empty ? '' : '\n$stackTrace'}';

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
```
