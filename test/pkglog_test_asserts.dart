import 'package:pkglog/pkglog.dart';

final class TestFailure implements Exception {
  final String message;

  TestFailure(this.message);
}

/// Asserts cannot be disabled in tests, so you check them by running them
/// separately via `dart run`:
///
/// ```
/// dart run test/pkglog_test_asserts.dart
/// dart run --enable-asserts test/pkglog_test_asserts.dart
/// ```
void main() {
  var assertsEnabled = false;

  assert(() {
    assertsEnabled = true;
    return true;
  }());

  print(
    'asserts ${assertsEnabled //
        ? '\x1B[32menabled\x1B[0m' : '\x1B[31mdisabled\x1B[0m'}\n',
  );

  final buf = <String>[];
  final log = Logger('test', level: LogLevel.all)..print = buf.add;
  var counter = 0;

  String Function() checkCalc(String msg) => () {
        counter++;
        return msg;
      };

  void logAll() {
    assert(log.v('main', 'verbose'));
    assert(log.d('main', 'debug'));
    assert(log.i('main', 'info'));
    assert(log.w('main', 'warning'));
    assert(log.e('main', 'error'));
    assert(log.s('main', 'shout'));
  }

  void verificationOfParameterCalculation() {
    counter = 0;
    assert(log.v(checkCalc('main'), checkCalc('verbose')));
    assert(log.d(checkCalc('main'), checkCalc('debug')));
    assert(log.i(checkCalc('main'), checkCalc('info')));
    assert(log.w(checkCalc('main'), checkCalc('warning')));
    assert(log.e(checkCalc('main'), checkCalc('error')));
    assert(log.s(checkCalc('main'), checkCalc('shout')));
  }

  void test(String name, void Function() callback) {
    buf.clear();
    try {
      callback();
      print('$name \x1B[32mpassed\x1B[0m');
    } on TestFailure catch (e) {
      print('$name \x1B[31mfailed: ${e.message}\x1B[0m');
    }
  }

  void expectList(List<String> actual, List<String> expected) {
    final length = actual.length;
    if (expected.length != length) {
      throw TestFailure('Expected $length items, but got ${expected.length}');
    }

    for (var i = 0; i < length; i++) {
      if (actual[i] != expected[i]) {
        throw TestFailure('Expected ${expected[i]}, but got ${actual[i]}');
      }
    }
  }

  void expect<T>(T actual, T expected) {
    if (actual != expected) {
      throw TestFailure('Expected $expected, but got $actual');
    }
  }

  List<String> whenAssertsEnabled(List<String> expected) =>
      assertsEnabled ? expected : <String>[];

  test('all levels', () {
    log.level = LogLevel.all;
    logAll();

    expectList(
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
    print('result for LogLevel.all:\n${buf.isEmpty ? '-' : buf.join('\n')}');

    verificationOfParameterCalculation();
    print('counter: $counter');
    expect(counter, assertsEnabled ? 12 : 0);

    print('');
  });

  test('verbose level', () {
    log.level = LogLevel.verbose; // == LogLevel.all
    logAll();
    expectList(
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
    expectList(
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
    expectList(
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
    expectList(
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
    expectList(
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
    expectList(
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
    expectList(buf, <String>[]);
    verificationOfParameterCalculation();
    expect(counter, assertsEnabled ? 0 : 0);
  });
}
