/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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
part of 'push_request_dialog.dart';

class PushChoiceDialog extends ConsumerWidget with PushDialogMixin {
  @override
  final PushChoiceRequest pushRequest;
  @override
  final PushToken token;

  const PushChoiceDialog({
    required this.pushRequest,
    required this.token,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme =
        (Theme.of(context).extensions[PushRequestTheme] as PushRequestTheme);
    final l10n = AppLocalizations.of(context)!;

    return DefaultDialog(
      scrollable: false,
      title: PushRequestHeader(pushRequest: pushRequest),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          PushRequestBaseInfo(token: token, pushRequest: pushRequest),
          const SizedBox(height: 24),
          ..._buildChoiceGrid(context, ref, theme),
          const SizedBox(height: 8),
          PaddedRow(
            peddingPercent: 0.33,
            child: PushActionButton(
              backgroundColor: theme.declineColor,
              height: 36.0,
              onPressed: () => PushDeclineConfirmDialog.showDialogWidget(
                context: context,
                onDecline: () => handleDecline(context, ref),
                onDiscard: () => handleDiscard(context, ref),
                title: pushRequest.title,
                expirationDate: pushRequest.expirationDate,
              ),
              child: Text(l10n.decline),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChoiceGrid(
    BuildContext context,
    WidgetRef ref,
    PushRequestTheme theme,
  ) {
    final widgets = <Widget>[];
    final answers = pushRequest.possibleAnswers.toList();
    const numPerRow = 3;

    while (answers.isNotEmpty) {
      final maxThisRow = answers.length == numPerRow + 1
          ? (numPerRow / 2).ceil()
          : min(answers.length, numPerRow);

      final rowAnswers = answers.sublist(0, maxThisRow);
      answers.removeRange(0, maxThisRow);

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final answer in rowAnswers)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: PushActionButton(
                      backgroundColor: theme.acceptColor,
                      height: 36.0,
                      onPressed: () =>
                          handleAccept(context, ref, answer: answer),
                      child: Text(answer),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }
}
