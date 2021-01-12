/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2019 NetKnights GmbH

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
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';

class GuideScreen extends StatelessWidget {
  final ScrollController _controller = ScrollController(initialScrollOffset: 2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            Localization.of(context).guide,
            overflow: TextOverflow.ellipsis,
            // maxLines: 2 only works like this.
            maxLines: 2, // Title can be shown on small screens too.
          ),
        ),
        body: FutureBuilder<String>(
          future: DefaultAssetBundle.of(context).loadString('res/md/GUIDE.md'),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Scrollbar(
                controller: _controller,
                isAlwaysShown: true,
                child: Markdown(
                  controller: _controller,
                  data: snapshot.data,
                ),
              );
            }
            return Center(
                child: Text(Localization.of(context).somethingWentWrong));
          },
        ));
  }
}