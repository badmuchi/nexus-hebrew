import 'dart:developer' as developer;

import '../error/failures.dart';

enum LogLevel {
  debug(500, 'DEBUG'),
  info(800, 'INFO'),
  warning(900, 'WARN'),
  error(1000, 'ERROR');

  final int severity;
  final String label;

  const LogLevel(this.severity, this.label);
}

abstract interface class AppLogger {
  void debug(String tag, String message);
  void info(String tag, String message);
  void warning(String tag, String message, {Failure? failure});
  void error(
    String tag,
    String message, {
    Failure? failure,
    String? errorDetails,
    StackTrace? stackTrace,
  });
}

final class DeveloperAppLogger implements AppLogger {
  final String _appName;

  const DeveloperAppLogger({String appName = 'NexusHebrew'})
      : _appName = appName;

  @override
  void debug(String tag, String message) {
    _emit(LogLevel.debug, tag, message);
  }

  @override
  void info(String tag, String message) {
    _emit(LogLevel.info, tag, message);
  }

  @override
  void warning(String tag, String message, {Failure? failure}) {
    final buffer = StringBuffer(message);
    if (failure != null) {
      buffer.write(' | failure=${failure.runtimeType}(${failure.message})');
    }
    _emit(LogLevel.warning, tag, buffer.toString());
  }

  @override
  void error(
    String tag,
    String message, {
    Failure? failure,
    String? errorDetails,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer(message);
    if (failure != null) {
      buffer.write(' | failure=${failure.runtimeType}(${failure.message})');
    }
    if (errorDetails != null && errorDetails.isNotEmpty) {
      buffer.write(' | details=$errorDetails');
    }
    _emit(LogLevel.error, tag, buffer.toString(), stackTrace: stackTrace);
  }

  void _emit(
    LogLevel level,
    String tag,
    String message, {
    StackTrace? stackTrace,
  }) {
    developer.log(
      '[${level.label}] [$tag] $message',
      name: _appName,
      level: level.severity,
      stackTrace: stackTrace,
    );
  }
}

final class NoOpAppLogger implements AppLogger {
  const NoOpAppLogger();

  @override
  void debug(String tag, String message) {}

  @override
  void info(String tag, String message) {}

  @override
  void warning(String tag, String message, {Failure? failure}) {}

  @override
  void error(
    String tag,
    String message, {
    Failure? failure,
    String? errorDetails,
    StackTrace? stackTrace,
  }) {}
}
