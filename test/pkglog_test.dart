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
      log = Logger('test', minLevel: MinLevel.all)
        ..print = (msg) => buf.add(msg.text);
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
          log.critical('main', 'critical');
        }

        void verificationOfParameterCalculation() {
          log.v(checkCalc('main'), checkCalc('verbose'));
          log.d(checkCalc('main'), checkCalc('debug'));
          log.i(checkCalc('main'), checkCalc('info'));
          log.w(checkCalc('main'), checkCalc('warning'));
          log.e(checkCalc('main'), checkCalc('error'));
          log.critical(checkCalc('main'), checkCalc('critical'));
        }

        test('all levels', () {
          log.minLevel = MinLevel.all;
          logAll();
          expect(buf, [
            '[v] test | main | verbose',
            '[d] test | main | debug',
            '[i] test | main | info',
            '[w] test | main | warning',
            '[e] test | main | error',
            '[!] test | main | critical',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 12);
        });

        test('verbose level', () {
          log.minLevel = MinLevel.verbose; // == Level.all
          logAll();
          expect(buf, [
            '[v] test | main | verbose',
            '[d] test | main | debug',
            '[i] test | main | info',
            '[w] test | main | warning',
            '[e] test | main | error',
            '[!] test | main | critical',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 12);
        });

        test('debug level', () {
          log.minLevel = MinLevel.debug;
          logAll();
          expect(buf, [
            '[d] test | main | debug',
            '[i] test | main | info',
            '[w] test | main | warning',
            '[e] test | main | error',
            '[!] test | main | critical',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 10);
        });

        test('info level', () {
          log.minLevel = MinLevel.info;
          logAll();
          expect(buf, [
            '[i] test | main | info',
            '[w] test | main | warning',
            '[e] test | main | error',
            '[!] test | main | critical',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 8);
        });

        test('warning level', () {
          log.minLevel = MinLevel.warning;
          logAll();
          expect(buf, [
            '[w] test | main | warning',
            '[e] test | main | error',
            '[!] test | main | critical',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 6);
        });

        test('error level', () {
          log.minLevel = MinLevel.error;
          logAll();
          expect(buf, [
            '[e] test | main | error',
            '[!] test | main | critical',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 4);
        });

        test('critical level', () {
          log.minLevel = MinLevel.critical;
          logAll();
          expect(buf, [
            '[!] test | main | critical',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 2);
        });

        test('off', () {
          log.minLevel = MinLevel.off;
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
          assert(log.critical('main', 'critical'));
        }

        void verificationOfParameterCalculation() {
          assert(log.v(checkCalc('main'), checkCalc('verbose')));
          assert(log.d(checkCalc('main'), checkCalc('debug')));
          assert(log.i(checkCalc('main'), checkCalc('info')));
          assert(log.w(checkCalc('main'), checkCalc('warning')));
          assert(log.e(checkCalc('main'), checkCalc('error')));
          assert(log.critical(checkCalc('main'), checkCalc('critical')));
        }

        List<String> whenAssertsEnabled(List<String> expected) =>
            assertsEnabled ? expected : <String>[];

        test('all levels', () {
          log.minLevel = MinLevel.all;
          logAll();
          expect(
            buf,
            whenAssertsEnabled([
              '[v] test | main | verbose',
              '[d] test | main | debug',
              '[i] test | main | info',
              '[w] test | main | warning',
              '[e] test | main | error',
              '[!] test | main | critical',
            ]),
          );
          verificationOfParameterCalculation();
          expect(counter, assertsEnabled ? 12 : 0);
        });

        test('verbose level', () {
          log.minLevel = MinLevel.verbose; // == Level.all
          logAll();
          expect(
            buf,
            whenAssertsEnabled([
              '[v] test | main | verbose',
              '[d] test | main | debug',
              '[i] test | main | info',
              '[w] test | main | warning',
              '[e] test | main | error',
              '[!] test | main | critical',
            ]),
          );
          verificationOfParameterCalculation();
          expect(counter, assertsEnabled ? 12 : 0);
        });

        test('debug level', () {
          log.minLevel = MinLevel.debug;
          logAll();
          expect(
            buf,
            whenAssertsEnabled([
              '[d] test | main | debug',
              '[i] test | main | info',
              '[w] test | main | warning',
              '[e] test | main | error',
              '[!] test | main | critical',
            ]),
          );
          verificationOfParameterCalculation();
          expect(counter, assertsEnabled ? 10 : 0);
        });

        test('info level', () {
          log.minLevel = MinLevel.info;
          logAll();
          expect(
            buf,
            whenAssertsEnabled([
              '[i] test | main | info',
              '[w] test | main | warning',
              '[e] test | main | error',
              '[!] test | main | critical',
            ]),
          );
          verificationOfParameterCalculation();
          expect(counter, assertsEnabled ? 8 : 0);
        });

        test('warning level', () {
          log.minLevel = MinLevel.warning;
          logAll();
          expect(
            buf,
            whenAssertsEnabled([
              '[w] test | main | warning',
              '[e] test | main | error',
              '[!] test | main | critical',
            ]),
          );
          verificationOfParameterCalculation();
          expect(counter, assertsEnabled ? 6 : 0);
        });

        test('error level', () {
          log.minLevel = MinLevel.error;
          logAll();
          expect(
            buf,
            whenAssertsEnabled([
              '[e] test | main | error',
              '[!] test | main | critical',
            ]),
          );
          verificationOfParameterCalculation();
          expect(counter, assertsEnabled ? 4 : 0);
        });

        test('critical level', () {
          log.minLevel = MinLevel.critical;
          logAll();
          expect(
            buf,
            whenAssertsEnabled([
              '[!] test | main | critical',
            ]),
          );
          verificationOfParameterCalculation();
          expect(counter, assertsEnabled ? 2 : 0);
        });

        test('off', () {
          log.minLevel = MinLevel.off;
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
          logIsEnabled && log.critical('main', 'critical');
        }

        void verificationOfParameterCalculation() {
          logIsEnabled && log.v(checkCalc('main'), checkCalc('verbose'));
          logIsEnabled && log.d(checkCalc('main'), checkCalc('debug'));
          logIsEnabled && log.i(checkCalc('main'), checkCalc('info'));
          logIsEnabled && log.w(checkCalc('main'), checkCalc('warning'));
          logIsEnabled && log.e(checkCalc('main'), checkCalc('error'));
          logIsEnabled &&
              log.critical(checkCalc('main'), checkCalc('critical'));
        }

        test('all levels', () {
          log.minLevel = MinLevel.all;
          logAll();
          expect(buf, [
            '[v] test | main | verbose',
            '[d] test | main | debug',
            '[i] test | main | info',
            '[w] test | main | warning',
            '[e] test | main | error',
            '[!] test | main | critical',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 12);
        });

        test('verbose level', () {
          log.minLevel = MinLevel.verbose; // == Level.all
          logAll();
          expect(buf, [
            '[v] test | main | verbose',
            '[d] test | main | debug',
            '[i] test | main | info',
            '[w] test | main | warning',
            '[e] test | main | error',
            '[!] test | main | critical',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 12);
        });

        test('debug level', () {
          log.minLevel = MinLevel.debug;
          logAll();
          expect(buf, [
            '[d] test | main | debug',
            '[i] test | main | info',
            '[w] test | main | warning',
            '[e] test | main | error',
            '[!] test | main | critical',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 10);
        });

        test('info level', () {
          log.minLevel = MinLevel.info;
          logAll();
          expect(buf, [
            '[i] test | main | info',
            '[w] test | main | warning',
            '[e] test | main | error',
            '[!] test | main | critical',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 8);
        });

        test('warning level', () {
          log.minLevel = MinLevel.warning;
          logAll();
          expect(buf, [
            '[w] test | main | warning',
            '[e] test | main | error',
            '[!] test | main | critical',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 6);
        });

        test('error level', () {
          log.minLevel = MinLevel.error;
          logAll();
          expect(buf, [
            '[e] test | main | error',
            '[!] test | main | critical',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 4);
        });

        test('critical level', () {
          log.minLevel = MinLevel.critical;
          logAll();
          expect(buf, [
            '[!] test | main | critical',
          ]);
          verificationOfParameterCalculation();
          expect(counter, 2);
        });

        test('off', () {
          log.minLevel = MinLevel.off;
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
          logIsEnabled && log.critical('main', 'critical');
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
          logIsEnabled &&
              log.critical(checkCalc('main'), checkCalc('critical'));
        }

        test('all levels', () {
          log.minLevel = MinLevel.all;
          logAll();
          expect(buf, <String>[]);
          verificationOfParameterCalculation();
          expect(counter, 0);
        });

        test('verbose level', () {
          log.minLevel = MinLevel.verbose; // == Level.all
          logAll();
          expect(buf, <String>[]);
          verificationOfParameterCalculation();
          expect(counter, 0);
        });

        test('debug level', () {
          log.minLevel = MinLevel.debug;
          logAll();
          expect(buf, <String>[]);
          verificationOfParameterCalculation();
          expect(counter, 0);
        });

        test('info level', () {
          log.minLevel = MinLevel.info;
          logAll();
          expect(buf, <String>[]);
          verificationOfParameterCalculation();
          expect(counter, 0);
        });

        test('warning level', () {
          log.minLevel = MinLevel.warning;
          logAll();
          expect(buf, <String>[]);
          verificationOfParameterCalculation();
          expect(counter, 0);
        });

        test('error level', () {
          log.minLevel = MinLevel.error;
          logAll();
          expect(buf, <String>[]);
          verificationOfParameterCalculation();
          expect(counter, 0);
        });

        test('critical level', () {
          log.minLevel = MinLevel.critical;
          logAll();
          expect(buf, <String>[]);
          verificationOfParameterCalculation();
          expect(counter, 0);
        });

        test('off', () {
          log.minLevel = MinLevel.off;
          logAll();
          expect(buf, <String>[]);
          verificationOfParameterCalculation();
          expect(counter, 0);
        });
      });

      group('[Sub-loggers]', () {
        group('withSource:', () {
          late LoggerWithSource subLog;

          setUp(() {
            subLog = log.withSource(checkCalc('main'));
          });

          void logAll() {
            subLog.v('verbose');
            subLog.d('debug');
            subLog.i('info');
            subLog.w('warning');
            subLog.e('error');
            subLog.critical('critical');
          }

          void verificationOfParameterCalculation() {
            subLog.v(checkCalc('verbose'));
            subLog.d(checkCalc('debug'));
            subLog.i(checkCalc('info'));
            subLog.w(checkCalc('warning'));
            subLog.e(checkCalc('error'));
            subLog.critical(checkCalc('critical'));
          }

          test('all levels', () {
            log.minLevel = MinLevel.all;
            logAll();
            expect(buf, [
              '[v] test | main | verbose',
              '[d] test | main | debug',
              '[i] test | main | info',
              '[w] test | main | warning',
              '[e] test | main | error',
              '[!] test | main | critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 7); // params calc
          });

          test('verbose level', () {
            log.minLevel = MinLevel.verbose; // == Level.all
            logAll();
            expect(buf, [
              '[v] test | main | verbose',
              '[d] test | main | debug',
              '[i] test | main | info',
              '[w] test | main | warning',
              '[e] test | main | error',
              '[!] test | main | critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 7); // params calc
          });

          test('debug level', () {
            log.minLevel = MinLevel.debug;
            logAll();
            expect(buf, [
              '[d] test | main | debug',
              '[i] test | main | info',
              '[w] test | main | warning',
              '[e] test | main | error',
              '[!] test | main | critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 6); // params calc
          });

          test('info level', () {
            log.minLevel = MinLevel.info;
            logAll();
            expect(buf, [
              '[i] test | main | info',
              '[w] test | main | warning',
              '[e] test | main | error',
              '[!] test | main | critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 5); // params calc
          });

          test('warning level', () {
            log.minLevel = MinLevel.warning;
            logAll();
            expect(buf, [
              '[w] test | main | warning',
              '[e] test | main | error',
              '[!] test | main | critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 4); // params calc
          });

          test('error level', () {
            log.minLevel = MinLevel.error;
            logAll();
            expect(buf, [
              '[e] test | main | error',
              '[!] test | main | critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 3); // params calc
          });

          test('critical level', () {
            log.minLevel = MinLevel.critical;
            logAll();
            expect(buf, [
              '[!] test | main | critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 2); // params calc
          });

          test('off', () {
            log.minLevel = MinLevel.off;
            logAll();
            expect(buf, <String>[]);
            expect(counter, 0); // source calc
            verificationOfParameterCalculation();
            expect(counter, 0); // params calc
          });
        });

        group('withFormatting:', () {
          late LoggerWithSource subLog;

          String Function() checkCalc(String msg) => () {
                counter++;
                return msg;
              };

          setUp(() {
            subLog = log
                .withSource(checkCalc('main'))
                .withFormatting((msg) => 'formatted: $msg');
          });

          void logAll() {
            subLog.v('verbose');
            subLog.d('debug');
            subLog.i('info');
            subLog.w('warning');
            subLog.e('error');
            subLog.critical('critical');
          }

          void verificationOfParameterCalculation() {
            subLog.v(checkCalc('verbose'));
            subLog.d(checkCalc('debug'));
            subLog.i(checkCalc('info'));
            subLog.w(checkCalc('warning'));
            subLog.e(checkCalc('error'));
            subLog.critical(checkCalc('critical'));
          }

          test('all levels', () {
            expect(counter, 0); // source calc
            log.minLevel = MinLevel.all;
            logAll();
            expect(buf, [
              '[v] test | main | formatted: verbose',
              '[d] test | main | formatted: debug',
              '[i] test | main | formatted: info',
              '[w] test | main | formatted: warning',
              '[e] test | main | formatted: error',
              '[!] test | main | formatted: critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 7); // params calc
          });

          test('verbose level', () {
            log.minLevel = MinLevel.verbose; // == Level.all
            logAll();
            expect(buf, [
              '[v] test | main | formatted: verbose',
              '[d] test | main | formatted: debug',
              '[i] test | main | formatted: info',
              '[w] test | main | formatted: warning',
              '[e] test | main | formatted: error',
              '[!] test | main | formatted: critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 7); // params calc
          });

          test('debug level', () {
            log.minLevel = MinLevel.debug;
            logAll();
            expect(buf, [
              '[d] test | main | formatted: debug',
              '[i] test | main | formatted: info',
              '[w] test | main | formatted: warning',
              '[e] test | main | formatted: error',
              '[!] test | main | formatted: critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 6); // params calc
          });

          test('info level', () {
            log.minLevel = MinLevel.info;
            logAll();
            expect(buf, [
              '[i] test | main | formatted: info',
              '[w] test | main | formatted: warning',
              '[e] test | main | formatted: error',
              '[!] test | main | formatted: critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 5); // params calc
          });

          test('warning level', () {
            log.minLevel = MinLevel.warning;
            logAll();
            expect(buf, [
              '[w] test | main | formatted: warning',
              '[e] test | main | formatted: error',
              '[!] test | main | formatted: critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 4); // params calc
          });

          test('error level', () {
            log.minLevel = MinLevel.error;
            logAll();
            expect(buf, [
              '[e] test | main | formatted: error',
              '[!] test | main | formatted: critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 3); // params calc
          });

          test('critical level', () {
            log.minLevel = MinLevel.critical;
            logAll();
            expect(buf, [
              '[!] test | main | formatted: critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 2); // params calc
          });

          test('off', () {
            log.minLevel = MinLevel.off;
            logAll();
            expect(buf, <String>[]);
            expect(counter, 0); // source calc
            verificationOfParameterCalculation();
            expect(counter, 0); // params calc
          });
        });

        group('withSourceAndContext:', () {
          late LoggerWithSourceAndContext<String> subLog;

          setUp(() {
            subLog = log
                .withSource(checkCalc('main'))
                .withContext((method, msg) => '$method | $msg');
          });

          void logAll() {
            subLog.v('init', 'verbose');
            subLog.d('init', 'debug');
            subLog.i('init', 'info');
            subLog.w('init', 'warning');
            subLog.e('init', 'error');
            subLog.critical('init', 'critical');
          }

          void verificationOfParameterCalculation() {
            subLog.v('init', checkCalc('verbose'));
            subLog.d('init', checkCalc('debug'));
            subLog.i('init', checkCalc('info'));
            subLog.w('init', checkCalc('warning'));
            subLog.e('init', checkCalc('error'));
            subLog.critical('init', checkCalc('critical'));
          }

          test('all levels', () {
            log.minLevel = MinLevel.all;
            logAll();
            expect(buf, [
              '[v] test | main | init | verbose',
              '[d] test | main | init | debug',
              '[i] test | main | init | info',
              '[w] test | main | init | warning',
              '[e] test | main | init | error',
              '[!] test | main | init | critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 7); // params calc
          });

          test('verbose level', () {
            log.minLevel = MinLevel.verbose; // == Level.all
            logAll();
            expect(buf, [
              '[v] test | main | init | verbose',
              '[d] test | main | init | debug',
              '[i] test | main | init | info',
              '[w] test | main | init | warning',
              '[e] test | main | init | error',
              '[!] test | main | init | critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 7); // params calc
          });

          test('debug level', () {
            log.minLevel = MinLevel.debug;
            logAll();
            expect(buf, [
              '[d] test | main | init | debug',
              '[i] test | main | init | info',
              '[w] test | main | init | warning',
              '[e] test | main | init | error',
              '[!] test | main | init | critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 6); // params calc
          });

          test('info level', () {
            log.minLevel = MinLevel.info;
            logAll();
            expect(buf, [
              '[i] test | main | init | info',
              '[w] test | main | init | warning',
              '[e] test | main | init | error',
              '[!] test | main | init | critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 5); // params calc
          });

          test('warning level', () {
            log.minLevel = MinLevel.warning;
            logAll();
            expect(buf, [
              '[w] test | main | init | warning',
              '[e] test | main | init | error',
              '[!] test | main | init | critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 4); // params calc
          });

          test('error level', () {
            log.minLevel = MinLevel.error;
            logAll();
            expect(buf, [
              '[e] test | main | init | error',
              '[!] test | main | init | critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 3); // params calc
          });

          test('critical level', () {
            log.minLevel = MinLevel.critical;
            logAll();
            expect(buf, [
              '[!] test | main | init | critical',
            ]);
            expect(counter, 1); // source calc
            verificationOfParameterCalculation();
            expect(counter, 2); // params calc
          });

          test('off', () {
            log.minLevel = MinLevel.off;
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
      late LoggerWithSource subLog1;
      late LoggerWithSourceAndContext<String> subLog2;

      setUp(() {
        final subLog = log.withSource('main');
        subLog1 = subLog.withFormatting(
          (message) => 'formatted: $message',
        );
        subLog2 = subLog.withContext<String>(
          (context, message) => '$context: $message',
        );
      });

      void logAll() {
        log.v('main', 'verbose');
        log.d('main', 'debug');
        log.i('main', 'info');
        log.w('main', 'warning');
        log.e('main', 'error');
        log.critical('main', 'critical');

        subLog1.v('verbose');
        subLog1.d('debug');
        subLog1.i('info');
        subLog1.w('warning');
        subLog1.e('error');
        subLog1.critical('critical');

        subLog2.v('init', 'verbose');
        subLog2.d('init', 'debug');
        subLog2.i('init', 'info');
        subLog2.w('init', 'warning');
        subLog2.e('init', 'error');
        subLog2.critical('init', 'critical');
      }

      test('all levels', () {
        log.format = (msg) =>
            '${msg.level.name.toUpperCase().padRight(8)} [${msg.package}]'
            ' ${msg.source == null ? '' : '${msg.source}:'}'
            ' ${msg.message}';
        logAll();
        expect(buf, [
          'VERBOSE  [test] main: verbose',
          'DEBUG    [test] main: debug',
          'INFO     [test] main: info',
          'WARNING  [test] main: warning',
          'ERROR    [test] main: error',
          'CRITICAL [test] main: critical',
          // subLog1
          'VERBOSE  [test] main: formatted: verbose',
          'DEBUG    [test] main: formatted: debug',
          'INFO     [test] main: formatted: info',
          'WARNING  [test] main: formatted: warning',
          'ERROR    [test] main: formatted: error',
          'CRITICAL [test] main: formatted: critical',
          // subLog2
          'VERBOSE  [test] main: init: verbose',
          'DEBUG    [test] main: init: debug',
          'INFO     [test] main: init: info',
          'WARNING  [test] main: init: warning',
          'ERROR    [test] main: init: error',
          'CRITICAL [test] main: init: critical',
        ]);
      });

      test('all levels except Level.info', () {
        log.format = (msg) =>
            '${msg.level.name.toUpperCase().padRight(8)} [${msg.package}]'
            ' ${msg.source == null ? '' : '${msg.source}:'}'
            ' ${msg.message}';
        log[Level.info].format = null;
        logAll();
        expect(buf, [
          'VERBOSE  [test] main: verbose',
          'DEBUG    [test] main: debug',
          '[i] test | main | info',
          'WARNING  [test] main: warning',
          'ERROR    [test] main: error',
          'CRITICAL [test] main: critical',
          // subLog1
          'VERBOSE  [test] main: formatted: verbose',
          'DEBUG    [test] main: formatted: debug',
          '[i] test | main | formatted: info',
          'WARNING  [test] main: formatted: warning',
          'ERROR    [test] main: formatted: error',
          'CRITICAL [test] main: formatted: critical',
          // subLog2
          'VERBOSE  [test] main: init: verbose',
          'DEBUG    [test] main: init: debug',
          '[i] test | main | init: info',
          'WARNING  [test] main: init: warning',
          'ERROR    [test] main: init: error',
          'CRITICAL [test] main: init: critical',
        ]);
      });

      test('only Level.info', () {
        log[Level.info].format = (msg) =>
            '${msg.level.name.toUpperCase().padRight(7)} [${msg.package}]'
            ' ${msg.source == null ? '' : '${msg.source}:'}'
            ' ${msg.message}';
        logAll();
        expect(buf, [
          '[v] test | main | verbose',
          '[d] test | main | debug',
          'INFO    [test] main: info',
          '[w] test | main | warning',
          '[e] test | main | error',
          '[!] test | main | critical',
          // subLog1
          '[v] test | main | formatted: verbose',
          '[d] test | main | formatted: debug',
          'INFO    [test] main: formatted: info',
          '[w] test | main | formatted: warning',
          '[e] test | main | formatted: error',
          '[!] test | main | formatted: critical',
          // subLog2
          '[v] test | main | init: verbose',
          '[d] test | main | init: debug',
          'INFO    [test] main: init: info',
          '[w] test | main | init: warning',
          '[e] test | main | init: error',
          '[!] test | main | init: critical',
        ]);
      });
    });

    group('null printing:', () {
      late LoggerWithSource subLog1;
      late LoggerWithSourceAndContext<String> subLog2;

      setUp(() {
        final subLog = log.withSource('main');
        subLog1 = subLog.withFormatting(
          (message) => 'formatted: $message',
        );
        subLog2 = subLog.withContext<String>(
          (context, message) => '$context: $message',
        );
      });

      void logAll() {
        log.v('main', 'verbose');
        log.d('main', 'debug');
        log.i('main', 'info');
        log.w('main', 'warning');
        log.e('main', 'error');
        log.critical('main', 'critical');

        subLog1.v('verbose');
        subLog1.d('debug');
        subLog1.i('info');
        subLog1.w('warning');
        subLog1.e('error');
        subLog1.critical('critical');

        subLog2.v('init', 'verbose');
        subLog2.d('init', 'debug');
        subLog2.i('init', 'info');
        subLog2.w('init', 'warning');
        subLog2.e('init', 'error');
        subLog2.critical('init', 'critical');
      }

      test('do not print', () {
        log
          ..print = null
          ..format = null;
        logAll();
        expect(buf, <String>[]);
      });

      test('print only Level.debug', () {
        log.print = null;
        log[Level.debug].print = (msg) => buf.add(msg.text);
        logAll();
        expect(buf, [
          '[d] test | main | debug',
          // subLog1
          '[d] test | main | formatted: debug',
          // subLog2
          '[d] test | main | init: debug',
        ]);
      });

      test('print all except Level.debug', () {
        log[Level.debug].print = null;
        logAll();
        expect(buf, [
          '[v] test | main | verbose',
          '[i] test | main | info',
          '[w] test | main | warning',
          '[e] test | main | error',
          '[!] test | main | critical',
          // subLog1
          '[v] test | main | formatted: verbose',
          '[i] test | main | formatted: info',
          '[w] test | main | formatted: warning',
          '[e] test | main | formatted: error',
          '[!] test | main | formatted: critical',
          // subLog2
          '[v] test | main | init: verbose',
          '[i] test | main | init: info',
          '[w] test | main | init: warning',
          '[e] test | main | init: error',
          '[!] test | main | init: critical',
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
        const className = 'LoggerWithSource';

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
          subLog.critical('critical');

          expect(buf, [
            '[v] test | main | verbose',
            '[d] test | main | debug',
            '[i] test | main | info',
            '[w] test | main | warning',
            '[e] test | main | error',
            '[!] test | main | critical',
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

      test('withFormatting:', () async {
        const className = 'LoggerWithSource';

        Future<void> check() async {
          final subLog = log //
              .withSource('main')
              .withFormatting((msg) => 'formatted: $msg');
          expect(log.$subLoggersCount, 2);

          if (vmAvailable) {
            final classInfo1 = await findClass(className);
            expect(classInfo1?.instancesCurrent, 2);
            await gc();
            final classInfo2 = await findClass(className);
            expect(classInfo2?.instancesCurrent, 1);
          }

          subLog.v('verbose');
          subLog.d('debug');
          subLog.i('info');
          subLog.w('warning');
          subLog.e('error');
          subLog.critical('critical');

          expect(buf, [
            '[v] test | main | formatted: verbose',
            '[d] test | main | formatted: debug',
            '[i] test | main | formatted: info',
            '[w] test | main | formatted: warning',
            '[e] test | main | formatted: error',
            '[!] test | main | formatted: critical',
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

      test('withContext:', () async {
        if (!vmAvailable) return;

        const className = 'LoggerWithSourceAndContext';

        Future<void> check() async {
          final subLog = log //
              .withSource('main')
              .withContext<String>(
                (method, msg) => '$method: $msg',
              );
          expect(log.$subLoggersCount, 2);

          if (vmAvailable) {
            final classInfo = await findClass(className);
            expect(classInfo?.instancesCurrent, 1);
          }

          subLog.v('init', 'verbose');
          subLog.d('init', 'debug');
          subLog.i('init', 'info');
          subLog.w('init', 'warning');
          subLog.e('init', 'error');
          subLog.critical('init', 'critical');

          expect(buf, [
            '[v] test | main | init: verbose',
            '[d] test | main | init: debug',
            '[i] test | main | init: info',
            '[w] test | main | init: warning',
            '[e] test | main | init: error',
            '[!] test | main | init: critical',
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
