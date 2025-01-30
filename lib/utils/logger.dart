/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' show min;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart' as printer;
import 'package:mutex/mutex.dart';
import 'package:path_provider/path_provider.dart';

import '../l10n/app_localizations.dart';
import '../mains/main_netknights.dart';
import '../utils/app_info_utils.dart';
import '../utils/pi_mailer.dart';
import '../views/settings_view/settings_view_widgets/send_error_dialog.dart';
import 'globals.dart';
import 'riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import 'view_utils.dart';

final provider = Provider<int>((ref) => 0);

class Logger {
  /*----------- STATIC FIELDS & GETTER -----------*/
  static final Mutex _mutexWriteFile = Mutex();
  static Logger? _instance;
  static BuildContext? get _context => navigatorKey.currentContext;
  static String get _mailBody => _context != null ? AppLocalizations.of(_context!)!.errorMailBody : 'Error Log File Attached';
  static Set<String> get _mailRecipients => {
        ...globalRef?.read(settingsProvider).value?.crashReportRecipients ?? {},
        ...PrivacyIDEAAuthenticator.currentCustomization != null ? {PrivacyIDEAAuthenticator.currentCustomization!.crashRecipient} : {}
      };
  static printer.Logger print = printer.Logger(
    printer: printer.PrettyPrinter(
      methodCount: 0,
      levelColors: {
        printer.Level.debug: const printer.AnsiColor.fg(040),
      },
      colors: true,
      printEmojis: true,
    ),
  );

  static Logger get instance {
    if (_instance == null) {
      Logger._();
      _printWarning('Logger was not initialized. Using default');
    }
    return _instance!;
  }

  static GlobalKey<NavigatorState> get navigatorKey {
    if (instance._navigatorKey == null) {
      _printWarning('Navigator key not set. Using default');
      instance._setupNavigatorKey();
    }
    return instance._navigatorKey!;
  }

  static Future<String> getErrorLog() => instance._getErrorLog();

  Future<String> _getErrorLog() async {
    if (_fullPath == null) return '';
    final file = File(_fullPath!);
    return file.readAsString();
  }

  /*----------- INSTANCE MEMBER & GETTER/SETTER -----------*/
  Function? _appRunner;
  Widget? _app;
  String _lastError = 'No error Message';
  GlobalKey<NavigatorState>? _navigatorKey;
  String? _logPath;
  bool _enableLoggingToFile = false;
  bool _flutterIsRunning = false;

  String get _filename => 'logfile.txt';
  String? get _fullPath => _logPath != null ? '$_logPath/$_filename' : null;
  static bool _verboseLogging = false;

  static void setVerboseLogging(bool value) => _verboseLogging = value;

  bool get logfileHasContent {
    if (_fullPath == null) return false;
    return (File(_fullPath!).existsSync()) && (File(_fullPath!).lengthSync() > 0);
  }

  /*----------- CONSTRUCTORS/FACTORIES -----------*/

  Logger._({Function? appRunner, Widget? app, GlobalKey<NavigatorState>? navigatorKey})
      : _appRunner = appRunner,
        _app = app,
        _navigatorKey = navigatorKey {
    if (_instance != null) {
      _printWarning('Logger already initialized. Using existing instance');
      return;
    } else {
      _instance = this;
    }

    _setupLogger().then((_) {
      if (_flutterIsRunning) _enableLoggingToFile = true;
      _print('Logger initialized${_enableLoggingToFile ? '\nLogging to File is Enabled now.' : ''}');
    });
  }

  // To enable logging to file, the app needs to be initialized with an appRunner or an app widget
  factory Logger.init({Function? appRunner, Widget? app, GlobalKey<NavigatorState>? navigatorKey}) {
    if (appRunner == null && app == null) {
      throw Exception('Logger.init() must be called with either a callback or an app Widget');
    }
    return Logger._(appRunner: appRunner, app: app, navigatorKey: navigatorKey);
  }

