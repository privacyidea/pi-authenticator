/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2021 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:privacyidea_authenticator/screens/settings_screen.dart';
import 'package:privacyidea_authenticator/utils/customizations.dart';

class GuideScreen extends StatelessWidget {
  // Without the offset the scroll bar is not shown the first time the screen
  // is displayed. This is a workaround for that bug and hopefully works on
  // all devices.
  final ScrollController _controller = ScrollController(initialScrollOffset: 2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.guide,
          overflow: TextOverflow.ellipsis,
          // maxLines: 2 only works like this.
          maxLines: 2, // Title can be shown on small screens too.
        ),
      ),
      body: Column(
        children: [
          FutureBuilder<String>(
            // localeName defaults to en if an unsupported locale is set on the phone.
            future: DefaultAssetBundle.of(context).loadString(
                'res/md/GUIDE_${AppLocalizations.of(context)!.localeName}.md'),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: Scrollbar(
                    controller: _controller,
                    isAlwaysShown: true,
                    child: Markdown(
                      controller: _controller,
                      data: snapshot.data!,
                    ),
                  ),
                );
              }
              return Center(
                  child: Text(AppLocalizations.of(context)!.somethingWentWrong));
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.showThisScreenOnStart),
            trailing: StreamBuilder<bool>(
              stream: AppSettings.of(context).showGuideOnStartStream(),
              initialData: true,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Checkbox(
                    value: snapshot.data,
                    onChanged: (value) =>
                        AppSettings.of(context).showGuideOnStart = value!,
                    activeColor: Colors.grey, // TODO Find a nice color for this
                  );
                } else {
                  // If the stream has no data, show an out-grayed checkbox
                  return Checkbox(
                    value: AppSettings.of(context).showGuideOnStart,
                    onChanged: null,
                  );
                }
              },
            ),
            tileColor: PRIMARY_COLOR,
          ),
        ],
      ),
    );
  }
}
