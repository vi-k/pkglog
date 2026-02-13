import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart' as ansi;
import 'package:pkglog/pkglog.dart';

class MyClass {}

Future<void> main() async {
  var log = Logger('pkglog', level: LogLevel.all);

  //
  print('\nDefaults:\n');

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e('main', 'error');
  log.critical('main', 'critical');

  //
  print('\nCustom building:\n');

  log.builder = (msg) => '${DateTime.now()} $msg';

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e('main', 'error');
  log.critical('main', 'critical');

  // Restore default builder.
  log.builder = LogMessage.defaultBuilder;

  //
  print('\nAnsi colors:\n');

  final colorLevels = <LoggerLevel, String>{
    LogLevel.verbose: '${ansi.bg256Gray8}${ansi.fg256Rgb000}',
    LogLevel.debug: '${ansi.bg256Gray12}${ansi.fg256Rgb000}',
    LogLevel.info: '${ansi.bg256Rgb345}${ansi.fg256Rgb000}',
    LogLevel.warning: '${ansi.bg256Rgb440}${ansi.fg256Rgb000}',
    LogLevel.error: '${ansi.bg256Rgb400}${ansi.fg256Rgb000}',
    LogLevel.critical: '${ansi.bg256Rgb300}${ansi.fg256Rgb550}',
  };
  log.builder =
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

  // Restore default builder.
  log.builder = LogMessage.defaultBuilder;

  //
  print('\nCustom printing:\n');

  for (final level in LoggerLevel.values) {
    final printer = ansi.AnsiPrinter(
      ansiCodesEnabled: !Platform.isIOS,
      defaultState: ansi.SgrPlainState(
        foreground: switch (level) {
          LogLevel.verbose => const ansi.Color256(ansi.Colors.gray8),
          LogLevel.debug => const ansi.Color256(ansi.Colors.gray12),
          LogLevel.info => const ansi.Color256(ansi.Colors.rgb345),
          LogLevel.warning => const ansi.Color256(ansi.Colors.rgb440),
          LogLevel.error => const ansi.Color256(ansi.Colors.rgb400),
          LogLevel.critical => const ansi.Color256(ansi.Colors.rgb550),
        },
        background: switch (level) {
          LogLevel.critical => const ansi.Color256(ansi.Colors.rgb300),
          _ => null,
        },
      ),
    );

    log[level].printer = printer.print;
  }

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e('main', 'error');
  log.critical('main', 'critical');

  // Restore default print.
  log.printer = print;

  //
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
  log.critical(
    () => 'main (#${++counter})', // counter=7
    () => 'critical (#${++counter})', // counter=8
  );

  //
  print('\nAuto stack trace:\n');

  log.level = LogLevel.error;

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e(
    'main',
    'error',
    error: Exception('test'), // auto stack trace
  );
  try {
    throw StateError('test');
  } on Object catch (error) {
    log.critical(
      'main',
      'critical',
      error: error, // the stack trace will be taken from `Error`
    );
  }

  //
  print('\nDisable logging completely:\n');

  log.level = LogLevel.off;

  log.v('main', 'verbose');
  log.d('main', 'debug');
  log.i('main', 'info');
  log.w('main', 'warning');
  log.e('main', 'error');
  log.critical('main', 'critical');

  //
  print('\nDisabling the logger using asserts:\n');

  log.level = LogLevel.all;

  assert(log.v('main', 'verbose'));
  assert(log.d('main', 'debug'));
  assert(log.i('main', 'info'));
  assert(log.w('main', 'warning'));
  assert(log.e('main', 'error'));
  assert(log.critical('main', 'critical'));

  //
  print('\nEnabling the logger using compile environment:\n');

  const logIsEnabled = bool.fromEnvironment('logging');

  logIsEnabled && log.v('main', 'verbose');
  logIsEnabled && log.d('main', 'debug');
  logIsEnabled && log.i('main', 'info');
  logIsEnabled && log.w('main', 'warning');
  logIsEnabled && log.e('main', 'error');
  logIsEnabled && log.critical('main', 'critical');

  //
  print('\nAccess to level logger:\n');

  log.level = LogLevel.info;

  log[LogLevel.info].builder =
      (msg) => '${msg.level.name.toUpperCase()}: ${msg.message}';

  log[LogLevel.info].printer =
      (msg) => print('${ansi.fgGreen}$msg${ansi.reset}');

  log[LogLevel.info].log('main', 'info');

  print('debug enabled: ${log[LogLevel.debug].isEnabled}');
  print('info enabled: ${log[LogLevel.info].isEnabled}');

  //
  print('\nSub loggers:\n');

  log = Logger('pkglog', level: LogLevel.all);
  log.i(MyClass, 'info');

  final subLog1 = log.withSource(
    MyClass,
    format: (message) => 'formatted: $message',
  );
  subLog1.i('info');

  final subLog2 = log.withContext<String>(
    MyClass,
    (method, message) => '$method: $message',
  );
  subLog2.i('init', 'info');

  final subLog3 = log.withContext<Map<String, Object?>>(
    MyClass,
    (context, message) => '$message: ${jsonEncode(context)}',
  );
  subLog3.i({'method': 'init', 'id': 1}, 'info');

  //
  print('\nScopes: levels:\n');

  log.level = LogLevel.all;

  Logger.commonScope(
    level: LogLevel.debug,
    () {
      log.v('scope#1', 'verbose'); // -
      log.d('scope#1', 'debug'); // +
      log.i('scope#1', 'info'); // +

      log.scope(level: LogLevel.info, () {
        log.v('scope#2', 'verbose'); // -
        log.d('scope#2', 'debug'); // -
        log.i('scope#2', 'info'); // +

        /// Silent mode = LogLevel.off.
        log.silent(() {
          log.v('scope#3', 'verbose'); // -
          log.d('scope#3', 'debug'); // -
          log.i('scope#3', 'info'); // -

          /// You cannot set a level lower than the current one.
          log.scope(level: LogLevel.debug, () {
            log.v('scope#3', 'verbose'); // -
            log.d('scope#3', 'debug'); // -
            log.i('scope#3', 'info'); // -
          });
        });
      });
    },
  );
  log.v('main', 'verbose'); // +
  log.d('main', 'debug'); // +
  log.i('main', 'info'); // +

  //
  print('\nScopes: builders and printers:\n');

  Logger.commonScope(
    builder: (msg) => '(built in scope #1) $msg',
    printer: (text) => print('(printed in scope #1) $text'),
    () {
      log.i('scope#1', 'info');

      log.scope(
        builder: (msg) => '(built in scope #2) $msg',
        printer: (text) => print('(printed in scope #2) $text'),
        () {
          log.i('scope#2', 'info');

          log.scope(
            builder: (msg) => '(built in scope #3) $msg',
            printer: (text) => print('(printed in scope #3) $text'),
            () {
              log.i('scope#3', 'info');

              // Asynchronous logging.
              Future(() {
                log.i('scope#3', 'future info');
              });
            },
          );
        },
      );
    },
  );
  log.i('main', 'info');
  // Wait for asynchronous logging "future info".
  await Future(() {});
}
