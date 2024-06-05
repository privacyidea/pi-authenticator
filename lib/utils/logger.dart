// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart' as printer;
import 'package:mutex/mutex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/utils/app_info_utils.dart';
import 'package:privacyidea_authenticator/utils/pi_mailer.dart';

import '../views/settings_view/settings_view_widgets/send_error_dialog.dart';
import 'globals.dart';
import 'riverpod_providers.dart';

final provider = Provider<int>((ref) => 0);

class Logger {
  /*----------- STATIC FIELDS & GETTER -----------*/
  static final Mutex _mutexWriteFile = Mutex();
  static Logger? _instance;
  static BuildContext? get _context => navigatorKey.currentContext;
  static String get _mailBody => _context != null ? AppLocalizations.of(_context!)!.errorMailBody : 'Error Log File Attached';
  static printer.Logger print = printer.Logger(
    printer: printer.PrettyPrinter(
      methodCount: 0,
      colors: true,
      printEmojis: true,
      printTime: false,
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

  /*----------- INSTANCE MEMBER & GETTER -----------*/
  Function? _appRunner;
  Widget? _app;
  String _lastError = 'No error Message';
  GlobalKey<NavigatorState>? _navigatorKey;
  String? _logPath;
  bool _enableLoggingToFile = false;
  bool _flutterIsRunning = false;

  String get _filename => 'logfile.txt';
  String? get _fullPath => _logPath != null ? '$_logPath/$_filename' : null;
  bool get _verbose {
    if (globalRef == null) return false;
    return globalRef!.read(settingsProvider).verboseLogging;
  }

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

  void logInfo(String message, {String? name, bool verbose = false}) {
    String infoString = _convertLogToSingleString(message, name: name, logLevel: LogLevel.INFO);
    infoString = _textFilter(infoString);
    if (_verbose || verbose) {
      _logToFile(infoString);
    }
    _print(infoString);
  }

  static void info(String message, {dynamic error, dynamic stackTrace, String? name, bool verbose = false}) =>
      instance.logInfo(message, name: name, verbose: verbose);

  void logWarning(String message, {dynamic error, dynamic stackTrace, String? name, bool verbose = false}) {
    String warningString = _convertLogToSingleString(message, error: error, stackTrace: stackTrace, name: name, logLevel: LogLevel.WARNING);
    warningString = _textFilter(warningString);
    if (instance._verbose || verbose) {
      instance._logToFile(warningString);
    }
    _printWarning(warningString);
  }

  static void warning(String message, {dynamic error, dynamic stackTrace, String? name, bool verbose = false}) =>
      instance.logWarning(message, error: error, stackTrace: stackTrace, name: name, verbose: verbose);

  void logError(String? message, {dynamic error, dynamic stackTrace, String? name}) {
    String errorString = _convertLogToSingleString(message, error: error, stackTrace: stackTrace, name: name, logLevel: LogLevel.ERROR);
    errorString = _textFilter(errorString);
    if (message != null) {
      _lastError = message.substring(0, min(message.length, 100));
    } else if (error != null) {
      _lastError = error.toString().substring(0, min(error.toString().length, 100));
    }
    _logToFile(errorString);
    _showSnackbar();
    StackTrace? stackTraceObject;
    if (stackTrace is StackTrace) {
      stackTraceObject = stackTrace;
    } else if (stackTrace is String) {
      stackTraceObject = StackTrace.fromString(stackTrace);
    }
    _printError(message, error: error, stackTrace: stackTraceObject, name: name);
  }

  static void error(String? message, {dynamic error, dynamic stackTrace, String? name}) =>
      instance.logError(message, error: error, stackTrace: stackTrace, name: name);

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
    } finally {
      _print('Message logged into file');
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
    String deviceInfo = AppInfoUtils.deviceInfoString;

    final completeMailBody = """${message ?? _mailBody}
---------------------------------------------------------

Device Parameters $deviceInfo""";

    return PiMailer.sendMail(subject: _lastError, body: completeMailBody, attachments: [_fullPath!]);
  }

  static void clearErrorLog() {
    instance._clearLog();
  }

  Future<void> _clearLog() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_filename');
    await file.writeAsString('', mode: FileMode.write);
    globalSnackbarKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          _context != null ? AppLocalizations.of(_context!)!.errorLogCleared : 'Error Log Cleared',
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
      ),
    );
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
    if (!kDebugMode) return;
    print.i(message);
  }

  static void _printWarning(String message) {
    if (!kDebugMode) return;
    print.w(message);
  }

  static void _printError(String? message, {dynamic error, StackTrace? stackTrace, String? name}) {
    if (!kDebugMode) return;
    var message0 = DateTime.now().toString();
    message0 += name != null ? ' [$name]\n' : '\n';
    message0 += message ?? '';
    print.e(message0, error: error, stackTrace: stackTrace);
  }

  /*----------- DISPLAY OUTPUTS -----------*/

  void _showSnackbar() {
    if (_flutterIsRunning == false) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalSnackbarKey.currentState?.showSnackBar(
        SnackBar(
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
      final regex = RegExp(r'(?<=' + key + r'[^A-Z0-9+/=,]*)[A-Z0-9+/=,]+', caseSensitive: false);
      text = text.replaceAll(regex, '******');
    }
    return text;
  }

  String _convertLogToSingleString(String? message, {dynamic error, dynamic stackTrace, String? name, LogLevel logLevel = LogLevel.INFO}) {
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
}

final filterParameterKeys = ['fbtoken', 'new_fb_token', 'secret'];

enum LogLevel {
  INFO,
  WARNING,
  ERROR,
}
