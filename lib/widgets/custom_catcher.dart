/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2020 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'package:catcher/catcher.dart';
import 'package:catcher/model/platform_type.dart';
import 'package:catcher/model/report.dart';
import 'package:catcher/model/report_handler.dart';
import 'package:catcher/model/report_mode.dart';
import 'package:catcher/utils/catcher_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:logging/logging.dart';

/// Custom implementation of the [EmailManualHandler] to change the content of
/// the e-mail.
class CustomEmailManualHandler extends ReportHandler {
  final List<String> recipients;
  final bool enableDeviceParameters;
  final bool enableApplicationParameters;
  final bool enableStackTrace;
  final bool enableCustomParameters;
  final String? emailTitle;
  final String? emailHeader;
  final bool sendHtml;
  final bool printLogs;
  final Logger _logger = Logger('CustomEmailManualHandler');

  CustomEmailManualHandler(this.recipients,
      {this.enableDeviceParameters = true,
      this.enableApplicationParameters = true,
      this.enableStackTrace = true,
      this.enableCustomParameters = true,
      this.emailTitle,
      this.emailHeader,
      this.sendHtml = true,
      this.printLogs = false});

  @override
  Future<bool> handle(Report report, BuildContext? context) async {
    return _sendEmail(report);
  }

  Future<bool> _sendEmail(Report report) async {
    try {
      final MailOptions mailOptions = MailOptions(
        body: _getBody(report),
        subject: _getTitle(report),
        recipients: recipients,
        isHTML: sendHtml,
      );
      _printLog('Creating mail request');
      await FlutterMailer.send(mailOptions);
      _printLog('Creating mail request success');
      return true;
    } catch (exc, stackTrace) {
      _printLog('Exception occured: $exc stack: $stackTrace');
      return false;
    }
  }

  String _getTitle(Report report) {
    return '(${report.applicationParameters.entries.where((e) => e.key == 'version').first.value})'
        ' Error report: >> ${report.error.runtimeType}: ${report.error}<<';
  }

  String _getBody(Report report) {
    if (sendHtml) {
      return _setupHtmlMessageText(report);
    } else {
      return _setupRawMessageText(report);
    }
  }

  String _setupHtmlMessageText(Report report) {
    final StringBuffer buffer = StringBuffer();
    if (emailHeader?.isNotEmpty == true) {
      buffer.write(emailHeader);
      buffer.write('<hr><br>');
    }

    buffer.write('<h2>Error:</h2>');
    buffer.write(report.error.toString());
    buffer.write('<hr><br>');
    if (enableStackTrace) {
      buffer.write('<h2>Stack trace:</h2>');
      buffer.write(report.stackTrace.toString().replaceAll('\n', '<br>'));
      buffer.write('<hr><br>');
    }
    if (enableDeviceParameters) {
      buffer.write('<h2>Device parameters:</h2>');
      for (final entry in report.deviceParameters.entries) {
        buffer.write('<b>${entry.key}</b>: ${entry.value}<br>');
      }
      buffer.write('<hr><br>');
    }
    if (enableApplicationParameters) {
      buffer.write('<h2>Application parameters:</h2>');
      for (final entry in report.applicationParameters.entries) {
        buffer.write('<b>${entry.key}</b>: ${entry.value}<br>');
      }
      buffer.write('<br><br>');
    }
    if (enableCustomParameters) {
      buffer.write('<h2>Custom parameters:</h2>');
      for (final entry in report.customParameters.entries) {
        buffer.write('<b>${entry.key}</b>: ${entry.value}<br>');
      }
      buffer.write('<br><br>');
    }

    return buffer.toString();
  }

