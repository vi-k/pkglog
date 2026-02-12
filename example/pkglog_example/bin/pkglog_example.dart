import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart' as ansi;
import 'package:pkglog/pkglog.dart';

class MyClass {}

void main() {
  var log = Logger('pkglog', level: LogLevel.all);

  print('\nDefaults:\n');

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e('main', 'error');
  log.s('main', 'shout');

  print('\nCustom formatting:\n');

  log.format = (level, package, source, message, error) =>
      '[${level.shortName}] $package | ${DateTime.now()} |'
      '${source == null ? '' : ' $source |'}'
      ' $message'
      '${error == null ? '' : ': $error'}';

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e('main', 'error');
  log.s('main', 'shout');

  print('\nAnsi colors:\n');

  for (final level in LogLevel.values) {
    final printer = ansi.AnsiPrinter(
      ansiCodesEnabled: !Platform.isIOS,
      defaultState: ansi.SgrPlainState(
        foreground: switch (level) {
          LogLevel.verbose => const ansi.Color256(ansi.Colors.gray8),
          LogLevel.debug => const ansi.Color256(ansi.Colors.gray12),
          LogLevel.info => const ansi.Color256(ansi.Colors.rgb345),
          LogLevel.warning => const ansi.Color256(ansi.Colors.rgb440),
          LogLevel.error => const ansi.Color256(ansi.Colors.rgb400),
          LogLevel.shout => const ansi.Color256(ansi.Colors.rgb550),
        },
        background: switch (level) {
          LogLevel.shout => const ansi.Color256(ansi.Colors.rgb300),
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
  log.s('main', 'shout');

  print('\nDeferred parameter computation:\n');

  log.level = LogLevel.info;
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
  log.s(
    () => 'main (#${++counter})', // counter=7
    () => 'shout (#${++counter})', // counter=8
  );

  print('\nAuto stack trace:\n');

  log.level = LogLevel.error;

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e('main', 'error', Exception('test')); // StackTrace.current
  try {
    throw StateError('test');
  } on Object catch (e) {
    log.s('main', 'shout', e); // stack trace from Error
  }

  print('\nDisable logging completely:\n');

  log.level = LogLevel.off;

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e('main', 'error');
  log.s('main', 'shout');

  print('\nDisabling the logger using asserts:\n');

  log.level = LogLevel.all;

  assert(log.v('main', 'verbose'));
  assert(log.d('main', 'debug'));
  assert(log.i('main', 'info'));
  assert(log.w('main', 'warning'));
  assert(log.e('main', 'error'));
  assert(log.s('main', 'shout'));

  print('\nEnabling the logger using compile environment:\n');

  const logIsEnabled = bool.fromEnvironment('logging');

  logIsEnabled && log.v('main', 'verbose');
  logIsEnabled && log.d('main', 'debug');
  logIsEnabled && log.i('main', 'info');
  logIsEnabled && log.w('main', 'warning');
  logIsEnabled && log.e('main', 'error');
  logIsEnabled && log.s('main', 'shout');

  print('\nAccess to level logger:\n');

  log[LogLevel.info].format = Logger.buildDefaultMessage;
  log[LogLevel.info].print = (text) => print('INFO: $text');

  log
    ..level = LogLevel.all
    ..i('main', 'info')
    ..log(LogLevel.info, 'main', 'info');

  print('\nCustom printing:\n');

  log = Logger('pkglog', level: LogLevel.all);

  final defaultPrinter = ansi.AnsiPrinter(
    ansiCodesEnabled: !Platform.isIOS,
    defaultState: const ansi.SgrPlainState(
      foreground: ansi.Color256(ansi.Colors.gray12),
    ),
    stacked: true,
  );

  final levelColors = <LogLevel, String>{
    LogLevel.verbose: '${ansi.fg256Gray0}${ansi.bg256Gray8}',
    LogLevel.debug: '${ansi.fg256Gray0}${ansi.bg256Gray12}',
    LogLevel.info: '${ansi.fg256Gray0}${ansi.bg256Rgb345}',
    LogLevel.warning: '${ansi.fg256Gray0}${ansi.bg256Rgb440}',
    LogLevel.error: '${ansi.fg256Gray0}${ansi.bg256Rgb400}',
    LogLevel.shout: '${ansi.fg256Rgb550}${ansi.bg256Rgb400}',
  };

  log
    ..print = null
    ..format = (level, package, source, message, error) {
      final text = '${levelColors[level]!}[${level.shortName}]${ansi.reset}'
          ' $package |'
          '${source == null ? '' : ' $source |'}'
          ' $message'
          '${error == null ? '' : ': $error'}';
      defaultPrinter.print(text);
      return text;
    };

  const query = 'GET https://example.com/';

  log.i('http', '$query | ${ansi.fg256Rgb050}[200] OK${ansi.reset}');
  log.w('http', '$query | ${ansi.fg256Rgb530}[301] Redirect${ansi.reset}');
  log.e('http', '$query | ${ansi.fg256Rgb500}[400] Bad request${ansi.reset}');
  log.s(
    'http',
    '$query | ${ansi.fg256Rgb511}${ansi.bg256Rgb100}'
        '[500] Internal Server Error${ansi.reset}',
  );

  print('\nSub loggers:\n');

  log = Logger('pkglog', level: LogLevel.all);
  final subLog1 = log.withSource(MyClass);
  final subLog2 = log.withSourceAndFormatting(
    MyClass,
    (message) => 'formatted: $message',
  );
  final subLog3 = log.withSourceAndContext<String>(
    MyClass,
    (method, message) => '$method: $message',
  );

  log.i(MyClass, 'info');
  subLog1.i('info');
  subLog2.i('info');
  subLog3.i('init', 'info');
}