  /*----------- LOGGING METHODS -----------*/

  static void info(String message, {dynamic error, StackTrace? stackTrace, String? name, bool verbose = false}) =>
      instance._logInfo(message, stackTrace: stackTrace, name: name, verbose: verbose);

  void _logInfo(String message, {dynamic stackTrace, String? name, bool verbose = false}) {
    if (_verboseLogging == false && kDebugMode == false && verbose == false) return;
    String infoString = _convertLogToSingleString(
      message,
      stackTrace: stackTrace,
      name: name ?? _getCallerMethodName(depth: 2),
      logLevel: LogLevel.INFO,
    );
    infoString = _textFilter(infoString);
    if (_verboseLogging || verbose) {
      _logToFile(infoString);
    }
    _print(infoString);
  }

  static void warning(String message, {dynamic error, StackTrace? stackTrace, String? name, bool verbose = false}) =>
      instance._logWarning(message, error: error, stackTrace: stackTrace, name: name, verbose: verbose);

  void _logWarning(String message, {dynamic error, StackTrace? stackTrace, String? name, bool verbose = false}) {
    if (_verboseLogging == false && kDebugMode == false && verbose == false) return;
    String warningString = _convertLogToSingleString(
      message,
      error: error,
      stackTrace: stackTrace,
      name: name ?? _getCallerMethodName(depth: 2),
      logLevel: LogLevel.WARNING,
    );
    warningString = _textFilter(warningString);
    if (_verboseLogging || verbose) {
      instance._logToFile(warningString);
    }
    _printWarning(warningString);
  }

  /// Does nothing if in production/release mode
  static void debug(String message, {dynamic error, StackTrace? stackTrace, String? name, bool verbose = false}) {
    if (!kDebugMode) return;
    instance._logDebug(message, error: error, stackTrace: stackTrace, name: name, verbose: verbose);
  }

  void _logDebug(String message, {dynamic error, StackTrace? stackTrace, String? name, bool verbose = false}) {
    if (_verboseLogging == false && kDebugMode == false && verbose == false) return;
    if (stackTrace != null) {
      log('Stacktrace is not supported in debug mode');
    }
    String debugString = instance._convertLogToSingleString(
      message,
      stackTrace: stackTrace ?? ((_verboseLogging || verbose) ? StackTrace.current : null),
      name: name ?? _getCallerMethodName(depth: 2),
      logLevel: LogLevel.DEBUG,
    );
    debugString = _textFilter(debugString);
    if (_verboseLogging || verbose) {
      instance._logToFile(debugString);
    }
    _printDebug(debugString);
  }

  static void error(String? message, {dynamic error, dynamic stackTrace, String? name}) =>
      instance._logError(message, error: error, stackTrace: stackTrace, name: name);

  void _logError(String? message, {dynamic error, dynamic stackTrace, String? name}) {
    String errorString = _convertLogToSingleString(
      message,
      error: error,
      stackTrace: stackTrace,
      name: name ?? _getCallerMethodName(depth: 2),
      logLevel: LogLevel.ERROR,
    );
    errorString = _textFilter(errorString);
    if (message != null) {
      _lastError = message.substring(0, min(message.length, 100));
    } else if (error != null) {
      _lastError = error.toString().substring(0, min(error.toString().length, 100));
    }
    _logToFile(errorString);
    _showErrorSnackbar();
    StackTrace? stackTraceObject;
    if (stackTrace is StackTrace) {
      stackTraceObject = stackTrace;
    } else if (stackTrace is String) {
      stackTraceObject = StackTrace.fromString(stackTrace);
    }
    _printError(message, error: error, stackTrace: stackTraceObject, name: name);
  }