  String _setupRawMessageText(Report report) {
    final StringBuffer buffer = StringBuffer();
    if (emailHeader?.isNotEmpty == true) {
      buffer.write(emailHeader);
      buffer.write('\n\n');
    }

    buffer.write('Error:\n');
    buffer.write(report.error.toString());
    buffer.write('\n\n');
    if (enableStackTrace) {
      buffer.write('Stack trace:\n');
      buffer.write(report.stackTrace.toString());
      buffer.write('\n\n');
    }
    if (enableDeviceParameters) {
      buffer.write('Device parameters:\n');
      for (final entry in report.deviceParameters.entries) {
        buffer.write('${entry.key}: ${entry.value}\n');
      }
      buffer.write('\n\n');
    }
    if (enableApplicationParameters) {
      buffer.write('Application parameters:\n');
      for (final entry in report.applicationParameters.entries) {
        buffer.write('${entry.key}: ${entry.value}\n');
      }
      buffer.write('\n\n');
    }
    if (enableCustomParameters) {
      buffer.write('Custom parameters:\n');
      for (final entry in report.customParameters.entries) {
        buffer.write('${entry.key}: ${entry.value}\n');
      }
      buffer.write('\n\n');
    }

    return buffer.toString();
  }

  void _printLog(String log) {
    if (printLogs) {
      _logger.info(log);
    }
  }

  @override
  List<PlatformType> getSupportedPlatforms() =>
      [PlatformType.android, PlatformType.iOS];
}

/// Custom implementation of the [PageReportMode] to change the screens content.
class CustomPageReportMode extends ReportMode {
  @override
  void requestAction(Report report, BuildContext? context) {
    _navigateToPageWidget(report, context!);
  }

  void _navigateToPageWidget(Report report, BuildContext context) async {
    await Future<void>.delayed(Duration.zero);
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomPageWidget(this, report),
      ),
    );
  }

  @override
  bool isContextRequired() {
    return true;
  }

  @override
  List<PlatformType> getSupportedPlatforms() =>
      [PlatformType.web, PlatformType.android, PlatformType.iOS];
}

class CustomPageWidget extends StatefulWidget {
  final CustomPageReportMode pageReportMode;
  final Report report;

  const CustomPageWidget(
    this.pageReportMode,
    this.report, {
    Key? key,
  }) : super(key: key);

  @override
  CustomPageWidgetState createState() {
    return CustomPageWidgetState();
  }
}

class CustomPageWidgetState extends State<CustomPageWidget> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => CatcherUtils.isCupertinoAppAncestor(context)
          ? _buildCupertinoPage()
          : _buildMaterialPage(),
    );
  }

  Widget _buildMaterialPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.unexpectedError),
      ),
      body: _buildInnerWidget(),
    );
  }

  Widget _buildCupertinoPage() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(AppLocalizations.of(context)!.unexpectedError),
      ),
      child: SafeArea(
        child: _buildInnerWidget(),
      ),
    );
  }

  Widget _buildInnerWidget() {
    String text =
        '${widget.report.error.runtimeType}: ${widget.report.error}\n';

    text += '\n';

    text += 'Stack trace:\n';
    text += '${widget.report.stackTrace}\n';

    text += '\n';

    text += 'Device parameters:\n';
    for (final entry in widget.report.deviceParameters.entries) {
      text += '${entry.key}: ${entry.value}\n';
    }

    text += '\n';

    text += 'Application parameters:\n';
    for (final entry in widget.report.applicationParameters.entries) {
      text += '${entry.key}: ${entry.value}\n';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppLocalizations.of(context)!.pageReportModeBody(
                  AppLocalizations.of(context)!.accept,
                  AppLocalizations.of(context)!.cancel),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Text(text),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                onPressed: () => _onAcceptClicked(),
                child: Text(AppLocalizations.of(context)!.accept),
              ),
              TextButton(
                onPressed: () => _onCancelClicked(),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _onAcceptClicked() {
    widget.pageReportMode.onActionConfirmed(widget.report);
    _closePage();
  }

  void _onCancelClicked() {
    widget.pageReportMode.onActionRejected(widget.report);
    _closePage();
  }

  void _closePage() {
    Navigator.of(context).pop();
  }
}
