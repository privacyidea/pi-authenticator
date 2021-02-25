import 'package:catcher/catcher.dart';
import 'package:catcher/model/platform_type.dart';
import 'package:catcher/model/report_mode.dart';
import 'package:catcher/utils/catcher_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';

class CustomPageReportMode extends ReportMode {
  @override
  void requestAction(Report report, BuildContext context) {
    _navigateToPageWidget(report, context);
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
    Key key,
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
        title: Text(Localization.of(context).pageReportModeTitle),
      ),
      body: _buildInnerWidget(),
    );
  }

  Widget _buildCupertinoPage() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(Localization.of(context).pageReportModeTitle),
      ),
      child: SafeArea(
        child: _buildInnerWidget(),
      ),
    );
  }

  Widget _buildInnerWidget() {
    String text = "${widget.report.error}\n";

    text += "\n";

    text += "Stack trace:\n";
    text += "${widget.report.stackTrace}\n";

    text += "\n";

    text += "Device parameters:\n";
    for (final entry in widget.report.deviceParameters.entries) {
      text += "${entry.key}: ${entry.value}\n";
    }

    text += "\n";

    text += "Application parameters:\n";
    for (final entry in widget.report.applicationParameters.entries) {
      text += "${entry.key}: ${entry.value}\n";
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
            child: Text( Localization.of(context).pageReportModeBody
              ,
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
                child: Text(Localization.of(context).accept),
              ),
              TextButton(
                onPressed: () => _onCancelClicked(),
                child: Text(Localization.of(context).cancel),
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
