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
import 'dart:convert';

import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

void main() {
  verifyCustomListBehavesLikeQueue();
  verifyCustomStringBufferWorks();
}

void verifyCustomListBehavesLikeQueue() {
  group("Test custom queue", () {
    Uri uri = Uri.parse("http://www.example.com");

    test("isEmpty", () {
      PushRequestQueue fifo = PushRequestQueue();
      var pushRequest = PushRequest(
          "title", "question", uri, "nonce", false, Uuid().v4().hashCode);

      expect(fifo.isNotEmpty, false);
      expect(fifo.isEmpty, true);

      fifo.add(pushRequest);

      expect(fifo.isNotEmpty, true);
      expect(fifo.isEmpty, false);

      var peek = fifo.peek();
      expect(peek, pushRequest);

      expect(fifo.isNotEmpty, true);
      expect(fifo.isEmpty, false);

      var pop = fifo.pop();
      expect(pop, pushRequest);

      expect(fifo.isNotEmpty, false);
      expect(fifo.isEmpty, true);
    });

    test("behaves like queue", () {
      Queue<PushRequest> queue = Queue();
      PushRequestQueue fifo = PushRequestQueue();

      var one = PushRequest(
          "one", "question", uri, "nonce", false, Uuid().v4().hashCode);
      var two = PushRequest(
          "two", "question", uri, "nonce", false, Uuid().v4().hashCode);
      var three = PushRequest(
          "three", "question", uri, "nonce", false, Uuid().v4().hashCode);
      var four = PushRequest(
          "four", "question", uri, "nonce", false, Uuid().v4().hashCode);
      var five = PushRequest(
          "five", "question", uri, "nonce", false, Uuid().v4().hashCode);

      queue.addLast(one);
      fifo.add(one);
      queue.addLast(two);
      fifo.add(two);
      queue.addLast(three);
      fifo.add(three);

      expect(fifo.peek(), queue.first);
      fifo.pop();
      queue.removeFirst();
      expect(fifo.peek(), queue.first);

      queue.addLast(four);
      fifo.add(four);
      queue.addLast(five);
      fifo.add(five);
      expect(fifo.pop(), queue.removeFirst());
      expect(fifo.pop(), queue.removeFirst());
      expect(fifo.pop(), queue.removeFirst());
      expect(fifo.pop(), queue.removeFirst());

      expect(fifo.isEmpty, true);
      expect(queue.isEmpty, true);
    });

    test("serialization", () {
      PushRequestQueue fifo = PushRequestQueue();

      var one = PushRequest(
          "one", "question", uri, "nonce", false, Uuid().v4().hashCode);
      var two = PushRequest(
          "two", "question", uri, "nonce", false, Uuid().v4().hashCode);
      var three = PushRequest(
          "three", "question", uri, "nonce", false, Uuid().v4().hashCode);
      var four = PushRequest(
          "four", "question", uri, "nonce", false, Uuid().v4().hashCode);
      var five = PushRequest(
          "five", "question", uri, "nonce", false, Uuid().v4().hashCode);

      fifo.add(one);
      fifo.add(two);
      fifo.add(three);
      fifo.add(four);
      fifo.add(five);

      var encoded = jsonEncode(fifo);
      var decoded = PushRequestQueue.fromJson(
          jsonDecode(encoded) as Map<String, dynamic>);

      expect(decoded, fifo);
    });
  });
}

void verifyCustomStringBufferWorks() {
  group('test custom string buffer', () {
    test('put elements in', () {
      CustomIntBuffer buffer = CustomIntBuffer();
      buffer.list = List();

      expect(buffer.maxSize, 20);
      expect(buffer.length, 0);

      buffer.put(1);
      buffer.put(2);
      buffer.put(3);

      expect(buffer.length, 3);

      expect(buffer.contains(1), true);
      expect(buffer.contains(2), true);
      expect(buffer.contains(3), true);
      expect(buffer.contains(4), false);

      for (int i = 3; i < buffer.maxSize; i++) {
        buffer.put(-1);
      }

      buffer.put(4);

      expect(buffer.length, 20);
      expect(buffer.maxSize, 20);

      expect(buffer.contains(1), false);
      expect(buffer.contains(2), true);
      expect(buffer.contains(3), true);
      expect(buffer.contains(4), true);
    });
  });
}
