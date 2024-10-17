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
import 'dart:typed_data';

class Uint8Buffer {
  int currentPos = 0;
  Uint8List data;
  Uint8Buffer({required this.data});
  factory Uint8Buffer.fromList(List<int> list) {
    return Uint8Buffer(data: Uint8List.fromList(list));
  }

  /// Writes [bytes] to the buffer
  void writeBytes(Uint8List bytes) {
    data = Uint8List.fromList([...data, ...bytes]);
  }

  /// Reads [length] bytes from the current position
  /// and moves the position forward
  /// If [length] is out of bounds, it will return the rest of the buffer
  Uint8List readBytes(int length) {
    var nextPos = currentPos + length;
    if (nextPos > data.length) nextPos = data.length;
    final bytes = data.sublist(currentPos, nextPos);
    currentPos = nextPos;
    return bytes;
  }

  /// Reads all bytes from the current position to the end of the buffer
  /// If [left] is provided, it will leave [left] bytes at the end
  /// and return the rest
  /// If [left] is out of bounds, it will return an empty list
  Uint8List readBytesToEnd({int left = 0}) {
    if (left < 0) left = 0;
    var nextPos = data.length - left;
    if (nextPos < currentPos) nextPos = currentPos;
    final bytes = data.sublist(currentPos, data.length - left);
    currentPos = data.length - left;
    return bytes;
  }

  /// Moves the current position to [pos]
  /// If [pos] is out of bounds, it will move to the closest bound
  void moveCurrentPos(int pos) {
    if (pos > data.length) {
      pos = data.length;
    } else if (pos < 0) {
      pos = 0;
    }
    currentPos = pos;
  }
}
