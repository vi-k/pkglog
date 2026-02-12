part of '../logger.dart';

/// Base class for sub-loggers.
sealed class SubLogger {
  final Logger _logger;

  SubLogger._(this._logger, {required MinLevel level}) {
    _setMinLevel(level);
  }

  // ignore: avoid_setters_without_getters
  void _setMinLevel(MinLevel value);
}
