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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'token_image.dart';

final disableCopyOtpProvider = StateProvider<bool>((ref) => false);

class TokenWidgetTile extends ConsumerWidget {
  final Widget? title;
  final List<String> subtitles;
  final Widget? leading;
  final Widget? trailing;
  final Function()? onTap;
  final bool tokenIsLocked;
  final String? tokenImage;

  final bool isPreview;

  const TokenWidgetTile({
    this.leading,
    this.title,
    this.subtitles = const [],
    this.trailing,
    this.onTap,
    this.tokenIsLocked = false,
    this.tokenImage,
    this.isPreview = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 2),
        titleAlignment: ListTileTitleAlignment.center,
        horizontalTitleGap: isPreview ? 0 : 8,
        leading: (leading != null) ? leading! : null,
        onTap: onTap,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topLeft,
          child: title,
        ),
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TokenImage(tokenImage: tokenImage),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    for (var line in subtitles)
                      Text(
                        line,
                        style: Theme.of(context).listTileTheme.subtitleTextStyle,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    for (var i = 0; i < 2 - subtitles.length; i++) Text(''),
                  ],
                ),
              ),
            ),
          ],
        ),
        trailing: trailing ?? const SizedBox(),
      );
}
