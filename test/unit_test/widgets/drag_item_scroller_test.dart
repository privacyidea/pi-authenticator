/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024-2025 NetKnights GmbH
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
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/widgets/drag_item_scroller.dart';

void main() {
  group('DragItemScroller Tests', () {
    testWidgets('static constants have expected values', (tester) async {
      expect(DragItemScroller.maxScrollingSpeed, 800.0);
      expect(DragItemScroller.minScrollingSpeed, 100.0);
      expect(DragItemScroller.refreshRate, 30);
      expect(DragItemScroller.minScrollingSpeedDetectDistanceTop, 40.0);
      expect(DragItemScroller.minScrollingSpeedDetectDistanceBottom, 120.0);
      expect(DragItemScroller.maxSpeedZoneHeightTop, 40.0);
      expect(DragItemScroller.maxSpeedZoneHeightBottom, 40);
    });
  });
}
