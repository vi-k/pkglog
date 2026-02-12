import 'dart:convert';
import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart' as ansi;
import 'package:pkglog/pkglog.dart';

class MyClass {}

void main() {
  var log = Logger('pkglog', minLevel: MinLevel.all);

  print('\nDefaults:\n');

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e('main', 'error');
  log.critical('main', 'critical');

  print('\nCustom formatting:\n');

  log.format = (msg) => '${DateTime.now()} $msg';

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e('main', 'error');
  log.critical('main', 'critical');

  // Restore default format.
  log.format = null;

  print('\nAnsi colors:\n');

  final colorLevels = <Level, String>{
    Level.verbose: '${ansi.bg256Gray8}${ansi.fg256Rgb000}',
    Level.debug: '${ansi.bg256Gray12}${ansi.fg256Rgb000}',
    Level.info: '${ansi.bg256Rgb345}${ansi.fg256Rgb000}',
    Level.warning: '${ansi.bg256Rgb440}${ansi.fg256Rgb000}',
    Level.error: '${ansi.bg256Rgb400}${ansi.fg256Rgb000}',
    Level.critical: '${ansi.bg256Rgb300}${ansi.fg256Rgb550}',
  };
  log.format =
      (msg) => '${colorLevels[msg.level]}[${msg.level.shortName}]${ansi.reset}'
          ' ${msg.package} |'
          '${msg.source == null ? '' : ' ${msg.source} |'}'
          ' ${msg.message}'
          '${msg.error == null ? '' : ': ${msg.error}'}';

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e('main', 'error');
  log.critical('main', 'critical');

  // Restore default format.
  log.format = null;

  print('\nCustom printing:\n');

  for (final level in Level.values) {
    final printer = ansi.AnsiPrinter(
      ansiCodesEnabled: !Platform.isIOS,
      defaultState: ansi.SgrPlainState(
        foreground: switch (level) {
          Level.verbose => const ansi.Color256(ansi.Colors.gray8),
          Level.debug => const ansi.Color256(ansi.Colors.gray12),
          Level.info => const ansi.Color256(ansi.Colors.rgb345),
          Level.warning => const ansi.Color256(ansi.Colors.rgb440),
          Level.error => const ansi.Color256(ansi.Colors.rgb400),
          Level.critical => const ansi.Color256(ansi.Colors.rgb550),
        },
        background: switch (level) {
          Level.critical => const ansi.Color256(ansi.Colors.rgb300),
          _ => null,
        },
      ),
    );

    log[level].print = printer.print;
  }

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e('main', 'error');
  log.critical('main', 'critical');

  // Restore default print.
  log.print = print;

  print('\nDeferred parameter computation:\n');

  log.minLevel = MinLevel.info;
  var counter = 0;

  log.v(
    () => 'main (#${++counter})', // counter=0
    () => 'verbose (#${++counter})', // counter=0
  );
  log.d(
    () => 'main (#${++counter})', // counter=0
    () => 'debug (#${++counter})', // counter=0
  );
  log.i(
    () => 'main (#${++counter})', // counter=1
    () => 'info (#${++counter})', // counter=2
  );
  log.w(
    () => 'main (#${++counter})', // counter=3
    () => 'warning (#${++counter})', // counter=4
  );
  log.e(
    () => 'main (#${++counter})', // counter=5
    () => 'error (#${++counter})', // counter=6
  );
  log.critical(
    () => 'main (#${++counter})', // counter=7
    () => 'critical (#${++counter})', // counter=8
  );

  print('\nAuto stack trace:\n');

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

  print('\nDisable logging completely:\n');

  log.minLevel = MinLevel.off;

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e('main', 'error');
  log.critical('main', 'critical');

  print('\nDisabling the logger using asserts:\n');

  log.minLevel = MinLevel.all;

  assert(log.v('main', 'verbose'));
  assert(log.d('main', 'debug'));
  assert(log.i('main', 'info'));
  assert(log.w('main', 'warning'));
  assert(log.e('main', 'error'));
  assert(log.critical('main', 'critical'));

  print('\nEnabling the logger using compile environment:\n');

  const logIsEnabled = bool.fromEnvironment('logging');

  logIsEnabled && log.v('main', 'verbose');
  logIsEnabled && log.d('main', 'debug');
  logIsEnabled && log.i('main', 'info');
  logIsEnabled && log.w('main', 'warning');
  logIsEnabled && log.e('main', 'error');
  logIsEnabled && log.critical('main', 'critical');

  print('\nAccess to level logger:\n');

  log[Level.info].format =
      (msg) => '${msg.level.name.toUpperCase()}: ${msg.message}';

  log[Level.info].print =
      (msg) => print('${ansi.fgGreen}${msg.text}${ansi.reset}');

  log[Level.info].log('main', 'info');

  print('\nSub loggers:\n');

  log = Logger('pkglog', minLevel: MinLevel.all);
  log.i(MyClass, 'info');

  final subLog1 = log.withSource(MyClass);
  subLog1.i('info');

  final subLog2 = subLog1.withFormatting(
    (message) => 'formatted: $message',
  );
  subLog2.i('info');

  final subLog3 = subLog1.withContext<String>(
    (method, message) => '$method: $message',
  );
  subLog3.i('init', 'info');

  final subLog4 = subLog1.withContext<Map<String, Object?>>(
    (context, message) => '$message: ${jsonEncode(context)}',
  );
  subLog4.i({'method': 'init', 'id': 1}, 'info');
}
