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

class PushCodeToPhoneDialog extends ConsumerStatefulWidget
    with PushDialogMixin {
  @override
  final PushCodeToPhoneRequest pushRequest;
  @override
  final PushToken token;

  const PushCodeToPhoneDialog({
    required this.pushRequest,
    required this.token,
    super.key,
  });

  @override
  ConsumerState<PushCodeToPhoneDialog> createState() =>
      _PushCodeToPhoneDialogState();
}

class _PushCodeToPhoneDialogState extends ConsumerState<PushCodeToPhoneDialog> {
  bool _isCopyOnCooldown = false;
  final _formKey = GlobalKey<FormState>();

  void _copyToClipboard() {
    if (_isCopyOnCooldown) return;

    setState(() => _isCopyOnCooldown = true);
    Clipboard.setData(ClipboardData(text: widget.pushRequest.displayCode));

    showSnackBar(
      AppLocalizations.of(
        context,
      )!.otpValueCopiedMessage(widget.pushRequest.displayCode),
      context: context,
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isCopyOnCooldown = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return DefaultDialog(
      scrollable: false,
      title: PushRequestHeader(pushRequest: widget.pushRequest),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PushRequestBaseInfo(pushRequest: widget.pushRequest),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  GestureDetector(
                    onTap: _copyToClipboard,
                    child: Text(
                      widget.pushRequest.displayCode,

                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.copy,
                      color: _isCopyOnCooldown
                          ? theme.disabledColor
                          : theme.colorScheme.primary,
                    ),
                    onPressed: _copyToClipboard,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        DialogAction(
          label: localizations.done,
          intent: ActionIntent.confirm,
          formState: _formKey,
          onPressed: () async => widget.handleDiscard(context, ref),
        ),
      ],
    );
  }
}
