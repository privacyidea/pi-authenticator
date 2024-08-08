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
abstract class ProcessorResult<T> {
  const ProcessorResult();
  factory ProcessorResult.success(T data) => ProcessorResultSuccess(data);
  factory ProcessorResult.failed(String errorMessage) => ProcessorResultFailed(errorMessage);
  bool get isSuccess => this is ProcessorResultSuccess<T>;
  ProcessorResultSuccess<T>? get asSuccess => this is ProcessorResultSuccess<T> ? this as ProcessorResultSuccess<T> : null;
  ProcessorResultFailed<T>? get asFailed => this is ProcessorResultFailed<T> ? this as ProcessorResultFailed<T> : null;
}

class ProcessorResultSuccess<T> extends ProcessorResult<T> {
  final T resultData;
  const ProcessorResultSuccess(this.resultData);

  @override
  String toString() {
    return 'ProcessorResultSuccess(data: $resultData)';
  }
}

class ProcessorResultFailed<T> extends ProcessorResult<T> {
  final String message;
  const ProcessorResultFailed(this.message);

  @override
  String toString() => '$runtimeType(message: $message)';
}
