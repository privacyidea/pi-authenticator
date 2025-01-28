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
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../utils/logger.dart';
import '../../../../utils/view_utils.dart';
import '../../../../widgets/dialog_widgets/default_dialog.dart';

class QrNotFoundDialog extends StatelessWidget {
  final XFile xFile;
  const QrNotFoundDialog({super.key, required this.xFile});

  Future<XFile?> show(BuildContext context) async => showDialog<XFile>(context: context, builder: build);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return DefaultDialog(
      title: Text(appLocalizations.qrNotFound),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            appLocalizations.qrInFileNotFound,
            textAlign: TextAlign.center,
          ),
          Text(
            appLocalizations.qrInFileNotFound2,
            textAlign: TextAlign.center,
          ),
          Text(
            appLocalizations.qrInFileNotFound3,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(appLocalizations.cancel)),
        TextButton(
          onPressed: () async {
            CroppedFile? croppedFile;
            try {
              await xFile.readAsBytes();
              if (!context.mounted) return;
              croppedFile = await ImageCropper().cropImage(
                sourcePath: xFile.path,
                uiSettings: [
                  AndroidUiSettings(aspectRatioPresets: [CropAspectRatioPreset.square]),
                  IOSUiSettings(aspectRatioPresets: [CropAspectRatioPreset.square]),
                  WebUiSettings(context: context),
                ],
              );
            } catch (e) {
              if (!context.mounted) return;
              Navigator.of(context).pop();
              showErrorStatusMessage(message: (l) => l.fileNotAvailable);
              return;
            }
            if (!context.mounted) return;
            if (croppedFile == null) {
              Logger.warning("No croppedFile");
              return Navigator.of(context).pop();
            }
            Logger.warning("Cropped file: ${croppedFile.path}");
            return Navigator.of(context).pop(XFile(croppedFile.path));
          },
          child: Text(appLocalizations.markQrCode),
        ),
      ],
    );
  }
}
