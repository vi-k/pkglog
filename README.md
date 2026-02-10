# pkglog

> [!WARNING]
> This README was written by AI.

A lightweight, flexible logger designed specifically for Dart packages.

`pkglog` provides a simple yet powerful logging abstraction for library
authors. It allows you to instrument your package with logging capabilities
while giving the consumer of your package full control over how those logs are
handled, filtered, and formatted.

## Features

- **Zero configuration defaults**: Works out of the box with `print`.
- **Granular control**: Configure logging levels per logger.
- **Flexible formatting**: Custom formatters for messages.
- **Sub-loggers**: Create context-aware loggers with bound sources or
  parameters.
- **Efficient**: Log messages are not evaluated if the log level is not enabled.
- **Safe**: Handles exceptions during logging gracefully.

## Usage

### Basic Usage

Create a `Logger` instance for your package. It is recommended to keep a static
or final instance to reuse it throughout your package.

```dart
import 'package:pkglog/pkglog.dart';

// Create a logger for your package
final logger = Logger('my_package', level: LogLevel.all);

void main() {
  logger.v('Verbose message');
  logger.d('Debug message');
  logger.i('Info message');
  logger.w('Warning message');
  logger.e('Error message');
  logger.s('Shout message');
}
```

### Log Levels

You can control which messages are logged by setting the `level`. The available levels are:
*   `verbose` (v)
*   `debug` (d)
*   `info` (i)
*   `warning` (w)
*   `error` (e)
*   `shout` (s)

To disable logging, set the level to `LogLevel.off`.

```dart
// Only show warnings and above
logger.level = LogLevel.warning;

logger.i('This will not be printed');
logger.w('This will be printed');
```

### Custom Formatting

You can define how messages are formatted and printed. The formatter receives
the level, package name, source (optional), message, error (optional), and
stack trace.

```dart
logger.format = (level, package, source, message, error, stackTrace) {
  final timestamp = DateTime.now().toIso8601String();
  return '$timestamp [${level.shortName}] $package: $message';
};
```

You can also customize the printer (defaults to `print`):

```dart
logger.print = (text) => stderr.writeln(text);
```

### Sub-loggers

Sub-loggers allow you to create loggers that are attached to a specific source
or context, inheriting the configuration of the parent logger.

#### With Source

Use `withSource` to create a logger that automatically tags messages with
a source name.

```dart
final dbLogger = logger.withSource('Database');
dbLogger.i('Connection established');
// Output: [i] my_package | Database | Connection established
```

#### Pre-formatting

Use `withSourceAndFormatting` to apply specific formatting logic to messages
from a sub-logger.

```dart
final jsonLogger = logger.withSourceAndFormatting(
  'JSON',
  (message) => 'JSON -> $message',
);
```

#### Parameterized

You can create loggers that accept a typed parameter for structured logging.
This is useful for logging events related to specific IDs or objects.

```dart
final requestLogger = logger.withSourceAndParam<int>(
  'Request',
  (id, message) => '[$id] $message',
);

requestLogger.i(101, 'Processing started');
// Output: [i] my_package | Request | [101] Processing started
```
