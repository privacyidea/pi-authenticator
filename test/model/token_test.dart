/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2019 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:collection';

import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:test/test.dart';

void main() {
  verifyCustomListBehavesLikeQueue();
}

void verifyCustomListBehavesLikeQueue() {
  group("Test custom queue", () {
    test("isEmpty", () {
      FIFOQueue<int> fifo = FIFOQueue();

      expect(fifo.isNotEmpty, false);
      expect(fifo.isEmpty, true);

      fifo.add(1);

      expect(fifo.isNotEmpty, true);
      expect(fifo.isEmpty, false);

      var peek = fifo.peek();
      expect(peek, 1);

      expect(fifo.isNotEmpty, true);
      expect(fifo.isEmpty, false);

      var pop = fifo.pop();
      expect(pop, 1);

      expect(fifo.isNotEmpty, false);
      expect(fifo.isEmpty, true);
    });

    test("behaves like queue", () {
      Queue<int> queue = Queue();
      FIFOQueue<int> fifo = FIFOQueue();

      queue.addLast(1);
      fifo.add(1);
      queue.addLast(2);
      fifo.add(2);
      queue.addLast(3);
      fifo.add(3);

      expect(fifo.peek(), queue.first);
      fifo.pop();
      queue.removeFirst();
      expect(fifo.peek(), queue.first);

      queue.addLast(4);
      fifo.add(4);
      queue.addLast(4);
      fifo.add(4);
      expect(fifo.pop(), queue.removeFirst());
      expect(fifo.pop(), queue.removeFirst());
      expect(fifo.pop(), queue.removeFirst());
      expect(fifo.pop(), queue.removeFirst());

      expect(fifo.isEmpty, true);
      expect(queue.isEmpty, true);
    });
  });
}
