part of '../logger.dart';

/// Base class for sub-loggers.
sealed class SubLogger {
  final Logger _logger;

  SubLogger._(this._logger, {required LogLevel? level}) {
    _level = level;
  }

  // ignore: avoid_setters_without_getters
  set _level(LogLevel? value);
}
