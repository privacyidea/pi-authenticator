// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart' as printer;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../views/settings_view/settings_view_widgets/send_error_dialog.dart';
import 'customizations.dart';
import 'riverpod_providers.dart';

final provider = Provider<int>((ref) => 0);

class Logger {
  /*----------- STATIC FIELDS & GETTER -----------*/
  static Logger? _instance;
  static BuildContext get _context => navigatorKey.currentContext!;
  static String get _mailBody => AppLocalizations.of(_context)!.errorLogFileAttached;
  static int get _lineLength => 160;
  static printer.Logger print = printer.Logger(
    printer: printer.PrettyPrinter(
      lineLength: _lineLength + 5,
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

  Future<String> get errorLog async {
    if (_fullPath == null) return '';
    final file = File(_fullPath!);
    return file.readAsString();
  }

  /*----------- INSTANCE MEMBER & GETTER -----------*/
  Function? _appRunner;
  Widget? _app;
  String _lastError = 'No error Message';
  GlobalKey<NavigatorState>? _navigatorKey;
  PackageInfo? _platformInfos;
  String? _logPath;
  bool _enableLoggingToFile = false;
  bool _flutterIsRunning = false;

  String get _mailRecipient => 'app-crash@netknights.it';
  String get _mailSubject =>
      _platformInfos != null ? '(${_platformInfos!.version}) ${_platformInfos!.appName} >>> $_lastError' : 'PrivacyIDEA Authenticator >>> $_lastError';
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

  Logger._({Function? appRunner, Widget? app})
      : _appRunner = appRunner,
        _app = app {
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
  factory Logger.init({Function? appRunner, Widget? app}) {
    if (appRunner == null && app == null) {
      throw Exception('Logger.init() must be called with either a callback or an app Widget');
    }
    return Logger._(appRunner: appRunner, app: app);
  }

  /*----------- LOGGING METHODS -----------*/

  static void info(String message, {dynamic error, dynamic stackTrace, String? name}) {
    final infoString = instance._convertLogToSingleString(message, error: error, stackTrace: stackTrace, name: name, logLevel: LogLevel.INFO);
    if (instance._verbose) {
      instance._logToFile(infoString);
    }
    _print(infoString);
  }

  static void warning(String message, {dynamic error, dynamic stackTrace, String? name}) {
    final warningString = instance._convertLogToSingleString(message, error: error, stackTrace: stackTrace, name: name, logLevel: LogLevel.WARNING);
    if (instance._verbose) {
      instance._logToFile(warningString);
    }
    _printWarning(warningString);
  }

  static void error(String? message, {dynamic error, dynamic stackTrace, String? name}) {
    final errorString = instance._convertLogToSingleString(message, error: error, stackTrace: stackTrace, name: name, logLevel: LogLevel.ERROR);
    instance._lastError = message ?? '';
    if (instance._lastError.isEmpty) {
      instance._lastError = error.toString().substring(0, 100);
    }
    instance._logToFile(errorString);
    instance._showSnackbar();
    _printError(message, error: error, stackTrace: stackTrace, name: name);
  }

  Future<void> _logToFile(String fileMessage) async {
    if (_enableLoggingToFile == false) return;
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_filename');

    try {
      fileMessage = _textFilter(fileMessage);
      await file.writeAsString(fileMessage, mode: FileMode.append);
    } catch (e) {
      _printError(e.toString());
    } finally {
      _print('Message logged into file');
    }
  }

  static void sendErrorLog() {
    instance._sendErrorLog();
  }

  Future<bool> _sendErrorLog() async {
    if (_fullPath == null) return false;
    final File file = File(_fullPath!);
    if (!file.existsSync() || file.lengthSync() == 0) {
      return false;
    }

    try {
      final MailOptions mailOptions = MailOptions(
        body: _mailBody,
        subject: _mailSubject,
        recipients: [_mailRecipient],
        attachments: [
          _fullPath!,
        ],
      );
      await FlutterMailer.send(mailOptions);
    } catch (exc, stackTrace) {
      Logger.error('Was not able to send the Email', error: exc, stackTrace: stackTrace, name: 'Logger#_sendErrorLog()');
      return false;
    }
    return true;
  }

  static void clearErrorLog() {
    instance._clearLog();
  }

  Future<void> _clearLog() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_filename');
    await file.writeAsString('', mode: FileMode.write);
    snackbarKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(_context)!.errorLogCleared),
      ),
    );
  }

  /*----------- SETUPS -----------*/

  Future<void> _setupLogger() async {
    await _setupErrorHooks();
    _setupNavigatorKey();
    await _setupPlatformInfos();
    await _setupLogPath();
  }

  void _runZonedGuarded() {
    if (_appRunner == null && _app == null) {
      WidgetsFlutterBinding.ensureInitialized();
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
        error('Uncaught Error', error: e, stackTrace: stack);
      },
    );
    WidgetsFlutterBinding.ensureInitialized();
  }

  void _setupNavigatorKey([GlobalKey<NavigatorState>? navigatorKey]) {
    _navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();
  }

  Future<void> _setupPlatformInfos() async {
    if (_flutterIsRunning == false) return;
    _platformInfos = await PackageInfo.fromPlatform();
  }

  Future<void> _setupLogPath() async {
    if (_flutterIsRunning == false) return;
    final directory = await getApplicationDocumentsDirectory();
    _logPath = directory.path;
  }

  Future<void> _setupErrorHooks() async {
    FlutterError.onError = (FlutterErrorDetails details) async {
      error('Uncaught Error', error: details.exception, stackTrace: details.stack);
    };

    /// Web doesn't support Isolate.current.addErrorListener
    if (!kIsWeb) {
      Isolate.current.addErrorListener(
        RawReceivePort((dynamic pair) async {
          final isolateError = pair as List<dynamic>;
          error(
            'Uncaught Error',
            error: isolateError.first.toString(),
            stackTrace: isolateError.last.toString(),
          );
        }).sendPort,
      );
    }
    _runZonedGuarded();
  }

  /*----------- PRINTS -----------*/

  static void _print(String message) {
    if (!kDebugMode) return;

    final messageWithShorterLines = _maxLineLengh(message);

    print.i(messageWithShorterLines);
  }

  static void _printWarning(String message) {
    if (!kDebugMode) return;
    final messageWithShorterLines = _maxLineLengh(message);
    print.w(messageWithShorterLines);
  }

  static void _printError(String? message, {dynamic error, dynamic stackTrace, String? name}) {
    if (!kDebugMode) return;
    final messageWithShorterLines = message != null ? _maxLineLengh(message) : null;
    print.e(messageWithShorterLines, error, stackTrace);
  }

  /*----------- DISPLAY OUTPUTS -----------*/

  void _showSnackbar() {
    if (_flutterIsRunning == false) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      snackbarKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(_context)!.errorOccurred),
          action: SnackBarAction(
            label: AppLocalizations.of(_context)!.showDetails,
            onPressed: () {
              _showDialog();
            },
          ),
        ),
      );
    });
  }

  void _showDialog() {
    if (_flutterIsRunning == false) return;
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => const SendErrorDialog(),
    );
  }

  /*----------- HELPER -----------*/

  static String _maxLineLengh(String text, {int? length}) {
    length ??= _lineLength;
    final lineSplittedText = StringBuffer();

    List<String> lines = text.split('\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      // Every [length] characters in [text], add an \n for a new line
      for (var j = 0; j < line.length; j += length) {
        lineSplittedText.write(line.substring(j, min<int>(j + length, line.length)));
        if (j + length < line.length) {
          lineSplittedText.write('\n');
        }
      }
      if (i < lines.length - 1) {
        lineSplittedText.write('\n');
      }
    }
    return lineSplittedText.toString();
  }

  String _textFilter(String text) {
    for (var key in filterParameterKeys) {
      final regex = RegExp(r'(?<=' + key + r':\s).+?(?=[},])');
      text = text.replaceAll(regex, '***');
    }
    return text;
  }

  String _convertLogToSingleString(String? message, {dynamic error, dynamic stackTrace, String? name, LogLevel logLevel = LogLevel.INFO}) {
    String fileMessage = '(${DateTime.now().toString()}) ${message ?? ''}';
    fileMessage += name != null ? '\n$name' : '';
    fileMessage += error != null ? '\n$error' : '';
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

final filterParameterKeys = <String>['fbtoken', 'new_fb_token'];

enum LogLevel {
  INFO,
  WARNING,
  ERROR,
}
