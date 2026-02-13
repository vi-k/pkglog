part of 'logger.dart';

/// Builds a log message.
typedef LogBuilder = String Function(LogMessage context);

/// Prints a log message.
typedef LogPrinter = void Function(String text);

void _defaultPrinter(String text) {}
const _zoneLevelTag = #pkglog_level;
const _zoneBuilderTag = #pkglog_builder;
const _zonePrinterTag = #pkglog_printer;

/// Logger for a specific [LoggerLevel].
///
/// Used for configuration:
///
/// ```dart
/// final log = Logger('my_package');
/// log[Level.info] // <- LevelLogger
///   ..builder = ...
///   ..printer = ...;
/// ```
final class LevelLogger {
  final LoggerLevel _level;

  /// Creates a new [LevelLogger].
  LevelLogger._(this._level);

  Logger? _logger;
  Logger get _requireLogger =>
      _logger ?? (throw StateError('Logger is not attached'));

  LogBuilder _builder = LogMessage.defaultBuilder;

  LogPrinter? _printer = Zone.current.print;

  LogFunction _log = _noLog;
  LogFunction get log => _log;

  bool get isEnabled {
    final zoneInstanceLevel = switch (Zone.current[(_zoneLevelTag, _logger)]) {
      final LogLevel level => level,
      _ => _level,
    };
    if (zoneInstanceLevel > _level) return false;

    final zoneCommonLevel = switch (Zone.current[_zoneLevelTag]) {
      final LogLevel level => level,
      _ => _level,
    };
    if (zoneCommonLevel > _level) return false;

    return !identical(_log, _noLog);
  }

  void _toggle(bool enabled) {
    _log = enabled ? _realLog : _noLog;
  }

  /// Sets the log builder.
  ///
  /// ```dart
  /// // Use the default message builder.
  /// log[Level.debug].builder = LogMessage.build;
  ///
  /// // Use a custom message builder.
  /// log[Level.debug].builder = (level, package, source, message, error) {
  ///   return '${level.name.toUpperCase()}: $message';
  /// };
  /// ```
  // ignore: avoid_setters_without_getters
  set builder(LogBuilder builder) {
    _builder = builder;
  }

  LogBuilder _resolveBuilder() =>
      switch (Zone.current[(_zoneBuilderTag, _logger)]) {
        final LogBuilder builder => builder,
        _ => switch (Zone.current[_zoneBuilderTag]) {
            final LogBuilder builder => builder,
            _ => _builder,
          },
      };

  /// Sets the log printer.
  ///
  /// ```dart
  /// // Use `print` by default.
  /// log[Level.debug].printer = print;
  ///
  /// // Use a custom log printer.
  /// log[Level.error].printer = stderr.writeln;
  /// log[Level.critical].printer = stderr.writeln;
  /// ```
  // ignore: avoid_setters_without_getters
  set printer(LogPrinter? printer) {
    _printer = printer;
  }

  LogPrinter? _resolvePrinter() =>
      switch (Zone.current[(_zonePrinterTag, _logger)]) {
        final LogPrinter printer => printer,
        null => switch (Zone.current[_zonePrinterTag]) {
            final LogPrinter printer => printer,
            null => _printer,
            _ => null,
          },
        _ => null,
      };

  @pragma('vm:prefer-inline')
  static bool _noLog(
    Object? source,
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      true;

  bool _realLog(
    Object? source,
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!isEnabled) return true;

    final msg = LogMessage(
      _level,
      _requireLogger.package,
      source,
      message,
      error == null
          ? null
          : LogError._(
              error,
              stackTrace ??
                  switch (error) {
                    Error(:final stackTrace?) => stackTrace,
                    _ => StackTrace.current,
                  },
            ),
    );

    final text = _resolveBuilder()(msg);
    _resolvePrinter()?.call(text);

    return true;
  }
}
