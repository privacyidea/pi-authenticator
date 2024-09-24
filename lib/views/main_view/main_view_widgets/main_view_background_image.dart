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

class MainViewBackgroundImage extends ConsumerWidget {
  final Widget appImage;

  const MainViewBackgroundImage({super.key, required this.appImage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final base = isDarkMode ? 0.3 : 0.08;
    final blendMode = isDarkMode ? BlendMode.darken : BlendMode.lighten;
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(36, 4, 36, 60),
        child:
            //  isDarkMode
            //     ?
            FittedBox(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(scaffoldBackgroundColor.withOpacity(1 - base), blendMode),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(scaffoldBackgroundColor, BlendMode.color),
              child: appImage,
            ),
          ),
          // )
          // :
          // FittedBox(
          //     child: ColorFiltered(
          //       colorFilter: ColorFilter.mode(scaffoldBackgroundColor.withOpacity(0.9), BlendMode.lighten),
          //       // colorFilter: ColorFilter.matrix([
          //       //   // Greyscale the child then add a fraction the color value to the backgroundcolor to make it look like a brightened greyscale image
          //       //   -0.393 * base, -0.769 * base, -0.189 * base, 0, r,
          //       //   -0.349 * base, -0.686 * base, -0.168 * base, 0, g,
          //       //   -0.272 * base, -0.534 * base, -0.131 * base, 0, b,
          //       //   0, 0, 0, 0, a,
          //       // ]),
          //       // child: Opacity(
          //       //   opacity: 0.1,
          //       child: ColorFiltered(
          //         colorFilter: ColorFilter.mode(scaffoldBackgroundColor, BlendMode.color),
          //         // child: ColorFiltered(
          //         //   colorFilter: ColorFilter.matrix([
          //         //     // Greyscale the child then add a fraction the color value to the backgroundcolor to make it look like a brightened greyscale image
          //         //     0.2126, 0.7152, 0.0722, 0, 0,
          //         //     0.2126, 0.7152, 0.0722, 0, 0,
          //         //     0.2126, 0.7152, 0.0722, 0, 0,
          //         //     0, 0, 0, 1, 0,
          //         //   ]),
          //         child: appImage,
          //       ),
          //     ),
          // ),
          // ),
        ),
      ),
    );
  }
}
/**
 *
 * /*
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

class MainViewBackgroundIcon extends ConsumerWidget {
  final Widget appImage;

  const MainViewBackgroundIcon({super.key, required this.appImage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final r = scaffoldBackgroundColor.red.toDouble();
    final g = scaffoldBackgroundColor.green.toDouble();
    final b = scaffoldBackgroundColor.blue.toDouble();
    final a = scaffoldBackgroundColor.alpha.toDouble();

    final base = isDarkMode ? 0.03 : 0.08;
    final asd = isDarkMode ? 1 : 0;
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(36, 4, 36, 60),
        child: FittedBox(
          child: ColorFiltered(
            colorFilter: ColorFilter.matrix(<double>[
              (0.393*base, (0.769*base, (0.189*base, 0, r, //
              (0.349*base, (0.686*base, (0.168*base, 0, g,
              (0.272*base, (0.534*base, (0.131*base, 0, b,
              0, 0, 0, 0, a, //
            ]),
            child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.transparent,
                  // scaffoldBackgroundColor,
                  BlendMode.color,
                ),
                child:
                    // isDarkMode
                    // ?
                    appImage
                // : ColorFiltered(
                //     colorFilter: ColorFilter.mode(
                //       scaffoldBackgroundColor,
                //       isDarkMode ? BlendMode.exclusion : BlendMode.exclusion,
                //     ),
                //     child:
                //  appImage,
                ),
          ),
        ),
        // ),
      ),
    );
  }
}

 */