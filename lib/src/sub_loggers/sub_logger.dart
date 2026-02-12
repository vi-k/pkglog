part of '../logger.dart';

/// Base class for sub-loggers.
sealed class SubLogger {
  final Logger _logger;

  SubLogger._(this._logger, {required LogLevelBase level}) {
    _setLevel(level);
  }

  // ignore: avoid_setters_without_getters
  void _setLevel(LogLevelBase value);
}
