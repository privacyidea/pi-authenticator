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

import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/widgets/button_widgets/cooldown_button.dart';

import '../../../../utils/customization/theme_extentions/push_request_theme.dart';
import '../push_request_dialog.dart';

class RequirePresenceButtonRow<T> extends StatelessWidget {
  final List<T> possibleAnswers;
  final Future<void> Function(String answer) onAccept;
  final double? rowHeight;

  const RequirePresenceButtonRow({
    super.key,
    required this.possibleAnswers,
    required this.onAccept,
    this.rowHeight,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    final answers = possibleAnswers.toList();
    final totalAnswersNum = answers.length;
    const numPerRow = 3;
    while (answers.isNotEmpty) {
      final maxThisRow = answers.length == numPerRow + 1 ? min(answers.length, (numPerRow / 2).ceil()) : min(answers.length, numPerRow);
      final answersThisRow = answers.sublist(0, maxThisRow);
      answers.removeRange(0, maxThisRow);
      final spacer = (maxThisRow != numPerRow && totalAnswersNum > maxThisRow)
          ? Expanded(flex: (numPerRow - answersThisRow.length) * answersThisRow.length, child: const SizedBox())
          : const SizedBox();
      final pushRequestTheme = (Theme.of(context).extensions[PushRequestTheme] as PushRequestTheme);
      children.add(
        SizedBox(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              spacer,
              for (final possibleAnswer in answersThisRow)
                Expanded(
                  flex: answersThisRow.length * 2,
                  child: CooldownButton(
                    style: ButtonStyle(
                      shape: PushRequestDialog.getButtonShape(context),
                      backgroundColor: WidgetStateProperty.all(pushRequestTheme.acceptColor),
                    ),
                    onPressed: () => _onPressedAnswer(possibleAnswer),
                    child: SizedBox(
                      height: rowHeight,
                      child: Center(
                        child: Text(
                          possibleAnswer.toString(),
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              spacer,
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Future<void> _onPressedAnswer(T answer) => onAccept(answer.toString());
}
