# TODO

- Добавить в README секцию "Common Mistakes" с наглядными примерами:
  log.i('expensive: ${compute()}'); // плохо (вычисляется всегда)
  log.i(() => 'expensive: ${compute()}'); // хорошо
  Добавить lint rule в analysis_options.yaml пакета? (сложно, но можно
  попробовать через custom lint).

- посмотреть, как работает @pragma('vm:prefer-inline')

- Добавить пресеты конфигурации:
  abstract final class PkglogPresets {
    /// Только ошибки в stderr
    static void errorsOnly(Logger log) {
      log.level = Level.error;
      log[Level.error].print = stderr.writeln;
      log[Level.critical].print = stderr.writeln;
    }

    /// Цветной вывод (если есть ansi_escape_codes)
    static void colored(Logger log) {
        // тот самый код из примера
    }

    /// Полная тишина
    static void silent(Logger log) => log.level = Level.off;
  }

- Добавить в README раздел "Частые сценарии":
  Как логировать в файл (синхронно).
  Как добавить timestamp.
  Как покрасить логи (расширить пример с ansi_escape_codes).
  Как интегрировать с riverpod/provider (для Flutter-библиотек).
  Как тестировать код с логгером.

- Написать в README про доп. тесты для asserts.
