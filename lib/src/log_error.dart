part of 'logger.dart';

/// An error and a stack trace.
final class LogError implements Error {
  final Object error;

  @override
  final StackTrace stackTrace;

  LogError._(this.error, this.stackTrace);

  @override
  String toString() =>
      '$error${stackTrace == StackTrace.empty ? '' : '\n$stackTrace'}';
}
