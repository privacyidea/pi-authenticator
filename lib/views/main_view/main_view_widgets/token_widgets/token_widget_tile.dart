/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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

import '../../../../../../../views/main_view/main_view_widgets/token_widgets/container_token_sync_icon.dart';
import '../../../../model/tokens/token.dart';
import '../../../../widgets/custom_texts.dart';
import 'token_image.dart';

final disableCopyOtpProvider = StateProvider<bool>((ref) => false);

class TokenWidgetTile extends ConsumerWidget {
  final Token token;
  final String title;
  final TextStyle? titleStyle;
  final List<String> additionalSubtitles;
  final Widget? leading;
  final Widget? trailing;
  final Function()? onTap;
  final String semanticsLabel;
  final Function()? titleOnTap;

  const TokenWidgetTile({
    required this.token,
    required this.title,
    required this.semanticsLabel,
    this.titleStyle,
    this.additionalSubtitles = const [],
    this.leading,
    this.trailing,
    this.onTap,
    this.titleOnTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String subtitle1 = '';
    if (token.label != title) subtitle1 = token.label;
    String subtitle2 = token.issuer;
    final subtitles = [...additionalSubtitles];
    if (subtitle1.isEmpty && additionalSubtitles.length < 2) subtitles.add('');
    if (subtitle2.isEmpty && additionalSubtitles.length < 2) subtitles.add('');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 2),
      titleAlignment: ListTileTitleAlignment.center,
      leading: (leading != null) ? leading! : null,
      onTap: onTap,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topLeft,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Semantics(
            label: semanticsLabel,
            child: InkWell(
              onTap: titleOnTap,
              child: HideableText(
                textScaleFactor: 1.9,
                isHidden: token.isHidden,
                text: title,
                textStyle: titleStyle,
              ),
            ),
          ),
        ),
      ),
      subtitle: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TokenImage(tokenImage: token.tokenImage),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (subtitle1.isNotEmpty)
                    Text(
                      subtitle1,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  if (subtitle2.isNotEmpty)
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            subtitle2,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                        ),
                        SizedBox(width: 6),
                        ContainerTokenSyncIcon(token),
                      ],
                    ),
                  for (var line in additionalSubtitles)
                    Text(
                      line,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      trailing: trailing ?? const SizedBox(),
    );
  }
}
