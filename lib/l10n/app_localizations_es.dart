import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get a11yAddFolderButton => 'Añadir carpeta';

  @override
  String get a11yAddTokenManuallyButton => 'Añadir token manualmente';

  @override
  String get a11yCloseSearchTokensButton => 'Cerrar búsqueda';

  @override
  String get a11yLicensesButton => 'Licencias';

  @override
  String get a11yPushTokensButton => 'Push Tokens';

  @override
  String get a11yScanQrCodeButton => 'Escanear código QR';

  @override
  String get a11yScanQrCodeViewActive => 'Vista de escaneo de código QR. Cammera está activa';

  @override
  String get a11yScanQrCodeViewFlashlightOff => 'Toque para encender la linterna.';

  @override
  String get a11yScanQrCodeViewFlashlightOn => 'Toque para apagar la linterna.';

  @override
  String get a11yScanQrCodeViewGallery => 'Abrir galería';

  @override
  String get a11yScanQrCodeViewInactive => 'Vista de escaneo de código QR. La cámara no está activa';

  @override
  String get a11ySearchTokensButton => 'Buscar tokens';

  @override
  String get a11ySettingsButton => 'Ajustes';

  @override
  String get accept => 'Aceptar';

  @override
  String get addANewFolder => 'Crear nueva carpeta';

  @override
  String get addSystemInfo => 'Añadir información del sistema';

  @override
  String get addToken => 'Añadir token';

  @override
  String get additionalErrorMessage => 'Mensaje opcional';

  @override
  String get algorithm => 'Algorithmo';

  @override
  String algorithmUnsupported(String algorithm) {
    return 'El algoritmo $algorithm no es compatible';
  }

  @override
  String get allTokensSynchronized => 'Todas los tokens están sincronizadas.';

  @override
  String get asFile => 'Como archivo';

  @override
  String get asQrCode => 'Como código QR';

  @override
  String get askLogSendedDescription => '¿Ha enviado el registro y desea borrarlo ahora?';

  @override
  String get authNotSupportedBody => 'Esta acción requiere que el dispositivo esté protegido mediante credenciales o datos biométricos.';

  @override
  String get authNotSupportedTitle => 'Se requieren credenciales de dispositivo o datos biométricos';

  @override
  String get authToAcceptPushRequest => 'Por favor, autentifíquese para aceptar la solicitud push.';

  @override
  String get authToDeclinePushRequest => 'Por favor, autentifíquese para rechazar la solicitud push.';

  @override
  String get authenticateToShowOtp => 'Por favor, autentifíquese para mostrar la contraseña de una sola vez.';

  @override
  String get authenticateToUnLockToken => 'Por favor, autentifíquese para cambiar el estado de bloqueo del token.';

  @override
  String get authenticationRequest => 'Autenticación';

  @override
  String get biometricHint => 'AAutenticación necesaria';

  @override
  String get biometricNotRecognized => 'No reconocido. Inténtelo de nuevo.';

  @override
  String get biometricRequiredTitle => 'Biometría no configurada';

  @override
  String get biometricSuccess => 'Autenticación correcta';

  @override
  String get butDiscardIt => 'pero descártelo';

  @override
  String get cancel => 'Anular';

  @override
  String get checkServerCertificate => 'Compruebe el certificado del servidor';

  @override
  String get checkYourNetwork => 'Compruebe su conexión de red e inténtelo de nuevo.';

  @override
  String get clearErrorLog => 'Borrar';

  @override
  String get clipboardEmpty => 'El portapapeles está vacío';

  @override
  String get confirmDeletion => 'Confiem supresión';

  @override
  String confirmDeletionOf(String name) {
    return '¿Está seguro de que desea eliminar $name?';
  }

  @override
  String get confirmFolderDeletionHint => 'Eliminar una carpeta no afecta a los tokens que contiene.\nLos tokens se mueven a la lista principal.';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get confirmTokenDeletionHint => 'Es posible que ya no pueda iniciar sesión si elimina este token.\nAsegúrese de que puede iniciar sesión en la cuenta asociada sin este token.';

  @override
  String get confirmation => 'confirmación';

  @override
  String get connectionFailed => 'Conexión fallida.';

  @override
  String get container => 'Contenedor';

  @override
  String get containerAlreadyExists => 'El contenedor ya existe';

  @override
  String get containerDetails => 'Detalles del contenedor';

  @override
  String get containerSerial => 'Contenedor de serie';

  @override
  String get containerSyncUrl => 'Url de sincronización de contenedores';

  @override
  String get continueButton => 'Continue';

  @override
  String get copyOTPToClipboard => 'Copiar OTP al portapapeles';

  @override
  String get couldNotConnectToServer => 'No se ha podido conectar con el servidor.';

  @override
  String get couldNotSignMessage => 'No se ha podido firmar el mensaje.';

  @override
  String get counter => 'Contador';

  @override
  String get create => 'Crear';

  @override
  String get createdAt => 'Creado el';

  @override
  String get creator => 'Creador';

  @override
  String get dayPasswordValidFor => 'Válido para';

  @override
  String get dayPasswordValidUntil => 'Válido hasta';

  @override
  String get decline => 'Negar';

  @override
  String get declineIt => 'rechazar';

  @override
  String get decrypt => 'Descifrar';

  @override
  String get decryptErrorButtonDelete => 'Borrar';

  @override
  String get decryptErrorButtonRetry => 'Reintentar';

  @override
  String get decryptErrorButtonSendError => 'Enviar error';

  @override
  String get decryptErrorContent => 'Lamentablemente, la aplicación no ha podido descifrar tus tokens. Esto indica que la clave de cifrado está rota. Puedes volver a intentarlo o borrar los datos de la app, lo que eliminaría los tokens de la app.';

  @override
  String get decryptErrorDeleteConfirmationContent => '¿Estás seguro de que quieres borrar los datos de la aplicación?';

  @override
  String get decryptErrorTitle => 'Error de descifrado';

  @override
  String get delete => 'Borrar';

  @override
  String get deleteContainerDialogContent => 'Si elimina este contenedor, el smartphone se desconectará del servidor privacyIDEA y los tokens de este contenedor quedarán inutilizables. Antes de eliminarlo, asegúrate de que los tokens correspondientes ya no son necesarios.';

  @override
  String deleteContainerDialogTitle(String serial) {
    return 'Borrar contenedor $serial';
  }

  @override
  String get deleteLockedToken => 'Por favor, autentíquese para eliminar el token bloqueado.';

  @override
  String get details => 'Detalles';

  @override
  String get deviceCredentialsRequiredTitle => 'No se han configurado las credenciales del dispositivo.';

  @override
  String get deviceCredentialsSetupDescription => 'Configurar las credenciales del dispositivo en los ajustes del dispositivo';

  @override
  String get digits => 'Dígitos';

  @override
  String get dismiss => 'Desestimar';

  @override
  String get done => 'Hecho';

  @override
  String get edit => 'Editar';

  @override
  String get editLockedToken => 'Por favor, autentíquese para editar el token bloqueado.';

  @override
  String get editToken => 'Editar token';

  @override
  String get enablePolling => 'Activar polling';

  @override
  String get encoding => 'Codificación';

  @override
  String get enterDetailsForToken => 'Introduzca los datos de el token';

  @override
  String get enterLink => 'Introducir enlace';

  @override
  String get enterPasswordToEncrypt => 'Ingrese una contraseña para cifrar los tokens. Esta contraseña será necesaria para importar los tokens.';

  @override
  String get errorLogCleared => 'Registro de errores borrado';

  @override
  String get errorLogEmpty => 'El registro de errores está vacío';

  @override
  String get errorLogTitle => 'Registro de errores';

  @override
  String get errorMailBody => 'Se adjunta el archivo de registro de errores.\nPuede sustituir este texto por información adicional sobre el error.';

  @override
  String get errorMissingPrivateKey => 'Falta la clave privada';

  @override
  String errorRollOutFailed(String name) {
    return 'Error en la extracción de el token $name.';
  }

  @override
  String errorRollOutNoConnectionToServer(String name) {
    return 'El despliegue del token $name ha fallado, no se ha podido acceder al servidor.';
  }

  @override
  String get errorRollOutNotPossibleAnymore => 'El despliegue de este token ya no es posible.';

  @override
  String get errorRollOutSSLHandshakeFailed => 'Ha fallado el protocolo SSL. No es posible el despliegue.';

  @override
  String errorRollOutUnknownError(String e) {
    return 'An unknown error occurred. Roll-out not possible: $e';
  }

  @override
  String get errorSavingFile => 'Error al guardar el archivo';

  @override
  String get errorSynchronizationNoNetworkConnection => 'Error al sincronizar los tokens. No se ha podido acceder al servidor de PrivacyIDEA.';

  @override
  String errorTokenExpired(String name) {
    return 'El token $name ha caducado.';
  }

  @override
  String errorUnlinkingPushToken(String label) {
    return 'Error al desvincular el token push $label';
  }

  @override
  String errorWhenPullingChallenges(String name) {
    return 'Se ha producido un error al buscar retos de $name';
  }

  @override
  String get exampleUrl => 'Por favor, introduzca una URL válida como: \"https://example.com/\"';

  @override
  String get expandLockedFolder => 'Por favor, autentifíquese para abrir la carpeta bloqueada.';

  @override
  String get export => 'Exportar';

  @override
  String get exportAllTokens => 'Exportar todos los tokens';

  @override
  String get exportLockedTokenReason => 'Por favor, autentíquese para exportar tokens bloqueados.';

  @override
  String get exportNonPrivacyIDEATokens => 'Exportar tokens no privacyIDEA';

  @override
  String get exportOneMore => 'Uno más';

  @override
  String get exportTokens => 'Exportar tokens';

  @override
  String get exportingTokens => 'Exportando tokens...';

  @override
  String failedToFinalizeContainer(String serial) {
    return 'Fallo al finalizar el contenedor $serial';
  }

  @override
  String failedToLoad(String name) {
    return 'Fallo al cargar: $name';
  }

  @override
  String failedToSyncContainer(String serial) {
    return 'Fallo al sincronizar el contenedor $serial';
  }

  @override
  String get feedback => 'Comentarios';

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
  String get feedbackSentDescription => 'Muchas gracias por su ayuda para mejorar esta aplicación.';

  @override
  String get feedbackSentTitle => 'Comentarios enviados';

  @override
  String get feedbackTitle => '¡Tus comentarios son siempre bienvenidos!';

  @override
  String get fileSavedToDownloadsFolder => 'Archivo guardado en la carpeta de descargas';

  @override
  String get finalizationState => 'Estado de finalización';

  @override
  String get finalizeContainerFailed => 'Finalizar Contenedor Fallido';

  @override
  String get firebaseToken => 'Token de Firebase';

  @override
  String get folderName => 'Nombre de la carpeta';

  @override
  String get generatingPhonePart => 'Generar parte telefónico';

  @override
  String get gitHubButton => 'Esta aplicación es de código abierto\nVisítanos en GitHub';

  @override
  String get goToSettingsButton => 'Ir a la configuración';

  @override
  String get goToSettingsDescription => 'La autenticación por credenciales o biométrica no está configurada en tu dispositivo. Por favor, configúrala en los ajustes del dispositivo.';

  @override
  String get grantCameraPermissionDialogButton => 'Conceder permiso';

  @override
  String get grantCameraPermissionDialogContent => 'Por favor, concede permiso a la cámara para escanear códigos QR';

  @override
  String get grantCameraPermissionDialogPermanentlyDenied => 'El permiso de cámara está denegado permanentemente. Concede el permiso de cámara en la configuración del teléfono';

  @override
  String get grantCameraPermissionDialogTitle => 'El permiso de cámara no está concedido';

  @override
  String get handshakeFailed => 'Handshake fallido';

  @override
  String get hidePushTokens => 'Ocultar tokens push';

  @override
  String get hidePushTokensDescription => 'Ocultar tokens push de la lista de tokens. Esto no borrará los tokens y seguirán siendo visibles en una pantalla aparte';

  @override
  String get imageUrl => 'URL de la imagen';

  @override
  String importConflictToken(int count) {
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
  String importExistingToken(int count) {
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
  String get importExportTokens => 'Importar/Exportar tokens';

  @override
  String importFailedToken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Error al importar $count tokens.',
      one: 'Error al importar un token.',
      zero: 'No token Fallo al importar.',
    );
    return '$_temp0';
  }

  @override
  String get importHint2FAS => 'Seleccione su copia de seguridad de 2FAS. Si no tiene una copia de seguridad, cree una en la aplicación 2FAS. Le recomendamos que utilice una contraseña';

  @override
  String get importHintAegisBackupFile => 'Seleccione su exportación de Aegis (.JSON).\nSi no tiene una exportación, cree una a través del menú de configuración en la app de Aegis. Se recomienda utilizar una contraseña';

  @override
  String get importHintAegisLink => 'Introduzca el enlace que recibe al transferir entradas desde Aegis';

  @override
  String get importHintAegisQrScan => 'Escanea el código QR que recibes al transferir entradas desde Aegis';

  @override
  String get importHintAuthenticatorProFile => 'Para crear una copia de seguridad de la aplicación Authenticator Pro, vaya a la configuración y pulse en \"Copia de seguridad automática\". Seleccione una ubicación de almacenamiento y establezca una contraseña. A continuación, pulse \"Hacer copia de seguridad ahora\" para exportar los tokens.';

  @override
  String get importHintFreeOtpPlusFile => 'Para crear una copia de seguridad de la app FreeOTP+, pulse los tres puntos de la esquina superior derecha y seleccione \"Exportar\". Puede elegir entre los formatos JSON y URI. Recomendamos eliminar la copia de seguridad después de importarla, ya que no está cifrada.';

  @override
  String get importHintFreeOtpPlusQrScan => 'Escanea el código QR que recibes al pulsar los tres puntos en el azulejo de la ficha y selecciona \"Compartir código QR\".';

  @override
  String get importHintGoogleQrFile => 'Selecciona un archivo de imagen con el código QR que recibes al exportar tus cuentas desde Google Authenticator.\n!! Tenga en cuenta que no es seguro guardar el código QR en su dispositivo, ya que los tokens no están cifrados !!';

  @override
  String get importHintGoogleQrScan => 'Escanea el código QR que recibes al exportar tus cuentas desde Google Authenticator';

  @override
  String get importHintPrivacyIdeaFile => 'Para crear una copia de seguridad, vaya a los ajustes y pulse sobre \"Exportar\". Seleccione \"Como archivo\", seleccione los tokens que desea exportar. A continuación, pulse \"Exportar\" y establezca una contraseña. La ubicación de almacenamiento es la carpeta de descargas de su dispositivo.';

  @override
  String get importHintPrivacyIdeaQrScan => 'Para crear códigos QR de las fichas, vaya a la configuración y pulse sobre \"Exportar\". A continuación, seleccione \"Como código QR\" y pulse sobre la ficha que desea exportar. Esta variante sólo es adecuada para la transferencia directa a otro dispositivo, ya que el código QR no está cifrado.';

  @override
  String importNTokens(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importar $count tokens',
      one: 'Importar un token',
      zero: 'No importar tokens',
    );
    return '$_temp0';
  }

  @override
  String importNewToken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se han encontrado $count nuevos tokens que se pueden importar.',
      one: 'Se ha encontrado un nuevo token que se puede importar.',
      zero: 'No se ha encontrado ningún token nuevo.',
    );
    return '$_temp0';
  }

  @override
  String get importTokens => 'Importar token';

  @override
  String get importantInformationTitle => 'Important information';

  @override
  String get importedVia => 'Importado a través de';

  @override
  String get increaseCounter => 'Incrementar contador';

  @override
  String internalServerError(String code) {
    return 'Error interno del servidor ($code)';
  }

  @override
  String get introAddFolder => 'Puedes crear carpetas para organizar tus tokens';

  @override
  String get introAddTokenManually => 'Si no quieres escanear un código QR, también puedes añadir tokens manualmente';

  @override
  String get introDragToken => 'Reorganiza tus tokens pulsándolo durante unos segundos y arrastrándolo a la posición deseada';

  @override
  String get introEditToken => 'Aquí puedes editar el nombre del token y ver algunos detalles';

  @override
  String get introHidePushTokens => 'Tus push tokens están ahora ocultos.\nPero puedes seguir viéndolos en la pantalla de push tokens.';

  @override
  String get introLockToken => 'Para mejorar la seguridad aún más, puedes bloquear los tokens.\nEntonces el token sólo se puede utilizar después de la autenticación.';

  @override
  String get introPollForChallenges => 'Puedes buscar nuevos retos arrastrando hacia abajo la lista de tokens';

  @override
  String get introScanQrCode => 'Puedes escanear códigos QR para añadir tokens.\nSoportamos todos los tokens comunes de Two-Factor-Authentication y también los tokens privacyIDEA';

  @override
  String get introTokenSwipe => 'Desliza los tokens hacia la izquierda para ver las acciones disponibles';

  @override
  String invalidBackupFile(String appName) {
    return 'El archivo seleccionado no es una copia de seguridad válida de $appName';
  }

  @override
  String invalidLink(String appName) {
    return 'El enlace introducido no es un token válido de $appName, o no es compatible';
  }

  @override
  String invalidQrFile(String appName) {
    return 'El archivo seleccionado no contiene un código QR válido de $appName';
  }

  @override
  String invalidQrScan(String appName) {
    return 'El código QR escaneado no es una copia de seguridad válida de $appName';
  }

  @override
  String get invalidUrl => 'URL no válida';

  @override
  String invalidValue(String parameter, String type, String value) {
    return 'El $type \'$value\' no es válido para \'$parameter\'.';
  }

  @override
  String invalidValueIn(String map, String parameter, String type, String value) {
    return 'El $type \'$value\' no es válido para \'$parameter\' en \'$map\'';
  }

  @override
  String get isExpotableQuestion => '¿Es exportable?';

  @override
  String get isPiTokenQuestion => '¿Es un token de privacyIDEA?';

  @override
  String get issuer => 'Emisor';

  @override
  String issuerLabel(String name) {
    return 'Emisor: $name';
  }

  @override
  String get language => 'Language';

  @override
  String get legacySigningErrorMessage => 'El token se creó en una versión obsoleta de la aplicación, lo que puede provocar problemas al utilizarlo.\nSe recomienda crear un nuevo token push si el problema persiste.';

  @override
  String legacySigningErrorTitle(String tokenLabel) {
    return 'Se ha producido un error al utilizar el token obsoleto: $tokenLabel';
  }

  @override
  String get licensesAndVersion => 'Licencias y versión';

  @override
  String get linkMustOtpAuth => 'El enlace debe empezar por otpauth://';

  @override
  String get linkedContainer => 'Contenedor vinculado';

  @override
  String get lock => 'Cierre';

  @override
  String get lockOut => 'La autenticación biométrica está desactivada. Bloquea y desbloquea la pantalla para activarla.';

  @override
  String get logMenu => 'Menú de registro';

  @override
  String get malformedData => 'Datos mal formados';

  @override
  String get markQrCode => 'Marcar código QR';

  @override
  String missingRequiredParameter(String parameter) {
    return 'El valor del parámetro [$parameter] es obligatorio, pero falta.';
  }

  @override
  String missingRequiredParameterIn(String map, String parameter) {
    return 'El valor del parámetro [$parameter] es obligatorio, pero falta en \"$map\".';
  }

  @override
  String mustNotBeEmpty(String field) {
    return '$field no debe estar vacío';
  }

  @override
  String get name => 'Nombre';

  @override
  String get no => 'No';

  @override
  String get noFbToken => 'No hay token de Firebase.';

  @override
  String get noMailAppDescription => 'No hay ninguna app de correo electrónico instalada o inicializada en este dispositivo, inténtalo de nuevo cuando puedas enviar un mensaje de correo electrónico.';

  @override
  String get noMailAppTitle => 'No hay aplicación de correo electrónico';

  @override
  String get noNetworkConnection => 'No hay conexión a la red.';

  @override
  String get noPublicKey => 'No hay clave pública.';

  @override
  String get noResultText1 => 'Indique el  ';

  @override
  String get noResultText2 => ' para empezar.';

  @override
  String get noResultTitle => 'Aún no hay tokens almacenadas.';

  @override
  String get noTokenToExport => 'No hay token disponible para exportar';

  @override
  String get noTokenToImport => 'No se ha encontrado ningún token para importar';

  @override
  String get notAnInteger => 'El valor no es un entero.';

  @override
  String get notAnNumber => 'El valor no es un número.';

  @override
  String get ok => 'Ok';

  @override
  String get open => 'Abrir';

  @override
  String get originApp => 'Aplicación Origen';

  @override
  String get originDetails => 'Datos de origen';

  @override
  String otpValueCopiedMessage(String otpValue) {
    return 'Contraseña \"$otpValue\" copiada en el portapapeles.';
  }

  @override
  String get password => 'Contraseña';

  @override
  String get passwordCannotBeEmpty => 'La contraseña no puede estar vacía';

  @override
  String get passwordCannotContainWhitespace => 'La contraseña no puede contener espacios en blanco';

  @override
  String get passwordMustBeAtLeast8Characters => 'La contraseña debe tener al menos 8 caracteres';

  @override
  String get passwordMustContainLowercaseLetter => 'La contraseña debe contener una letra minúscula';

  @override
  String get passwordMustContainNumber => 'La contraseña debe contener un número';

  @override
  String get passwordMustContainSpecialCharacter => 'La contraseña debe contener un carácter especial';

  @override
  String get passwordMustContainUppercaseLetter => 'La contraseña debe contener una letra mayúscula';

  @override
  String get passwordsDoNotMatch => 'Las contraseña no coinciden';

  @override
  String get patchNotesBugFixes => 'Corrección de errores';

  @override
  String get patchNotesDialogTitle => '¿Qué hay de nuevo?';

  @override
  String get patchNotesImprovements => 'Mejoras';

  @override
  String get patchNotesNewFeatures => 'Nuevas características';

  @override
  String get patchNotesV4_3_0NewFeatures1 => 'Añadido soporte para importar tokens de Google, Aegis y 2FAS Authenticator. En el futuro se añadirán más fuentes de importación';

  @override
  String get patchNotesV4_3_0NewFeatures2 => 'Añadida opción de feedback a los ajustes';

  @override
  String get patchNotesV4_3_0NewFeatures3 => 'Los tokens push ahora se pueden ocultar de la lista de tokens';

  @override
  String get patchNotesV4_3_0NewFeatures4 => 'Se han añadido introducciones para ayudar a los nuevos usuarios a empezar';

  @override
  String get patchNotesV4_3_0NewFeatures5 => 'Ahora puedes buscar tokens tocando la lupa de la esquina superior derecha';

  @override
  String get patchNotesV4_3_0NewFeatures6 => 'Añadido Token HomeWidget para Android 12 y posteriores';

  @override
  String get patchNotesV4_3_1BugFix1 => 'Se ha corregido un problema donde el valor OTP no se mostraba después de la autenticación en algunos dispositivos.';

  @override
  String get patchNotesV4_3_1Improvement1 => 'Se ha mejorado el escáner de códigos QR.';

  @override
  String get patchNotesV4_4_0Improvement1 => 'Se han añadido más fuentes de importación.';

  @override
  String get patchNotesV4_4_0Improvement2 => 'Se ha mejorado el reconocimiento de códigos QR a partir de archivos de imagen.';

  @override
  String get patchNotesV4_4_0NewFeatures1 => 'Ahora es posible exportar tokens cuando se puede garantizar que no son tokens de privacyIDEA. Actualmente, no se puede descartar que los tokens añadidos a través del escáner de código QR procedan de privacyIDEA. La diferenciación se mejorará en futuras versiones.';

  @override
  String get patchNotesV4_4_0NewFeatures2 => 'Añadido soporte para privacyIDEA\'s \"require presence\".';

  @override
  String get patchNotesV4_4_2Improvement1 => 'Añadido soporte linterna para el escaneo de códigos QR.';

  @override
  String get patchNotesV4_4_2NewFeatures1 => 'Ahora es posible insertar tokens copiando y pegando.';

  @override
  String get patchNotesV4_4_2NewFeatures2 => 'Añadido soporte de galería para el escaneo de códigos QR.';

  @override
  String get period => 'Periodo';

  @override
  String get phonePart => 'Pieza de teléfono:';

  @override
  String piServerCode(String code) {
    return 'Código del servidor PI: $code';
  }

  @override
  String get pleaseEnterANameForThisToken => 'Introduzca un nombre para este token.';

  @override
  String get pleaseEnterASecretForThisToken => 'Por favor, introduzca un secreto para este token.';

  @override
  String get pollingFailed => 'Consulta fallida.';

  @override
  String pollingFailedFor(String serial) {
    return 'Fallo de sondeo para $serial';
  }

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get publicKey => 'Clave pública';

  @override
  String get pushEndpointUrl => 'URL del punto final push';

  @override
  String get pushRequestParseError => 'No se ha podido procesar la solicitud push.';

  @override
  String get pushToken => 'Push Token';

  @override
  String get qrFileDecodeError => 'No fue posible decodificar el código QR de la imagen seleccionada, por favor utilice el escáner de código QR en su lugar.';

  @override
  String get qrInFileNotFound => 'No se ha encontrado ningún código QR en la imagen seleccionada.';

  @override
  String get qrInFileNotFound2 => 'Puedes mostrarme dónde está el código QR.';

  @override
  String get qrInFileNotFound3 => 'Espero encontrar el código si está en el centro del área marcada.';

  @override
  String get qrNotFound => 'No se ha encontrado ningún código QR.';

  @override
  String get rename => 'Renombrar';

  @override
  String get renameToken => 'Renombrar token';

  @override
  String get renameTokenFolder => 'Cambiar nombre de carpeta';

  @override
  String get replaceButton => 'Sustituir';

  @override
  String requestInfo(String account, String issuer) {
    return 'Enviado por $issuer para su cuenta: \"$account\"';
  }

  @override
  String get requestPushChallengesPeriodically => 'Solicita retos push al servidor periódicamente. Habilite esta opción si los retos push no se reciben normalmente.';

  @override
  String get requestTriggerdByUserQuestion => '¿Fue usted quien provocó esta petición?';

  @override
  String get retryRolloutButton => 'Reintentar despliegue';

  @override
  String get rolloutStateCompleted => 'Despliegue completado';

  @override
  String get rolloutStateGeneratingKeyPair => 'Generación del par de claves';

  @override
  String get rolloutStateGeneratingKeyPairCompleted => 'Generación del par de claves completada';

  @override
  String get rolloutStateGeneratingKeyPairFailed => 'Error al generar el par de claves';

  @override
  String get rolloutStateNotStarted => 'Iniciar despliegue';

  @override
  String get rolloutStateParsingResponse => 'Analizando la respuesta';

  @override
  String get rolloutStateParsingResponseCompleted => 'Respuesta de análisis sintáctico completada';

  @override
  String get rolloutStateParsingResponseFailed => 'Error al analizar la respuesta';

  @override
  String get rolloutStateSendingPublicKey => 'Envío de clave pública';

  @override
  String get rolloutStateSendingPublicKeyCompleted => 'Envío de clave pública completado';

  @override
  String get rolloutStateSendingPublicKeyFailed => 'Error al enviar la clave pública';

  @override
  String get saveButton => 'Guardar';

  @override
  String get scanQrCode => 'Escanear código QR';

  @override
  String get scanThisQrWithNewDevice => 'Escanee este código QR con su nuevo dispositivo para importar el token.';

  @override
  String get secondsUntilNextOTP => 'Segundos hasta el próximo OTP';

  @override
  String get secretIsRequired => 'Se requiere secreto';

  @override
  String get secretKey => 'Clave secreta';

  @override
  String get selectFile => 'Seleccionar archivo';

  @override
  String get selectImportSource => 'Seleccionar fuente de importación';

  @override
  String get selectImportType => 'Jak chcete importovat žetony?';

  @override
  String selectTokensToExport(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seleccionar tokens para exportar',
      one: 'Seleccionar token para exportar',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get selectTokensToExportHelpContent1 => 'Si un token no aparece en la lista, no se garantiza que no sea un token privacyIDEA.';

  @override
  String get selectTokensToExportHelpContent2 => 'Actualmente sólo se pueden exportar los tokens añadidos manualmente y los importados.';

  @override
  String get selectTokensToExportHelpContent3 => ' Estamos trabajando en una solución para diferenciar entre tokens privacyIDEA y tokens privados.';

  @override
  String get selectTokensToExportHelpContent4 => ' Puede obtener un nuevo código QR del servicio del que recibió el token.';

  @override
  String get selectTokensToExportHelpTitle => '¿Su ficha no figura en la lista?';

  @override
  String get send => 'Enviar';

  @override
  String get sendErrorDialogBody => 'Se ha producido un error inesperado en la aplicación. La siguiente información puede ser enviada a los desarrolladores por correo electrónico para ayudar a prevenir este error en el futuro.';

  @override
  String get sendErrorLogDescription => 'Se crea un correo electrónico listo.\nContiene información sobre la app, el error y el dispositivo.\nPuedes editar el correo antes de enviarlo.\nAquí puede ver cómo utilizamos la información:';

  @override
  String get sendPushRequestResponseFailed => 'No se ha podido enviar la respuesta.';

  @override
  String get serverNotReachable => 'No se ha podido acceder al servidor.';

  @override
  String get settings => 'Configuración';

  @override
  String get settingsGroupGeneral => 'Información general';

  @override
  String get showDetails => 'Mostrar detalles';

  @override
  String get showErrorLog => 'Mostrar';

  @override
  String get showPrivacyPolicy => 'Mostrar política de privacidad';

  @override
  String get signInTitle => 'Autenticación necesaria';

  @override
  String get someTokensDoNotSupportPolling => 'Algunos tokens están obsoletos y no admiten la consulta activa para la autenticación mediante mensaje push.';

  @override
  String statusCode(int statusCode) {
    return 'Código de estado: $statusCode';
  }

  @override
  String get sync => 'Sinchronizar';

  @override
  String get syncContainerFailed => 'Error en la sincronización de contenedores';

  @override
  String get syncFbTokenFailed => 'La sincronización ha fallado para los siguientes tokens, por favor inténtelo de nuevo:';

  @override
  String get syncFbTokenManuallyWhenNetworkIsAvailable => 'Por favor, sincronice los tokens push manualmente a través de los ajustes cuando haya una conexión de red disponible.';

  @override
  String get syncState => 'Estado de la sincronización';

  @override
  String get syncStateCompletedDescription => 'Sincronización completada';

  @override
  String get syncStateFailedDescription => 'Sincronización fallida';

  @override
  String get syncStateNotStartedDescription => 'Sincronización no iniciada';

  @override
  String get syncStateSyncingDescription => 'Sincronización actual';

  @override
  String get synchronizePushTokens => 'Sinchronizar push tokens';

  @override
  String get synchronizesTokensWithServer => 'Sinchronizar tokens con el privacyIDEA servidor.';

  @override
  String get synchronizingTokens => 'Sincronización de los tokens.';

  @override
  String get theSecretDoesNotFitTheCurrentEncoding => 'El secreto no se ajusta a la codificación actual';

  @override
  String get theme => 'Tema';

  @override
  String get timeOut => 'Tiempo de espera';

  @override
  String get tokenDataParseError => 'No se han podido analizar los datos del token.';

  @override
  String get tokenDetails => 'Detalles de la token';

  @override
  String get tokenLinkImport => 'Enlace token';

  @override
  String get tokenSerial => 'Token serial';

  @override
  String get tokensAreEncrypted => 'Los tokens están encriptados. Por favor, introduce la contraseña para descifrarlos';

  @override
  String get tokensDoNotSupportSynchronization => 'Las siguientes tokens no admiten la sincronización y deben volver a desplegarse:';

  @override
  String get tokensSuccessfullyDecrypted => 'Los tokens se han descifrado correctamente y ya se pueden importar.';

  @override
  String get type => 'Tipo';

  @override
  String get unexpectedError => 'Se ha producido un error inesperado.';

  @override
  String get unknown => 'Desconocido';

  @override
  String get unlock => 'Desbloquear';

  @override
  String unsupported(String name, String value) {
    return '$name [$value] no es compatible con esta versión de la aplicación.';
  }

  @override
  String get useDeviceLocaleDescription => 'Utilizar el idioma del dispositivo si está soportado, en caso contrario por defecto inglés.';

  @override
  String get useDeviceLocaleTitle => 'Utiliza el idioma del teléfono';

  @override
  String valueNotAllowed(String parameter, String type, String value) {
    return 'Tipo $type «$value» no es un valor permitido para »$parameter»';
  }

  @override
  String valueNotAllowedIn(String map, String parameter, String type, String value) {
    return 'Tipo $type «$value» no es un valor válido para “$parameter” en »$map»d';
  }

  @override
  String get verboseLogging => 'Registro detallado';

  @override
  String get versionTitle => 'Versión';

  @override
  String get wrongPassword => 'Contraseña incorrecta';

  @override
  String get yes => 'Sí';
}
