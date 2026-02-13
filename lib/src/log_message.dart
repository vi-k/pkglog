part of 'logger.dart';

/// Context for a log message.
///
/// [level] is the log level.
/// [package] is the name of the package.
/// [source] is the source of the log message.
/// [message] is the log message.
/// [error] is the error object.
final class LogMessage {
  LogMessage(
    this.level,
    this.package,
    this.unresolvedSource,
    this.unresolvedMessage,
    this.error,
  );

  final LoggerLevel level;
  final String package;
  final Object? unresolvedSource;
  final Object? unresolvedMessage;
  final LogError? error;

  late final String? source = Logger.resolveToString(unresolvedSource);
  late final String message =
      Logger.resolveToString(unresolvedMessage) ?? 'null';

  static String defaultBuilder(LogMessage msg) => msg.toString();

  /// Builds the default log message.
  @override
  String toString() => '[${level.shortName}] $package |'
      '${source == null ? '' : ' $source |'}'
      ' $message'
      '${error == null ? '' : ': $error'}';
}

base mixin LogMessageWrapper<L extends Object> {
  @protected
  LogMessage get msg;

  L get level;

  String get package => msg.package;
  Object? get unresolvedSource => msg.unresolvedSource;
  String? get source => msg.source;
  Object? get unresolvedMessage => msg.unresolvedMessage;
  String get message => msg.message;
  Object? get error => msg.error?.error;
  StackTrace? get stackTrace => msg.error?.stackTrace;

  @override
  String toString() => msg.toString();
}
