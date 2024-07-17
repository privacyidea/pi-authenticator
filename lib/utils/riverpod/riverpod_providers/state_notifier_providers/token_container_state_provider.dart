import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../api/token_container_api_endpoint.dart';
import '../../../../model/states/token_container_state.dart';
import '../../../../repo/token_container_state_repositorys/hybrid_token_container_state_repository.dart';
import '../../../../repo/token_container_state_repositorys/preference_token_container_state_repository.dart.dart';
import '../../../../repo/token_container_state_repositorys/remote_token_container_state_repository.dart';
import '../../../../state_notifiers/token_container_notifier.dart';
import '../../../logger.dart';

final tokenContainerStateProvider = StateNotifierProvider<TokenContainerNotifier, TokenContainerState>((ref) {
  Logger.info("New tokenContainerStateProvider created", name: 'tokenContainerStateProvider');
  return TokenContainerNotifier(
    // ref: ref,
    repository: HybridTokenContainerStateRepository(
      localRepository: SecureTokenContainerStateRepository('placeholder'), // TODO: Implement containerId
      syncedRepository: SecureTokenContainerStateRepository('placeholder'), // TODO: Implement containerId
      remoteRepository: RemoteTokenContainerStateRepository(
        apiEndpoint: TokenContainerApiEndpoint(), // TODO: Nochmal anschauen
        containerId: 'placeholder', // TODO: Implement containerId
      ),
    ),
  );
});
