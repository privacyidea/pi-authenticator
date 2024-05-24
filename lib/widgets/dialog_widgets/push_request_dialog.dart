import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../model/extensions/color_extension.dart';
import '../../model/push_request.dart';
import '../../model/tokens/push_token.dart';
import '../../utils/globals.dart';
import '../../utils/lock_auth.dart';
import '../../utils/riverpod_providers.dart';
import '../press_button.dart';
import 'default_dialog.dart';

class PushRequestDialog extends ConsumerStatefulWidget {
  final PushRequest pushRequest;

  const PushRequestDialog(this.pushRequest, {super.key});

  @override
  ConsumerState<PushRequestDialog> createState() => _PushRequestDialogState();
}

class _PushRequestDialogState extends ConsumerState<PushRequestDialog> {
  double get lineHeight => Theme.of(context).textTheme.titleLarge?.fontSize ?? 16;
  double get spacerHeight => lineHeight * 0.5;

  MaterialStateProperty<OutlinedBorder?> get buttonShape => MaterialStateProperty.all(
        Theme.of(context).elevatedButtonTheme.style?.shape?.resolve({})?.copyWith(
          side: BorderSide(color: Theme.of(context).colorScheme.onPrimary, width: 2.5),
        ),
      );

  bool isHandled = false;
  bool dialogIsOpen = false;

  @override
  void dispose() {
    if (dialogIsOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        int popCount = 0;
        Navigator.of(await globalContext).popUntil((route) {
          popCount++;
          return route.isFirst || popCount > 1;
        });
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacerHeight = this.spacerHeight;
    final question = widget.pushRequest.question;
    final token = ref.watch(tokenProvider).getTokenBySerial(widget.pushRequest.serial);
    final localizations = AppLocalizations.of(context)!;
    if (token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) ref.read(pushRequestProvider.notifier).remove(widget.pushRequest);
      });
    }
    final test = [
      '42',
      '0#',
      '69',
      '13',
      '37',
    ];
    return isHandled || token == null
        ? const SizedBox()
        : Container(
            color: Colors.transparent,
            child: DefaultDialog(
              scrollable: false,
              title: Text(
                localizations.authenticationRequest,
                style: Theme.of(context).textTheme.headlineMedium!,
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    localizations.requestInfo(
                      token.issuer,
                      token.label,
                    ),
                    style: Theme.of(context).textTheme.bodyLarge!,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacerHeight),
                  ...[
                    Text(
                      question,
                      style: Theme.of(context).textTheme.bodyLarge!,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacerHeight),
                  ],
                  widget.pushRequest.answers == null
                      ? AnswerSelectionWidget(
                          onAnswerSelected: (p0) {
                            globalRef?.read(pushRequestProvider.notifier).accept(token, widget.pushRequest, selectedAnswerIndex: p0);
                            if (mounted) setState(() => isHandled = true);
                          },
                          possibleAnswers: test,
                        )
                      : SizedBox(
                          // Accept button
                          child: PressButton(
                            style: ButtonStyle(shape: buttonShape),
                            onPressed: () async {
                              if (token.isLocked && await lockAuth(localizedReason: localizations.authToAcceptPushRequest) == false) {
                                return;
                              }
                              globalRef?.read(pushRequestProvider.notifier).accept(token, widget.pushRequest);
                              if (mounted) setState(() => isHandled = true);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: spacerHeight),
                                  child: Text(
                                    localizations.accept,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                  ),
                                ),
                                Icon(
                                  Icons.check_outlined,
                                  size: Theme.of(context).textTheme.headlineMedium?.fontSize ?? 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                  SizedBox(
                    // Decline button
                    child: PressButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.errorContainer,
                        ),
                        shape: buttonShape,
                      ),
                      onPressed: () async {
                        if (token.isLocked && await lockAuth(localizedReason: localizations.authToDeclinePushRequest) == false) {
                          return;
                        }
                        dialogIsOpen = true;
                        await _showConfirmationDialog(token);
                        dialogIsOpen = false;
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            localizations.decline,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                            textAlign: TextAlign.center,
                          ),
                          Icon(
                            Icons.close_outlined,
                            size: Theme.of(context).textTheme.headlineMedium?.fontSize ?? 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: spacerHeight),
                ],
              ),
            ),
          );
  }

  Future<void> _showConfirmationDialog(PushToken pushToken) {
    final localizations = AppLocalizations.of(context)!;
    return showDialog(
        useRootNavigator: false,
        context: globalNavigatorKey.currentContext!,
        builder: (BuildContext context) {
          final spacerHeight = this.spacerHeight;
          return DefaultDialog(
            title: Text(
              localizations.authenticationRequest,
              style: Theme.of(context).textTheme.titleLarge!,
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  localizations.requestTriggerdByUserQuestion,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: Theme.of(context).textTheme.titleMedium?.fontSize),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacerHeight),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Expanded(child: SizedBox()),
                    Expanded(
                      flex: 6,
                      child: PressButton(
                        style: ButtonStyle(shape: buttonShape),
                        onPressed: () {
                          globalRef?.read(pushRequestProvider.notifier).decline(pushToken, widget.pushRequest);
                          Navigator.of(context).pop();
                          if (mounted) setState(() => isHandled = true);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              localizations.yes,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                              textAlign: TextAlign.center,
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                localizations.butDiscardIt,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onPrimary.mixWith(Colors.grey.shade800),
                                    ),
                                textAlign: TextAlign.center,
                                softWrap: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(flex: 2, child: SizedBox()),
                    Expanded(
                      flex: 6,
                      child: PressButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.errorContainer),
                          shape: buttonShape,
                        ),
                        onPressed: () {
                          //TODO: Notify issuer
                          globalRef?.read(pushRequestProvider.notifier).decline(pushToken, widget.pushRequest);
                          Navigator.of(context).pop();
                          if (mounted) setState(() => isHandled = true);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              localizations.no,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              localizations.declineIt,
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary.mixWith(Colors.grey.shade800)),
                              textAlign: TextAlign.center,
                              softWrap: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ],
            ),
          );
        });
  }
}

