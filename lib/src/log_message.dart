part of 'logger.dart';

/// Context for a log message.
///
/// [level] is the log level.
/// [package] is the name of the package.
/// [source] is the source of the log message.
/// [message] is the log message.
/// [error] is the error object.
base class LogMessage {
  LogMessage(
    this.level,
    this.package,
    this.source,
    this.message,
    this.error,
  );

  final Level level;
  final String package;
  final String? source;
  final String message;
  final LogError? error;

  String get text => toString();
  String? _text;
  set text(String value) {
    _text = value;
  }

  /// Builds the default log message.
  @override
  String toString() => _text ??= '[${level.shortName}] $package |'
      '${source == null ? '' : ' $source |'}'
      ' $message'
      '${error == null ? '' : ': $error'}';
}

typedef LogMessageBuilder = LogMessage Function(
  Level level,
  String package,
  String? source,
  String message,
  LogError? error,
);