  Future<void> _logToFile(String fileMessage) async {
    if (_enableLoggingToFile == false) return;
    await _mutexWriteFile.acquire();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_filename');

    try {
      fileMessage = _textFilter(fileMessage);
      await file.writeAsString('\n$fileMessage', mode: FileMode.append);
    } catch (e) {
      _printError(e.toString());
    }
    _mutexWriteFile.release();
  }

  static void sendErrorLog([String? message]) {
    instance._sendErrorLog(message);
  }

  Future<bool> _sendErrorLog([String? message]) {
    if (_fullPath == null || kIsWeb) return Future.value(false);
    final File file = File(_fullPath!);
    if (!file.existsSync() || file.lengthSync() == 0) {
      return Future.value(false);
    }
    String deviceInfo = InfoUtils.deviceInfoString;

    final completeMailBody = """${message ?? _mailBody}
---------------------------------------------------------

Device Parameters $deviceInfo""";
    return PiMailer.sendMail(
      mailRecipients: _mailRecipients,
      subjectPrefix: PrivacyIDEAAuthenticator.currentCustomization?.crashSubjectPrefix,
      subject: _lastError,
      body: completeMailBody,
      attachments: [_fullPath!],
    );
  }

  static void clearErrorLog() {
    instance._clearLog();
  }