class AnswerSelectionWidget<T> extends StatefulWidget {
  final List<T> possibleAnswers;
  final void Function(int) onAnswerSelected;
  const AnswerSelectionWidget({required this.possibleAnswers, super.key, required this.onAnswerSelected});

  @override
  State<AnswerSelectionWidget<T>> createState() => _AnswerSelectionWidgetState<T>();
}

class _AnswerSelectionWidgetState<T> extends State<AnswerSelectionWidget<T>> {
  double get lineHeight => Theme.of(context).textTheme.titleLarge?.fontSize ?? 16;
  double get spacerHeight => lineHeight * 0.5;
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    final possibleAnswers = widget.possibleAnswers.toList();
    const numPerRow = 3;
    var answersHandled = 0;
    var numRow = 0;
    while (possibleAnswers.length > answersHandled) {
      final maxThisRow = possibleAnswers.length - answersHandled == numPerRow + 1
          ? min(possibleAnswers.length - answersHandled, (numPerRow / 2).ceil())
          : min(possibleAnswers.length - answersHandled, numPerRow);
      numRow++;
      print('NumRow: $numRow');
      print('asd.length: ${possibleAnswers.length}');
      print('maxThisRow: $maxThisRow');
      children.add(
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (maxThisRow != numPerRow) const Expanded(child: SizedBox()),
            for (var i = answersHandled; i < answersHandled + maxThisRow; i++, answersHandled++)
              Expanded(
                flex: 4,
                child: PressButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.onPrimary,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () => widget.onAnswerSelected(i),
                  child: Padding(
                    padding: EdgeInsets.all(spacerHeight),
                    child: Text(
                      possibleAnswers[i].toString(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            if (maxThisRow != numPerRow) const Expanded(child: SizedBox()),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
