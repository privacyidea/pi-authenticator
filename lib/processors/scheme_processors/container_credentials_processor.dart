import 'package:privacyidea_authenticator/processors/scheme_processors/scheme_processor_interface.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_notifier_providers/token_container_state_provider.dart';

import '../../model/tokens/container_credentials.dart';

class ContainerCredentialsProcessor extends SchemeProcessor {
  @override
  Set<String> get supportedSchemes => {'container'}; // TODO: edit supportedSchemes to the real supported schemes
  List<String> get supportedHosts => ['credentials']; // TODO: edit supportedHosts to the real supported hosts

  const ContainerCredentialsProcessor();
  @override
  Future processUri(Uri uri, {bool fromInit = false}) async {
    if (!supportedHosts.contains(uri.host) || !supportedSchemes.contains(uri.scheme)) {
      return null;
    }
    final credential = ContainerCredential.fromUriMap(uri.queryParameters);
    globalRef?.read(credentialsProvider.notifier).addCredential(credential);
  }
}
