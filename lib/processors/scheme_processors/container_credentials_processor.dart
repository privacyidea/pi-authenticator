import 'package:privacyidea_authenticator/processors/scheme_processors/scheme_processor_interface.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

import '../../model/tokens/container_credentials.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/credential_nofitier.dart';

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
    Logger.warning('Adding credential to container', name: 'ContainerCredentialsProcessor');
    globalRef?.read(credentialsNotifierProvider.notifier).addCredential(credential);
  }
}
