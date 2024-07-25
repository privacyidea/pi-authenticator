import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/states/token_folder_state.dart';
import '../../../../repo/preference_token_folder_repository.dart';
import '../../state_notifiers/token_folder_notifier.dart';
import '../../../logger.dart';

final tokenFolderProvider = StateNotifierProvider<TokenFolderNotifier, TokenFolderState>(
  (ref) {
    Logger.info("New TokenFolderNotifier created", name: 'tokenFolderProvider');
    return TokenFolderNotifier(repository: PreferenceTokenFolderRepository());
  },
  name: 'tokenFolderProvider',
);