  Future<void> _clearLog() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_filename');
    await file.writeAsString('', mode: FileMode.write);
    showSnackBar(_context != null ? AppLocalizations.of(_context!)!.errorLogCleared : 'Error Log Cleared');
  }

  /*----------- SETUPS -----------*/

  Future<void> _setupLogger() async {
    await _setupErrorHooks();
    _setupNavigatorKey();
    await _setupLogPath();
  }

  void _runZonedGuarded() {
    if (_appRunner == null && _app == null) {
      // WidgetsFlutterBinding.ensureInitialized();
      return;
    }
    runZonedGuarded<void>(
      () {
        if (_appRunner != null) {
          _appRunner!();
          _flutterIsRunning = true;
        } else if (_app != null) {
          runApp(_app!);
          _flutterIsRunning = true;
        }
      },
      (e, stack) {
        error('Uncaught Error: $e', error: e, stackTrace: stack);
      },
    );
    WidgetsFlutterBinding.ensureInitialized();
  }

  // Has no effect if _navigatorKey is already set
  void _setupNavigatorKey([GlobalKey<NavigatorState>? navigatorKey]) {
    _navigatorKey ??= navigatorKey ?? GlobalKey<NavigatorState>();
  }

  Future<void> _setupLogPath() async {
    if (_flutterIsRunning == false) return;
    final directory = await getApplicationDocumentsDirectory();
    _logPath = directory.path;
  }

  Future<void> _setupErrorHooks() async {
    FlutterError.onError = (FlutterErrorDetails details) async {
      error('Uncaught Error: ${details.exception}', error: details.exception, stackTrace: details.stack ?? StackTrace.current);
    };

    /// Web doesn't support Isolate.current.addErrorListener
    if (!kIsWeb) {
      Isolate.current.addErrorListener(
        RawReceivePort((dynamic pair) async {
          final isolateError = pair as List<dynamic>;
          error(
            'Uncaught Error: ${isolateError.first.toString()}',
            error: isolateError.first.toString(),
            stackTrace: isolateError.length >= 2 && isolateError[1] != null && isolateError[1].toString() != '' ? isolateError[1] : StackTrace.current,
          );
        }).sendPort,
      );
    }
    _runZonedGuarded();
  }

  /*----------- PRINTS -----------*/

  static void _print(String message) {
    if (!kDebugMode) return; // add \n every 1000 characters only if the line is longer than 1000 characters
    message = message.replaceAllMapped(RegExp(r'.{1000}'), (match) => '${match.group(0)}\n');
    print.i(message);
  }

  static void _printDebug(String message) {
    if (!kDebugMode) return;
    // add \n every 1000 characters only if the line is longer than 1000 characters
    message = message.replaceAllMapped(RegExp(r'.{1000}'), (match) => '${match.group(0)}\n');
    print.d(message);
  }

  static void _printWarning(String message) {
    if (!kDebugMode) return; // add \n every 1000 characters only if the line is longer than 1000 characters
    message = message.replaceAllMapped(RegExp(r'.{1000}'), (match) => '${match.group(0)}\n');
    print.w(message);
  }

  static void _printError(String? message, {dynamic error, StackTrace? stackTrace, String? name}) {
    if (!kDebugMode) return;
    var message0 = DateTime.now().toString();
    message0 += name != null ? ' [$name]\n' : '\n';
    message = message?.replaceAllMapped(RegExp(r'.{1000}'), (match) => '${match.group(0)}\n');
    // add \n every 1000 characters only if the line is longer than 1000 characters
    message0 += message ?? '';
    print.e(message0, error: error, stackTrace: stackTrace);
  }

  /*----------- DISPLAY OUTPUTS -----------*/

  void _showErrorSnackbar() {
    if (_flutterIsRunning == false) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalSnackbarKey.currentState?.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            _context != null ? AppLocalizations.of(_context!)!.unexpectedError : 'An unexpected error occurred.',
          ),
          action: _context != null
              ? SnackBarAction(
                  label: AppLocalizations.of(_context!)!.showDetails,
                  onPressed: () {
                    _showDialog();
                  },
                )
              : null,
        ),
      );
    });
  }

  void _showDialog() {
    if (_flutterIsRunning == false) return;
    if (_context == null) return;
    showDialog(
      context: _context!,
      builder: (context) => const SendErrorDialog(),
      useRootNavigator: false,
    );
  }

  /*----------- HELPER -----------*/

  static String _textFilter(String text) {
    for (var key in filterParameterKeys) {
      // It searches for the key, ignores following characters until it finds base64 caracters (plus padding and separator) and replaces it with "******"
      final regex = RegExp(r'(?<=' + key + r'[^A-Z0-9+/=,]*)[A-Z0-9+/=,:_-]+', caseSensitive: false);
      text = text.replaceAll(regex, '******');
    }
    return text;
  }

  String _convertLogToSingleString(String? message, {dynamic error, StackTrace? stackTrace, String? name, LogLevel logLevel = LogLevel.INFO}) {
    String fileMessage = '${DateTime.now().toString()}';
    fileMessage += name != null ? ' [$name]\n' : '\n';
    fileMessage += message ?? '';
    fileMessage += error != null ? '\nError: $error' : '';
    fileMessage += stackTrace != null ? '\nStacktrace:\n$stackTrace' : '';

    List<String> lineSeparatedStrings = fileMessage.split("\n");
    fileMessage = '';
    for (var i = 0; i < lineSeparatedStrings.length; i++) {
      final line = lineSeparatedStrings[i];
      final nextLine = lineSeparatedStrings.length > i + 1 ? lineSeparatedStrings[i + 1] : null;
      if (line != 'null' && line != '') fileMessage += '[${logLevel.name}] $line';
      if (nextLine != null && nextLine != 'null' && nextLine != '') fileMessage += '\n';
    }
    return fileMessage;
  }

  static String? _getCallerMethodName({int depth = 1}) => _getCurrentMethodName(deph: depth + 1);
  static String? _getCurrentMethodName({int deph = 1}) {
    final frames = StackTrace.current.toString().split('\n');
    final frame = frames.elementAtOrNull(deph + 1);
    if (frame == null) return null;
    final entry = frame.split(' ');
    final methodName = entry.elementAtOrNull(entry.length - 2);
    if (methodName == 'closure>') return RegExp(r'(?<=\s\s)\w+.*(?=\s\()').firstMatch(frame)?.group(0);
    return methodName;
  }
}

final filterParameterKeys = ['fbtoken', 'new_fb_token', 'secret'];

enum LogLevel {
  INFO,
  DEBUG,
  WARNING,
  ERROR,
}
