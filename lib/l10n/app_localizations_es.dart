import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get accept => 'Aceptar';

  @override
  String get decline => 'Negar';

  @override
  String get name => 'Nombre';

  @override
  String get secretKey => 'Clave secreta';

  @override
  String get encoding => 'Codificación';

  @override
  String get algorithm => 'Algorithmo';

  @override
  String get digits => 'Dígitos';

  @override
  String get type => 'Tipo';

  @override
  String get period => 'Periodo';

  @override
  String get rename => 'Renombrar';

  @override
  String get cancel => 'Anular';

  @override
  String get delete => 'Borrar';

  @override
  String get dismiss => 'Desestimar';

  @override
  String get addToken => 'Añadir token';

  @override
  String get scanQrCode => 'Escanear código QR';

  @override
  String get enterDetailsForToken => 'Introduzca los datos de el token';

  @override
  String get pleaseEnterANameForThisToken => 'Introduzca un nombre para este token.';

  @override
  String get pleaseEnterASecretForThisToken => 'Por favor, introduzca un secreto para este token.';

  @override
  String get theSecretDoesNotFitTheCurrentEncoding => 'El secreto no se ajusta a la codificación actual';

  @override
  String get renameToken => 'Renombrar token';

  @override
  String get confirmDeletion => 'Confiem supresión';

  @override
  String confirmDeletionOf(Object name) {
    return '¿Está seguro de que desea eliminar $name?';
  }

  @override
  String get confirmTokenDeletionHint => 'Es posible que ya no pueda iniciar sesión si elimina este token.\nAsegúrese de que puede iniciar sesión en la cuenta asociada sin este token.';

  @override
  String get confirmFolderDeletionHint => 'Eliminar una carpeta no afecta a los tokens que contiene.\nLos tokens se mueven a la lista principal.';

  @override
  String get generatingPhonePart => 'Generar parte telefónico';

  @override
  String get phonePart => 'Pieza de teléfono:';

  @override
  String otpValueCopiedMessage(Object otpValue) {
    return 'Contraseña \"$otpValue\" copiada en el portapapeles.';
  }

  @override
  String get settings => 'Configuración';

  @override
  String get pushToken => 'Push Token';

  @override
  String get theme => 'Tema';

  @override
  String get lightTheme => 'Luminoso';

  @override
  String get darkTheme => 'Negro';

  @override
  String get systemTheme => 'Utilizar el tema del teléfono';

  @override
  String get enablePolling => 'Activar polling';

  @override
  String get requestPushChallengesPeriodically => 'Solicita retos push al servidor periódicamente. Habilite esta opción si los retos push no se reciben normalmente.';

  @override
  String get synchronizePushTokens => 'Sinchronizar push tokens';

  @override
  String get synchronizesTokensWithServer => 'Sinchronizar tokens con el privacyIDEA servidor.';

  @override
  String get sync => 'Sinchronizar';

  @override
  String get synchronizingTokens => 'Sincronización de los tokens.';

  @override
  String get allTokensSynchronized => 'Todas los tokens están sincronizadas.';

  @override
  String get synchronizationFailed => 'La sincronización ha fallado para los siguientes tokens, por favor inténtelo de nuevo:';

  @override
  String get tokensDoNotSupportSynchronization => 'Las siguientes tokens no admiten la sincronización y deben volver a desplegarse:';

  @override
  String errorRollOutFailed(Object name) {
    return 'Error en la extracción de el token $name.';
  }

  @override
  String statusCode(Object statusCode) {
    return 'Código de estado: $statusCode';
  }

  @override
  String get errorSynchronizationNoNetworkConnection => 'Error al sincronizar los tokens. No se ha podido acceder al servidor de PrivacyIDEA.';

  @override
  String errorRollOutNoConnectionToServer(Object name) {
    return 'El despliegue del token $name ha fallado, no se ha podido acceder al servidor.';
  }

  @override
  String errorRollOutUnknownError(Object e) {
    return 'An unknown error occurred. Roll-out not possible: $e';
  }

  @override
  String get rollingOut => 'Despliegue';

  @override
  String get pollingChallenges => 'Sondeo para nuevos challenges';

  @override
  String get unexpectedError => 'Se ha producido un error inesperado.';

  @override
  String get pollingFailed => 'Consulta fallida.';

  @override
  String pollingFailedFor(Object serial) {
    return 'Fallo de sondeo para $serial';
  }

  @override
  String get noNetworkConnection => 'No hay conexión a la red.';

  @override
  String get connectionFailed => 'Conexión fallida.';

  @override
  String get checkYourNetwork => 'Compruebe su conexión de red e inténtelo de nuevo.';

  @override
  String get serverNotReachable => 'No se ha podido acceder al servidor.';

  @override
  String get couldNotSignMessage => 'No se ha podido firmar el mensaje.';

  @override
  String get useDeviceLocaleTitle => 'Utiliza el idioma del teléfono';

  @override
  String get useDeviceLocaleDescription => 'Utilizar el idioma del dispositivo si está soportado, en caso contrario por defecto inglés.';

  @override
  String get language => 'Language';

  @override
  String get authenticateToShowOtp => 'Por favor, autentifíquese para mostrar la contraseña de una sola vez.';

  @override
  String get authenticateToUnLockToken => 'Por favor, autentifíquese para cambiar el estado de bloqueo del token.';

  @override
  String get biometricRequiredTitle => 'Biometría no configurada';

  @override
  String get biometricHint => 'AAutenticación necesaria';

  @override
  String get biometricNotRecognized => 'No reconocido. Inténtelo de nuevo.';

  @override
  String get biometricSuccess => 'Autenticación correcta';

  @override
  String get deviceCredentialsRequiredTitle => 'No se han configurado las credenciales del dispositivo.';

  @override
  String get deviceCredentialsSetupDescription => 'Configurar las credenciales del dispositivo en los ajustes del dispositivo';

  @override
  String get signInTitle => 'Autenticación necesaria';

  @override
  String get goToSettingsButton => 'Ir a la configuración';

  @override
  String get goToSettingsDescription => 'La autenticación por credenciales o biométrica no está configurada en tu dispositivo. Por favor, configúrala en los ajustes del dispositivo.';

  @override
  String get lockOut => 'La autenticación biométrica está desactivada. Bloquea y desbloquea la pantalla para activarla.';

  @override
  String get authNotSupportedTitle => 'Se requieren credenciales de dispositivo o datos biométricos';

  @override
  String get authNotSupportedBody => 'Esta acción requiere que el dispositivo esté protegido mediante credenciales o datos biométricos.';

  @override
  String get lock => 'Cierre';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get noResultTitle => 'Aún no hay tokens almacenadas.';

  @override
  String get noResultText1 => 'Indique el  ';

  @override
  String get noResultText2 => ' para empezar.';

  @override
  String onBoardingTitle1(Object appName) {
    return '$appName';
  }

  @override
  String get onBoardingText1 => 'Autenticación de dos factores\nmuy fácil';

  @override
  String get onBoardingTitle2 => 'Máxima seguridad';

  @override
  String get onBoardingText2 => 'Almacena fichas de forma segura en tu teléfono.\nProtegido por tus datos biométricos.';

  @override
  String get onBoardingTitle3 => 'Visítenos en Github';

  @override
  String get onBoardingText3 => 'Esta aplicación es de código abierto';

  @override
  String get errorLogTitle => 'Registro de errores';

  @override
  String get logMenu => 'Menú de registro';

  @override
  String get showErrorLog => 'Mostrar';

  @override
  String get clearErrorLog => 'Borrar';

  @override
  String get send => 'Enviar';

  @override
  String get sendErrorLogDescription => 'Se crea un correo electrónico listo.\nContiene información sobre la app, el error y el dispositivo.\nPuedes editar el correo antes de enviarlo.\nAquí puede ver cómo utilizamos la información:';

  @override
  String get showPrivacyPolicy => 'Mostrar política de privacidad';

  @override
  String get errorLogEmpty => 'El registro de errores está vacío';

  @override
  String get verboseLogging => 'Registro detallado';

  @override
  String get errorLogCleared => 'Registro de errores borrado';

  @override
  String get ok => 'Ok';

  @override
  String get errorMailBody => 'Se adjunta el archivo de registro de errores.\nPuede sustituir este texto por información adicional sobre el error.';

  @override
  String get showDetails => 'Mostrar detalles';

  @override
  String get open => 'Abrir';

  @override
  String get sendErrorDialogBody => 'Se ha producido un error inesperado en la aplicación. La siguiente información puede ser enviada a los desarrolladores por correo electrónico para ayudar a prevenir este error en el futuro.';

  @override
  String get noFbToken => 'No hay token de Firebase.';

  @override
  String get firebaseToken => 'Token de Firebase';

  @override
  String get noPublicKey => 'No hay clave pública.';

  @override
  String get publicKey => 'Clave pública';

  @override
  String get editToken => 'Editar token';

  @override
  String get edit => 'Editar';

  @override
  String get save => 'Guardar';

  @override
  String get validFor => 'Válido para';

  @override
  String get validUntil => 'Válido hasta';

  @override
  String get deleteLockedToken => 'Por favor, autentíquese para eliminar el token bloqueado.';

  @override
  String get editLockedToken => 'Por favor, autentíquese para editar el token bloqueado.';

  @override
  String get uncollapseLockedFolder => 'Por favor, autentifíquese para abrir la carpeta bloqueada.';

  @override
  String get renameTokenFolder => 'Cambiar nombre de carpeta';

  @override
  String get addANewFolder => 'Crear nueva carpeta';

  @override
  String get folderName => 'Nombre de la carpeta';

  @override
  String get retryRollout => 'Reintentar despliegue';

  @override
  String get generatingRSAKeyPair => 'Generando par de claves RSA';

  @override
  String get generatingRSAKeyPairFailed => 'Error al generar el par de claves RSA';

  @override
  String get sendingRSAPublicKey => 'Enviando clave pública RSA';

  @override
  String get sendingRSAPublicKeyFailed => 'Error al enviar la clave pública RSA';

  @override
  String get parsingResponse => 'Analizando la respuesta';

  @override
  String get parsingResponseFailed => 'Error al analizar la respuesta';

  @override
  String get rolloutCompleted => 'Despliegue completado';

  @override
  String get authToAcceptPushRequest => 'Por favor, autentifíquese para aceptar la solicitud push.';

  @override
  String get authToDeclinePushRequest => 'Por favor, autentifíquese para rechazar la solicitud push.';

  @override
  String get pushRequestParseError => 'No se ha podido procesar la solicitud push.';

  @override
  String get imageUrl => 'URL de la imagen';

  @override
  String get errorRollOutSSLHandshakeFailed => 'Ha fallado el protocolo SSL. No es posible el despliegue.';

  @override
  String errorWhenPullingChallenges(Object name) {
    return 'Se ha producido un error al buscar retos de $name';
  }

  @override
  String get errorRollOutNotPossibleAnymore => 'El despliegue de este token ya no es posible.';

  @override
  String errorTokenExpired(Object name) {
    return 'El token $name ha caducado.';
  }

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get butDiscardIt => 'pero descártelo';

  @override
  String get declineIt => 'rechazar';

  @override
  String get requestTriggerdByUserQuestion => '¿Fue usted quien provocó esta petición?';

  @override
  String get grantCameraPermissionDialogTitle => 'El permiso de cámara no está concedido';

  @override
  String get grantCameraPermissionDialogContent => 'Por favor, concede permiso a la cámara para escanear códigos QR';

  @override
  String get grantCameraPermissionDialogPermanentlyDenied => 'El permiso de cámara está denegado permanentemente. Concede el permiso de cámara en la configuración del teléfono';

  @override
  String get grantCameraPermissionDialogButton => 'Conceder permiso';

  @override
  String get decryptErrorTitle => 'Error de descifrado';

  @override
  String get decryptErrorContent => 'Lamentablemente, la aplicación no ha podido descifrar tus tokens. Esto indica que la clave de cifrado está rota. Puedes volver a intentarlo o borrar los datos de la app, lo que eliminaría los tokens de la app.';

  @override
  String get decryptErrorButtonDelete => 'Borrar';

  @override
  String get decryptErrorButtonSendError => 'Enviar error';

  @override
  String get decryptErrorButtonRetry => 'Reintentar';

  @override
  String get decryptErrorDeleteConfirmationContent => '¿Estás seguro de que quieres borrar los datos de la aplicación?';

  @override
  String get hidePushTokens => 'Ocultar tokens push';

  @override
  String get hidePushTokensDescription => 'Ocultar tokens push de la lista de tokens. Esto no borrará los tokens y seguirán siendo visibles en una pantalla aparte';

  @override
  String get settingsGroupGeneral => 'Información general';

  @override
  String get licensesAndVersion => 'Licencias y versión';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get introScanQrCode => 'You can scan QR codes to add tokens.\nWe support every common Two-Factor-Authentication token and also the privacyIDEA tokens.';

  @override
  String get introAddTokenManually => 'If you don\'t want to scan a QR code, you can also add tokens manually.';

  @override
  String get introTokenSwipe => 'Swipe tokens to the left to see available actions.';

  @override
  String get introEditToken => 'Here you can edit the token name and see some details.';

  @override
  String get introLockToken => 'To improve security even more, you can lock tokens.\nThen the token can only be used after authentication.';

  @override
  String get introDragToken => 'Reorganize your tokens by pressing it for a few seconds and then dragging it to the desired position.';

  @override
  String get introAddFolder => 'You can create folders\nto organize your tokens.';

  @override
  String get introPollForChallenges => 'You can check for new challenges by dragging down the token list.';

  @override
  String get introHidePushTokens => 'Your push tokens are hidden now.\nBut you can still see them on the push token screen.';

  @override
  String legacySigningErrorTitle(Object tokenLabel) {
    return 'Se ha producido un error al utilizar el token obsoleto: $tokenLabel';
  }

  @override
  String get legacySigningErrorMessage => 'El token se creó en una versión obsoleta de la aplicación, lo que puede provocar problemas al utilizarlo.\nSe recomienda crear un nuevo token push si el problema persiste.';

  @override
  String get selectImportSource => 'Seleccionar fuente de importación';

  @override
  String get selectImportType => 'Jak chcete importovat žetony?';

  @override
  String get importTokens => 'Importar token';

  @override
  String get selectFile => 'Seleccionar archivo';

  @override
  String get decrypt => 'Descifrar';

  @override
  String get tokensAreEncrypted => 'Los tokens están encriptados. Por favor, introduce la contraseña para descifrarlos';

  @override
  String get tokensNotEncrypted => 'Los tokens no están encriptados y se pueden importar directamente';

  @override
  String get tokensSuccessfullyDecrypted => 'Los tokens se han descifrado correctamente y ya se pueden importar.';

  @override
  String get password => 'Contraseña';

  @override
  String get wrongPassword => 'Contraseña incorrecta';

  @override
  String get qrScan => 'Escanear';

  @override
  String get enterLink => 'Introducir enlace';

  @override
  String invalidBackupFile(Object appName) {
    return 'El archivo seleccionado no es una copia de seguridad válida de $appName';
  }

  @override
  String invalidQrScan(Object appName) {
    return 'El código QR escaneado no es una copia de seguridad válida de $appName';
  }

  @override
  String invalidQrFile(Object appName) {
    return 'El archivo seleccionado no contiene un código QR válido de $appName';
  }

  @override
  String invalidLink(Object appName) {
    return 'El enlace introducido no es un token válido de $appName, o no es compatible';
  }

  @override
  String importExistingToken(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se han encontrado $count tokens que ya están en la aplicación.',
      one: 'Se ha encontrado un token que ya existe en la aplicación.',
      zero: 'No se ha encontrado ningún token que ya esté en la aplicación.',
    );
    return '$_temp0';
  }

  @override
  String importConflictToken(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hay un conflicto con tokens que ya existen.\nPor favor, seleccione cuál le gustaría conservar.',
      one: 'Hay un conflicto con tokens que ya existen.\nPor favor, seleccione cuál le gustaría conservar.',
      zero: 'No hay conflicto con tokens que ya existen.',
    );
    return '$_temp0';
  }

  @override
  String importNewToken(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se ha encontrado un nuevo token $count que se importará.',
      one: 'Se ha encontrado un nuevo token que se importará.',
      zero: 'No se ha encontrado un nuevo token.',
    );
    return '$_temp0';
  }

  @override
  String get importHint2FAS => 'Seleccione su copia de seguridad de 2FAS. Si no tiene una copia de seguridad, cree una en la aplicación 2FAS. Le recomendamos que utilice una contraseña';

  @override
  String get importHintAegisBackupFile => 'Seleccione su exportación de Aegis (.JSON).\nSi no tiene una exportación, cree una a través del menú de configuración en la app de Aegis. Se recomienda utilizar una contraseña';

  @override
  String get importHintAegisQrScan => 'Escanea el código QR que recibes al transferir entradas desde Aegis';

  @override
  String get importHintAegisLink => 'Introduzca el enlace que recibe al transferir entradas desde Aegis';

  @override
  String get importHintGoogleQrScan => 'Escanea el código QR que recibes al exportar tus cuentas desde Google Authenticator';

  @override
  String get importHintGoogleQrFile => 'Selecciona un archivo de imagen con el código QR que recibes al exportar tus cuentas desde Google Authenticator.\n!! Tenga en cuenta que no es seguro guardar el código QR en su dispositivo, ya que los tokens no están cifrados !!';

  @override
  String get qrFileDecodeError => 'No fue posible decodificar el código QR de la imagen seleccionada, por favor utilice el escáner de código QR en su lugar.';

  @override
  String get tokenLink => 'Enlace token';

  @override
  String get feedback => 'Comentarios';

  @override
  String get feedbackTitle => '¡Tus comentarios son siempre bienvenidos!';

  @override
  String get feedbackDescription => 'Si tienes alguna pregunta, sugerencia o problema, háznoslo saber';

  @override
  String get feedbackHint => 'Se abrirá un correo electrónico preparado que podrá enviarnos. Si lo desea, se añadirá información sobre su dispositivo y la versión de la aplicación. Puede comprobar y editar el correo electrónico antes de enviarlo.';

  @override
  String get feedbackPrivacyPolicy1 => 'Al enviar sus comentarios, acepta nuestra ';

  @override
  String get feedbackPrivacyPolicy2 => 'política de privacidad';

  @override
  String get feedbackPrivacyPolicy3 => '.';

  @override
  String get addSystemInfo => 'Añadir información del sistema';

  @override
  String get feedbackThanks => '¡Gracias por sus comentarios!';
}
