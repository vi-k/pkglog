@TestOn('vm')
library;

import 'dart:async';

import 'package:leak_tracker/leak_tracker.dart';
import 'package:pkglog/pkglog.dart';
import 'package:test/test.dart';

import 'utils/gc.dart';

void main() {
  group('[Logger]', () {
    final buf = <String>[];
    late Logger log;
    var counter = 0;

    setUp(() {
      counter = 0;
      buf.clear();
      log = Logger('test', level: LogLevel.all)..print = buf.add;
    });

    String Function() checkCalc(String msg) => () {
          counter++;
          return msg;
        };

    group('check levels:', () {
      group('check levels:', () {
        void logAll() {
          log.v('main', 'verbose');
          log.d('main', 'debug');
          log.i('main', 'info');
          log.w('main', 'warning');
          log.e('main', 'error');
          log.s('main', 'shout');
        }

        void verificationOfParameterCalculation() {
          log.v(checkCalc('main'), checkCalc('verbose'));
          log.d(checkCalc('main'), checkCalc('debug'));
          log.i(checkCalc('main'), checkCalc('info'));
          log.w(checkCalc('main'), checkCalc('warning'));
          log.e(checkCalc('main'), checkCalc('error'));
          log.s(checkCalc('main'), checkCalc('shout'));
        }

        test('all levels', () {
          log.level = LogLevel.all;
          logAll();
          expect(buf, [
            '[v] test | main | verbose',
            '[d] test | main | debug',
            '[i] test | main | info',
            '[w] test | main | warning',
            '[e] test | main | error',
            '[s] test | main | shout',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 12);
        });

        test('verbose level', () {
          log.level = LogLevel.verbose; // == LogLevel.all
          logAll();
          expect(buf, [
            '[v] test | main | verbose',
            '[d] test | main | debug',
            '[i] test | main | info',
            '[w] test | main | warning',
            '[e] test | main | error',
            '[s] test | main | shout',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 12);
        });

        test('debug level', () {
          log.level = LogLevel.debug;
          logAll();
          expect(buf, [
            '[d] test | main | debug',
            '[i] test | main | info',
            '[w] test | main | warning',
            '[e] test | main | error',
            '[s] test | main | shout',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 10);
        });

        test('info level', () {
          log.level = LogLevel.info;
          logAll();
          expect(buf, [
            '[i] test | main | info',
            '[w] test | main | warning',
            '[e] test | main | error',
            '[s] test | main | shout',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 8);
        });

        test('warning level', () {
          log.level = LogLevel.warning;
          logAll();
          expect(buf, [
            '[w] test | main | warning',
            '[e] test | main | error',
            '[s] test | main | shout',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 6);
        });

        test('error level', () {
          log.level = LogLevel.error;
          logAll();
          expect(buf, [
            '[e] test | main | error',
            '[s] test | main | shout',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 4);
        });

        test('shout level', () {
          log.level = LogLevel.shout;
          logAll();
          expect(buf, [
            '[s] test | main | shout',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 2);
        });

        test('off', () {
          log.level = LogLevel.off;
          logAll();
          expect(buf, <String>[]);
          verificationOfParameterCalculation();
          expect(counter, 0);
        });
      });

      // Asserts cannot be disabled in tests, so you need to check the result
      // with asserts disabled using a separate file: pkglog_test_asserts.dart:
      //
      // dart run test/pkglog_test_asserts.dart
      group('enable by asserts:', () {
        var assertsEnabled = false;

        setUpAll(() async {
          assert(() {
            assertsEnabled = true;
            return true;
          }());
          print('asserts: ${assertsEnabled ? 'enabled' : 'disabled'}');
        });

        void logAll() {
          assert(log.v('main', 'verbose'));
          assert(log.d('main', 'debug'));
          assert(log.i('main', 'info'));
          assert(log.w('main', 'warning'));
          assert(log.e('main', 'error'));
          assert(log.s('main', 'shout'));
        }

        void verificationOfParameterCalculation() {
          assert(log.v(checkCalc('main'), checkCalc('verbose')));
          assert(log.d(checkCalc('main'), checkCalc('debug')));
          assert(log.i(checkCalc('main'), checkCalc('info')));
          assert(log.w(checkCalc('main'), checkCalc('warning')));
          assert(log.e(checkCalc('main'), checkCalc('error')));
          assert(log.s(checkCalc('main'), checkCalc('shout')));
        }

        List<String> whenAssertsEnabled(List<String> expected) =>
            assertsEnabled ? expected : <String>[];

        test('all levels', () {
          log.level = LogLevel.all;
          logAll();
          expect(
            buf,
            whenAssertsEnabled([
              '[v] test | main | verbose',
              '[d] test | main | debug',
              '[i] test | main | info',
              '[w] test | main | warning',
              '[e] test | main | error',
              '[s] test | main | shout',
            ]),
          );
          verificationOfParameterCalculation();
          expect(counter, assertsEnabled ? 12 : 0);
        });

        test('verbose level', () {
          log.level = LogLevel.verbose; // == LogLevel.all
          logAll();
          expect(
            buf,
            whenAssertsEnabled([
              '[v] test | main | verbose',
              '[d] test | main | debug',
              '[i] test | main | info',
              '[w] test | main | warning',
              '[e] test | main | error',
              '[s] test | main | shout',
            ]),
          );
          verificationOfParameterCalculation();
          expect(counter, assertsEnabled ? 12 : 0);
        });

        test('debug level', () {
          log.level = LogLevel.debug;
          logAll();
          expect(
            buf,
            whenAssertsEnabled([
              '[d] test | main | debug',
              '[i] test | main | info',
              '[w] test | main | warning',
              '[e] test | main | error',
              '[s] test | main | shout',
            ]),
          );
          verificationOfParameterCalculation();
          expect(counter, assertsEnabled ? 10 : 0);
        });

        test('info level', () {
          log.level = LogLevel.info;
          logAll();
          expect(
            buf,
            whenAssertsEnabled([
              '[i] test | main | info',
              '[w] test | main | warning',
              '[e] test | main | error',
              '[s] test | main | shout',
            ]),
          );
          verificationOfParameterCalculation();
          expect(counter, assertsEnabled ? 8 : 0);
        });

        test('warning level', () {
          log.level = LogLevel.warning;
          logAll();
          expect(
            buf,
            whenAssertsEnabled([
              '[w] test | main | warning',
              '[e] test | main | error',
              '[s] test | main | shout',
            ]),
          );
          verificationOfParameterCalculation();
          expect(counter, assertsEnabled ? 6 : 0);
        });

        test('error level', () {
          log.level = LogLevel.error;
          logAll();
          expect(
            buf,
            whenAssertsEnabled([
              '[e] test | main | error',
              '[s] test | main | shout',
            ]),
          );
          verificationOfParameterCalculation();
          expect(counter, assertsEnabled ? 4 : 0);
        });

        test('shout level', () {
          log.level = LogLevel.shout;
          logAll();
          expect(
            buf,
            whenAssertsEnabled([
              '[s] test | main | shout',
            ]),
          );
          verificationOfParameterCalculation();
          expect(counter, assertsEnabled ? 2 : 0);
        });

        test('off', () {
          log.level = LogLevel.off;
          logAll();
          expect(buf, <String>[]);
          verificationOfParameterCalculation();
          expect(counter, 0);
        });
      });

      group('enable by constant:', () {
        const logIsEnabled = true;

        void logAll() {
          logIsEnabled && log.v('main', 'verbose');
          logIsEnabled && log.d('main', 'debug');
          logIsEnabled && log.i('main', 'info');
          logIsEnabled && log.w('main', 'warning');
          logIsEnabled && log.e('main', 'error');
          logIsEnabled && log.s('main', 'shout');
        }

        void verificationOfParameterCalculation() {
          logIsEnabled && log.v(checkCalc('main'), checkCalc('verbose'));
          logIsEnabled && log.d(checkCalc('main'), checkCalc('debug'));
          logIsEnabled && log.i(checkCalc('main'), checkCalc('info'));
          logIsEnabled && log.w(checkCalc('main'), checkCalc('warning'));
          logIsEnabled && log.e(checkCalc('main'), checkCalc('error'));
          logIsEnabled && log.s(checkCalc('main'), checkCalc('shout'));
        }

        test('all levels', () {
          log.level = LogLevel.all;
          logAll();
          expect(buf, [
            '[v] test | main | verbose',
            '[d] test | main | debug',
            '[i] test | main | info',
            '[w] test | main | warning',
            '[e] test | main | error',
            '[s] test | main | shout',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 12);
        });

        test('verbose level', () {
          log.level = LogLevel.verbose; // == LogLevel.all
          logAll();
          expect(buf, [
            '[v] test | main | verbose',
            '[d] test | main | debug',
            '[i] test | main | info',
            '[w] test | main | warning',
            '[e] test | main | error',
            '[s] test | main | shout',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 12);
        });

        test('debug level', () {
          log.level = LogLevel.debug;
          logAll();
          expect(buf, [
            '[d] test | main | debug',
            '[i] test | main | info',
            '[w] test | main | warning',
            '[e] test | main | error',
            '[s] test | main | shout',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 10);
        });

        test('info level', () {
          log.level = LogLevel.info;
          logAll();
          expect(buf, [
            '[i] test | main | info',
            '[w] test | main | warning',
            '[e] test | main | error',
            '[s] test | main | shout',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 8);
        });

        test('warning level', () {
          log.level = LogLevel.warning;
          logAll();
          expect(buf, [
            '[w] test | main | warning',
            '[e] test | main | error',
            '[s] test | main | shout',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 6);
        });

        test('error level', () {
          log.level = LogLevel.error;
          logAll();
          expect(buf, [
            '[e] test | main | error',
            '[s] test | main | shout',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 4);
        });

        test('shout level', () {
          log.level = LogLevel.shout;
          logAll();
          expect(buf, [
            '[s] test | main | shout',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 2);
        });

        test('off', () {
          log.level = LogLevel.off;
          logAll();
          expect(buf, <String>[]);
          verificationOfParameterCalculation();
          expect(counter, 0);
        });
      });

      group('disable by constant:', () {
        const logIsEnabled = false;

        void logAll() {
          // ignore: dead_code
          logIsEnabled && log.v('main', 'verbose');
          // ignore: dead_code
          logIsEnabled && log.d('main', 'debug');
          // ignore: dead_code
          logIsEnabled && log.i('main', 'info');
          // ignore: dead_code
          logIsEnabled && log.w('main', 'warning');
          // ignore: dead_code
          logIsEnabled && log.e('main', 'error');
          // ignore: dead_code
          logIsEnabled && log.s('main', 'shout');
        }

        void verificationOfParameterCalculation() {
          // ignore: dead_code
          logIsEnabled && log.v(checkCalc('main'), checkCalc('verbose'));
          // ignore: dead_code
          logIsEnabled && log.d(checkCalc('main'), checkCalc('debug'));
          // ignore: dead_code
          logIsEnabled && log.i(checkCalc('main'), checkCalc('info'));
          // ignore: dead_code
          logIsEnabled && log.w(checkCalc('main'), checkCalc('warning'));
          // ignore: dead_code
          logIsEnabled && log.e(checkCalc('main'), checkCalc('error'));
          // ignore: dead_code
          logIsEnabled && log.s(checkCalc('main'), checkCalc('shout'));
        }

        test('all levels', () {
          log.level = LogLevel.all;
          logAll();
          expect(buf, <String>[]);
          verificationOfParameterCalculation();
          expect(counter, 0);
        });

        test('verbose level', () {
          log.level = LogLevel.verbose; // == LogLevel.all
          logAll();
          expect(buf, <String>[]);
          verificationOfParameterCalculation();
          expect(counter, 0);
        });

        test('debug level', () {
          log.level = LogLevel.debug;
          logAll();
          expect(buf, <String>[]);
          verificationOfParameterCalculation();
          expect(counter, 0);
        });

        test('info level', () {
          log.level = LogLevel.info;
          logAll();
          expect(buf, <String>[]);
          verificationOfParameterCalculation();
          expect(counter, 0);
        });

        test('warning level', () {
          log.level = LogLevel.warning;
          logAll();
          expect(buf, <String>[]);
          verificationOfParameterCalculation();
          expect(counter, 0);
        });

        test('error level', () {
          log.level = LogLevel.error;
          logAll();
          expect(buf, <String>[]);
          verificationOfParameterCalculation();
          expect(counter, 0);
        });

        test('shout level', () {
          log.level = LogLevel.shout;
          logAll();
          expect(buf, <String>[]);
          verificationOfParameterCalculation();
          expect(counter, 0);
        });

        test('off', () {
          log.level = LogLevel.off;
          logAll();
          expect(buf, <String>[]);
          verificationOfParameterCalculation();
          expect(counter, 0);
        });
      });

      group('[Sub-loggers]', () {
        group('withSource:', () {
          late SubLoggerWithSource subLog;

          setUp(() {
            subLog = log.withSource(checkCalc('main'));
          });

          void logAll() {
            subLog.v('verbose');
            subLog.d('debug');
            subLog.i('info');
            subLog.w('warning');
            subLog.e('error');
            subLog.s('shout');
          }

          void verificationOfParameterCalculation() {
            subLog.v(checkCalc('verbose'));
            subLog.d(checkCalc('debug'));
            subLog.i(checkCalc('info'));
            subLog.w(checkCalc('warning'));
            subLog.e(checkCalc('error'));
            subLog.s(checkCalc('shout'));
          }

          test('all levels', () {
            log.level = LogLevel.all;
            logAll();
            expect(buf, [
              '[v] test | main | verbose',
              '[d] test | main | debug',
              '[i] test | main | info',
              '[w] test | main | warning',
              '[e] test | main | error',
              '[s] test | main | shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 7); // params calc
          });

          test('verbose level', () {
            log.level = LogLevel.verbose; // == LogLevel.all
            logAll();
            expect(buf, [
              '[v] test | main | verbose',
              '[d] test | main | debug',
              '[i] test | main | info',
              '[w] test | main | warning',
              '[e] test | main | error',
              '[s] test | main | shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 7); // params calc
          });

          test('debug level', () {
            log.level = LogLevel.debug;
            logAll();
            expect(buf, [
              '[d] test | main | debug',
              '[i] test | main | info',
              '[w] test | main | warning',
              '[e] test | main | error',
              '[s] test | main | shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 6); // params calc
          });

          test('info level', () {
            log.level = LogLevel.info;
            logAll();
            expect(buf, [
              '[i] test | main | info',
              '[w] test | main | warning',
              '[e] test | main | error',
              '[s] test | main | shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 5); // params calc
          });

          test('warning level', () {
            log.level = LogLevel.warning;
            logAll();
            expect(buf, [
              '[w] test | main | warning',
              '[e] test | main | error',
              '[s] test | main | shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 4); // params calc
          });

          test('error level', () {
            log.level = LogLevel.error;
            logAll();
            expect(buf, [
              '[e] test | main | error',
              '[s] test | main | shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 3); // params calc
          });

          test('shout level', () {
            log.level = LogLevel.shout;
            logAll();
            expect(buf, [
              '[s] test | main | shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 2); // params calc
          });

          test('off', () {
            log.level = LogLevel.off;
            logAll();
            expect(buf, <String>[]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 1); // params calc
          });
        });

        group('withSourceAndFormatting:', () {
          late SubLoggerWithSource subLog;

          setUp(() {
            subLog = log.withSourceAndFormatting(
              checkCalc('main'),
              (msg) => 'formatted: $msg',
            );
          });

          void logAll() {
            subLog.v('verbose');
            subLog.d('debug');
            subLog.i('info');
            subLog.w('warning');
            subLog.e('error');
            subLog.s('shout');
          }

          void verificationOfParameterCalculation() {
            subLog.v(checkCalc('verbose'));
            subLog.d(checkCalc('debug'));
            subLog.i(checkCalc('info'));
            subLog.w(checkCalc('warning'));
            subLog.e(checkCalc('error'));
            subLog.s(checkCalc('shout'));
          }

          test('all levels', () {
            log.level = LogLevel.all;
            logAll();
            expect(buf, [
              '[v] test | main | formatted: verbose',
              '[d] test | main | formatted: debug',
              '[i] test | main | formatted: info',
              '[w] test | main | formatted: warning',
              '[e] test | main | formatted: error',
              '[s] test | main | formatted: shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 7); // params calc
          });

          test('verbose level', () {
            log.level = LogLevel.verbose; // == LogLevel.all
            logAll();
            expect(buf, [
              '[v] test | main | formatted: verbose',
              '[d] test | main | formatted: debug',
              '[i] test | main | formatted: info',
              '[w] test | main | formatted: warning',
              '[e] test | main | formatted: error',
              '[s] test | main | formatted: shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 7); // params calc
          });

          test('debug level', () {
            log.level = LogLevel.debug;
            logAll();
            expect(buf, [
              '[d] test | main | formatted: debug',
              '[i] test | main | formatted: info',
              '[w] test | main | formatted: warning',
              '[e] test | main | formatted: error',
              '[s] test | main | formatted: shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 6); // params calc
          });

          test('info level', () {
            log.level = LogLevel.info;
            logAll();
            expect(buf, [
              '[i] test | main | formatted: info',
              '[w] test | main | formatted: warning',
              '[e] test | main | formatted: error',
              '[s] test | main | formatted: shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 5); // params calc
          });

          test('warning level', () {
            log.level = LogLevel.warning;
            logAll();
            expect(buf, [
              '[w] test | main | formatted: warning',
              '[e] test | main | formatted: error',
              '[s] test | main | formatted: shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 4); // params calc
          });

          test('error level', () {
            log.level = LogLevel.error;
            logAll();
            expect(buf, [
              '[e] test | main | formatted: error',
              '[s] test | main | formatted: shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 3); // params calc
          });

          test('shout level', () {
            log.level = LogLevel.shout;
            logAll();
            expect(buf, [
              '[s] test | main | formatted: shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 2); // params calc
          });

          test('off', () {
            log.level = LogLevel.off;
            logAll();
            expect(buf, <String>[]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 1); // params calc
          });
        });

        group('withSourceAndContext:', () {
          late SubLoggerWithSourceAndContext<String> subLog;

          setUp(() {
            subLog = log.withSourceAndContext(
              checkCalc('main'),
              (method, msg) => '$method | $msg',
            );
          });

          void logAll() {
            subLog.v('init', 'verbose');
            subLog.d('init', 'debug');
            subLog.i('init', 'info');
            subLog.w('init', 'warning');
            subLog.e('init', 'error');
            subLog.s('init', 'shout');
          }

          void verificationOfParameterCalculation() {
            subLog.v('init', checkCalc('verbose'));
            subLog.d('init', checkCalc('debug'));
            subLog.i('init', checkCalc('info'));
            subLog.w('init', checkCalc('warning'));
            subLog.e('init', checkCalc('error'));
            subLog.s('init', checkCalc('shout'));
          }

          test('all levels', () {
            log.level = LogLevel.all;
            logAll();
            expect(buf, [
              '[v] test | main | init | verbose',
              '[d] test | main | init | debug',
              '[i] test | main | init | info',
              '[w] test | main | init | warning',
              '[e] test | main | init | error',
              '[s] test | main | init | shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 7); // params calc
          });

          test('verbose level', () {
            log.level = LogLevel.verbose; // == LogLevel.all
            logAll();
            expect(buf, [
              '[v] test | main | init | verbose',
              '[d] test | main | init | debug',
              '[i] test | main | init | info',
              '[w] test | main | init | warning',
              '[e] test | main | init | error',
              '[s] test | main | init | shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 7); // params calc
          });

          test('debug level', () {
            log.level = LogLevel.debug;
            logAll();
            expect(buf, [
              '[d] test | main | init | debug',
              '[i] test | main | init | info',
              '[w] test | main | init | warning',
              '[e] test | main | init | error',
              '[s] test | main | init | shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 6); // params calc
          });

          test('info level', () {
            log.level = LogLevel.info;
            logAll();
            expect(buf, [
              '[i] test | main | init | info',
              '[w] test | main | init | warning',
              '[e] test | main | init | error',
              '[s] test | main | init | shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 5); // params calc
          });

          test('warning level', () {
            log.level = LogLevel.warning;
            logAll();
            expect(buf, [
              '[w] test | main | init | warning',
              '[e] test | main | init | error',
              '[s] test | main | init | shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 4); // params calc
          });

          test('error level', () {
            log.level = LogLevel.error;
            logAll();
            expect(buf, [
              '[e] test | main | init | error',
              '[s] test | main | init | shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 3); // params calc
          });

          test('shout level', () {
            log.level = LogLevel.shout;
            logAll();
            expect(buf, [
              '[s] test | main | init | shout',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 2); // params calc
          });

          test('off', () {
            log.level = LogLevel.off;
            logAll();
            expect(buf, <String>[]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 1); // params calc
          });
        });
      });
    });

    group('custom formatting:', () {
      late SubLoggerWithSource subLog1;
      late SubLoggerWithSourceAndContext<String> subLog2;

      setUp(() {
        subLog1 = log.withSourceAndFormatting(
          'main',
          (message) => 'formatted: $message',
        );
        subLog2 = log.withSourceAndContext<String>(
          'main',
          (context, message) => '$context: $message',
        );
      });

      void logAll() {
        log.v('main', 'verbose');
        log.d('main', 'debug');
        log.i('main', 'info');
        log.w('main', 'warning');
        log.e('main', 'error');
        log.s('main', 'shout');

        subLog1.v('verbose');
        subLog1.d('debug');
        subLog1.i('info');
        subLog1.w('warning');
        subLog1.e('error');
        subLog1.s('shout');

        subLog2.v('init', 'verbose');
        subLog2.d('init', 'debug');
        subLog2.i('init', 'info');
        subLog2.w('init', 'warning');
        subLog2.e('init', 'error');
        subLog2.s('init', 'shout');
      }

      test('all levels', () {
        log.format = (level, package, source, message, error) =>
            '${level.name.toUpperCase().padRight(7)} [$package]'
            ' ${source == null ? '' : '$source:'}'
            ' $message';
        logAll();
        expect(buf, [
          'VERBOSE [test] main: verbose',
          'DEBUG   [test] main: debug',
          'INFO    [test] main: info',
          'WARNING [test] main: warning',
          'ERROR   [test] main: error',
          'SHOUT   [test] main: shout',
          // subLog1
          'VERBOSE [test] main: formatted: verbose',
          'DEBUG   [test] main: formatted: debug',
          'INFO    [test] main: formatted: info',
          'WARNING [test] main: formatted: warning',
          'ERROR   [test] main: formatted: error',
          'SHOUT   [test] main: formatted: shout',
          // subLog2
          'VERBOSE [test] main: init: verbose',
          'DEBUG   [test] main: init: debug',
          'INFO    [test] main: init: info',
          'WARNING [test] main: init: warning',
          'ERROR   [test] main: init: error',
          'SHOUT   [test] main: init: shout',
        ]);
      });

      test('all levels except LogLevel.info', () {
        log.format = (level, package, source, message, error) =>
            '${level.name.toUpperCase().padRight(7)} [$package]'
            ' ${source == null ? '' : '$source:'}'
            ' $message';
        log[LogLevel.info].format = Logger.buildDefaultMessage;
        logAll();
        expect(buf, [
          'VERBOSE [test] main: verbose',
          'DEBUG   [test] main: debug',
          '[i] test | main | info',
          'WARNING [test] main: warning',
          'ERROR   [test] main: error',
          'SHOUT   [test] main: shout',
          // subLog1
          'VERBOSE [test] main: formatted: verbose',
          'DEBUG   [test] main: formatted: debug',
          '[i] test | main | formatted: info',
          'WARNING [test] main: formatted: warning',
          'ERROR   [test] main: formatted: error',
          'SHOUT   [test] main: formatted: shout',
          // subLog2
          'VERBOSE [test] main: init: verbose',
          'DEBUG   [test] main: init: debug',
          '[i] test | main | init: info',
          'WARNING [test] main: init: warning',
          'ERROR   [test] main: init: error',
          'SHOUT   [test] main: init: shout',
        ]);
      });

      test('only LogLevel.info', () {
        log[LogLevel.info].format = (level, package, source, message, error) =>
            '${level.name.toUpperCase().padRight(7)} [$package]'
            ' ${source == null ? '' : '$source:'}'
            ' $message';
        logAll();
        expect(buf, [
          '[v] test | main | verbose',
          '[d] test | main | debug',
          'INFO    [test] main: info',
          '[w] test | main | warning',
          '[e] test | main | error',
          '[s] test | main | shout',
          // subLog1
          '[v] test | main | formatted: verbose',
          '[d] test | main | formatted: debug',
          'INFO    [test] main: formatted: info',
          '[w] test | main | formatted: warning',
          '[e] test | main | formatted: error',
          '[s] test | main | formatted: shout',
          // subLog2
          '[v] test | main | init: verbose',
          '[d] test | main | init: debug',
          'INFO    [test] main: init: info',
          '[w] test | main | init: warning',
          '[e] test | main | init: error',
          '[s] test | main | init: shout',
        ]);
      });
    });

    group('null printing:', () {
      late SubLoggerWithSource subLog1;
      late SubLoggerWithSourceAndContext<String> subLog2;

      setUp(() {
        subLog1 = log.withSourceAndFormatting(
          'main',
          (message) => 'formatted: $message',
        );
        subLog2 = log.withSourceAndContext<String>(
          'main',
          (context, message) => '$context: $message',
        );
      });

      void logAll() {
        log.v('main', 'verbose');
        log.d('main', 'debug');
        log.i('main', 'info');
        log.w('main', 'warning');
        log.e('main', 'error');
        log.s('main', 'shout');

        subLog1.v('verbose');
        subLog1.d('debug');
        subLog1.i('info');
        subLog1.w('warning');
        subLog1.e('error');
        subLog1.s('shout');

        subLog2.v('init', 'verbose');
        subLog2.d('init', 'debug');
        subLog2.i('init', 'info');
        subLog2.w('init', 'warning');
        subLog2.e('init', 'error');
        subLog2.s('init', 'shout');
      }

      test('do not print', () {
        log
          ..print = null
          ..format = Logger.buildDefaultMessage;
        logAll();
        expect(buf, <String>[]);
      });

      test('print inside format', () {
        log
          ..print = null
          ..format = (level, package, source, message, error) {
            final text = Logger.buildDefaultMessage(
              level, package, source, //
              message, error,
            );
            buf.add(text);
            return '';
          };
        logAll();
        expect(buf, [
          '[v] test | main | verbose',
          '[d] test | main | debug',
          '[i] test | main | info',
          '[w] test | main | warning',
          '[e] test | main | error',
          '[s] test | main | shout',
          // subLog1
          '[v] test | main | formatted: verbose',
          '[d] test | main | formatted: debug',
          '[i] test | main | formatted: info',
          '[w] test | main | formatted: warning',
          '[e] test | main | formatted: error',
          '[s] test | main | formatted: shout',
          // subLog2
          '[v] test | main | init: verbose',
          '[d] test | main | init: debug',
          '[i] test | main | init: info',
          '[w] test | main | init: warning',
          '[e] test | main | init: error',
          '[s] test | main | init: shout',
        ]);
      });

      test('print only LogLevel.debug', () {
        log.print = null;
        log[LogLevel.debug].print = buf.add;
        logAll();
        expect(buf, [
          '[d] test | main | debug',
          // subLog1
          '[d] test | main | formatted: debug',
          // subLog2
          '[d] test | main | init: debug',
        ]);
      });

      test('print all except LogLevel.debug', () {
        log[LogLevel.debug].print = null;
        logAll();
        expect(buf, [
          '[v] test | main | verbose',
          '[i] test | main | info',
          '[w] test | main | warning',
          '[e] test | main | error',
          '[s] test | main | shout',
          // subLog1
          '[v] test | main | formatted: verbose',
          '[i] test | main | formatted: info',
          '[w] test | main | formatted: warning',
          '[e] test | main | formatted: error',
          '[s] test | main | formatted: shout',
          // subLog2
          '[v] test | main | init: verbose',
          '[i] test | main | init: info',
          '[w] test | main | init: warning',
          '[e] test | main | init: error',
          '[s] test | main | init: shout',
        ]);
      });
    });

    // The sub-logger disposal test is only possible in debug mode.
    group('disposal of sub-loggers:', () {
      var vmAvailable = false;

      setUpAll(() async {
        vmAvailable = await vmServiceAvailable();
        if (vmAvailable) {
          await gc();
        }
        print('vm service available: $vmAvailable');
      });

      test('withSource:', () async {
        const className = 'SubLoggerWithSource';

        Future<void> check() async {
          final subLog = log.withSource('main');
          expect(log.$subLoggersCount, 1);

          if (vmAvailable) {
            final classInfo = await findClass(className);
            expect(classInfo?.instancesCurrent, 1);
          }

          subLog.v('verbose');
          subLog.d('debug');
          subLog.i('info');
          subLog.w('warning');
          subLog.e('error');
          subLog.s('shout');

          expect(buf, [
            '[v] test | main | verbose',
            '[d] test | main | debug',
            '[i] test | main | info',
            '[w] test | main | warning',
            '[e] test | main | error',
            '[s] test | main | shout',
          ]);
        }

        await check();
        if (vmAvailable) {
          await gc();
          final classInfo = await findClass(className);
          expect(classInfo?.instancesCurrent, 0);
        } else {
          await forceGC(fullGcCycles: 2);
        }
        expect(log.$subLoggersCount, 0);
      });

      test('withSourceAndFormatting:', () async {
        const className = 'SubLoggerWithSource';

        Future<void> check() async {
          final subLog =
              log.withSourceAndFormatting('main', (msg) => 'formatted: $msg');
          expect(log.$subLoggersCount, 1);

          if (vmAvailable) {
            final classInfo = await findClass(className);
            expect(classInfo?.instancesCurrent, 1);
          }

          subLog.v('verbose');
          subLog.d('debug');
          subLog.i('info');
          subLog.w('warning');
          subLog.e('error');
          subLog.s('shout');

          expect(buf, [
            '[v] test | main | formatted: verbose',
            '[d] test | main | formatted: debug',
            '[i] test | main | formatted: info',
            '[w] test | main | formatted: warning',
            '[e] test | main | formatted: error',
            '[s] test | main | formatted: shout',
          ]);
        }

        await check();
        if (vmAvailable) {
          await gc();
          final classInfo = await findClass(className);
          expect(classInfo?.instancesCurrent, 0);
        } else {
          await forceGC(fullGcCycles: 2);
        }
        expect(log.$subLoggersCount, 0);
      });

      test('withSourceAndContext:', () async {
        if (!vmAvailable) return;

        const className = 'SubLoggerWithSourceAndContext';

        Future<void> check() async {
          final subLog = log.withSourceAndContext<String>(
            'main',
            (method, msg) => '$method: $msg',
          );
          expect(log.$subLoggersCount, 1);

          if (vmAvailable) {
            final classInfo = await findClass(className);
            expect(classInfo?.instancesCurrent, 1);
          }

          subLog.v('init', 'verbose');
          subLog.d('init', 'debug');
          subLog.i('init', 'info');
          subLog.w('init', 'warning');
          subLog.e('init', 'error');
          subLog.s('init', 'shout');

          expect(buf, [
            '[v] test | main | init: verbose',
            '[d] test | main | init: debug',
            '[i] test | main | init: info',
            '[w] test | main | init: warning',
            '[e] test | main | init: error',
            '[s] test | main | init: shout',
          ]);
        }

        await check();
        if (vmAvailable) {
          await gc();
          final classInfo = await findClass(className);
          expect(classInfo?.instancesCurrent, 0);
        } else {
          await forceGC(fullGcCycles: 2);
        }
        expect(log.$subLoggersCount, 0);
      });
    });
  });
}
