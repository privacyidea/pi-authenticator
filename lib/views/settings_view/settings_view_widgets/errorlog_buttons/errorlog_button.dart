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

class ErrorlogButton extends StatelessWidget {
  final Function() onPressed;
  final String text;
  const ErrorlogButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) => ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Flexible(child: SizedBox()),
            Expanded(
              flex: 4,
              child: ElevatedButton(
                onPressed: onPressed,
                child: Text(
                  text,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ),
            ),
            const Flexible(child: SizedBox()),
          ],
        ),
      );
}
