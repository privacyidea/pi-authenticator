// /*
//  * privacyIDEA Authenticator
//  *
//  * Author: Frank Merkel <frank.merkel@netknights.it>
//  *
//  * Copyright (c) 2024 NetKnights GmbH
//  *
//  * Licensed under the Apache License, Version 2.0 (the 'License');
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an 'AS IS' BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */
// import 'package:flutter/material.dart';
// import 'package:privacyidea_authenticator/model/riverpod_states/token_filter.dart';

// import '../../../model/mixins/sortable_mixin.dart';
// import '../../../model/token_folder.dart';
// import '../../../model/tokens/token.dart';
// import 'folder_widgets/token_folder_widget.dart';
// import 'token_widgets/token_widget_builder.dart';

// abstract class SortableWidgetBuilder {
//   static Widget fromSortable(SortableMixin sortable, {Key? key, TokenFilter? filter}) {
//     if (sortable is TokenFolder) return TokenFolderWidget(folder: sortable, key: key, filter: filter);
//     if (sortable is Token) return TokenWidgetBuilder.fromToken(token: sortable, key: key);
//     throw UnimplementedError('Sortable type (${sortable.runtimeType}) not supported');
//   }
// }
