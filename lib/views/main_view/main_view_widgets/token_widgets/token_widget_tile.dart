import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_action.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/custom_trailing.dart';
import 'default_token_actions/default_delete_action.dart';
import 'default_token_actions/default_edit_action.dart';
import 'default_token_actions/default_lock_action.dart';

final disableCopyOtpProvider = StateProvider<bool>((ref) => false);

class TokenWidgetTile extends StatelessWidget {
  final Widget? title;
  final Token token;
  final TokenAction? deleteAction;
  final TokenAction? editAction;
  final TokenAction? lockAction;
  final Widget? leading;
  final Widget? trailing;
  final Function()? onTap;
  final bool tokenIsLocked;
  final String? tokenImage;

  const TokenWidgetTile({
    required this.token,
    this.leading,
    this.title,
    this.deleteAction,
    this.editAction,
    this.lockAction,
    this.trailing,
    this.onTap,
    this.tokenIsLocked = false,
    this.tokenImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(left: 20.0, top: 0.1, right: 20.0, bottom: 0.1),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                ),
              ),
              Container(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).highlightColor,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          margin: const EdgeInsets.all(10.0),
                          child: Text(token.label,
                              style: const TextStyle(fontSize: 18))),
                      PopupMenuButton<String>(
                        onSelected: (String choice) {
                          if (choice == 'delete') {
                            (deleteAction ?? DefaultDeleteAction(token: token))
                                .handle(context);
                          } else if (choice == 'edit') {
                            (editAction ?? DefaultEditAction(token: token))
                                .handle(context);
                          } else if (choice == 'lock') {
                            (lockAction ?? DefaultLockAction(token: token))
                                .handle(context);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          List<PopupMenuEntry<String>> actions = [];

                          actions.add(PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: const Icon(Icons.delete),
                              title: Text(AppLocalizations.of(context)!.delete),
                            ),
                          ));

                          actions.add(PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                              leading: const Icon(Icons.edit),
                              title: Text(AppLocalizations.of(context)!.edit),
                            ),
                          ));

                          if (token.pin == false) {
                            if (token.isLocked) {
                              actions.add(PopupMenuItem<String>(
                                value: 'lock',
                                child: ListTile(
                                  leading: const Icon(Icons.lock),
                                  title: Text(
                                      AppLocalizations.of(context)!.unlock),
                                ),
                              ));
                            } else {
                              actions.add(PopupMenuItem<String>(
                                value: 'lock',
                                child: ListTile(
                                  leading: const Icon(Icons.lock),
                                  title:
                                      Text(AppLocalizations.of(context)!.lock),
                                ),
                              ));
                            }
                          }

                          return actions;
                        },
                        icon: const Icon(Icons.more_horiz),
                        offset: const Offset(0, 50),
                      )
                    ],
                  ),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                horizontalTitleGap: 8.0,
                leading: (leading != null) ? leading! : null,
                onTap: onTap,
                title: title,
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
                            Text(
                              token.issuer,
                              style: Theme.of(context)
                                  .listTileTheme
                                  .subtitleTextStyle,
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
                trailing: CustomTrailing(
                  child: trailing ?? const SizedBox(),
                ),
              ),
            ],
          ),
        ),
      );
}

final tokenImages = <String?, Uint8List?>{};

Future<Uint8List?> getTokenImageBytesAsync(String? tokenImageUrl) async {
  if (tokenImages.containsKey(tokenImageUrl)) {
    return tokenImages[tokenImageUrl]!;
  } else {
    if (tokenImageUrl == null || tokenImageUrl.isEmpty || Uri.tryParse(tokenImageUrl) == null) {
      tokenImages[tokenImageUrl] = null;
      return null;
    }
    http.Response response;
    try {
      response = await http.get(Uri.parse(tokenImageUrl));
    } catch (e) {
      return null;
    }
    final newTokenImage = response.bodyBytes;
    tokenImages[tokenImageUrl] = newTokenImage;
    return newTokenImage;
  }
}

Uint8List? getTokenImageBytesSync(String? tokenImageUrl) => tokenImages[tokenImageUrl];

class TokenImage extends StatefulWidget {
  final String? tokenImage;
  const TokenImage({super.key, this.tokenImage});

  @override
  State<TokenImage> createState() => _TokenImageState();
}

class _TokenImageState extends State<TokenImage> {
  late bool hasImage;
  Image? tokenImage;

  @override
  void initState() {
    super.initState();
    hasImage = widget.tokenImage != null && widget.tokenImage!.isNotEmpty;
    final imageBytes = getTokenImageBytesSync(widget.tokenImage);
    if (imageBytes != null) {
      tokenImage = Image.memory(
        imageBytes,
        fit: BoxFit.fitHeight,
        errorBuilder: (context, error, stackTrace) {
          if (!mounted) return const SizedBox();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              hasImage = false;
            });
          });
          return const SizedBox();
        },
      );
    } else {
      _loadImage();
    }
  }

  void _loadImage() {
    if (!hasImage || tokenImage != null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final uint8List = await getTokenImageBytesAsync(widget.tokenImage);
      if (uint8List == null) {
        setState(() {
          hasImage = false;
        });
        return;
      }
      setState(() {
        tokenImage = Image.memory(
          uint8List,
          fit: BoxFit.fitHeight,
          errorBuilder: (context, error, stackTrace) {
            if (!mounted) return const SizedBox();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                hasImage = false;
              });
            });
            return const SizedBox();
          },
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) => hasImage
      ? Padding(
          padding: const EdgeInsets.only(left: 4, top: 2, right: 4),
          child: SizedBox(
            height: 32,
            child: tokenImage ??
                const SizedBox(
                  width: 32,
                  child: CircularProgressIndicator(),
                ),
          ))
      : const SizedBox();
}
