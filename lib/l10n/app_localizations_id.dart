import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get a11yAddFolderButton => 'Menambahkan folder';

  @override
  String get a11yAddTokenManuallyButton => 'Tambahkan token secara manual';

  @override
  String get a11yCloseSearchTokensButton => 'Tutup pencarian';

  @override
  String get a11yLicensesButton => 'Lisensi';

  @override
  String get a11yPushTokensButton => 'Token Dorong';

  @override
  String get a11yScanQrCodeButton => 'Memindai Kode QR';

  @override
  String get a11yScanQrCodeViewActive => 'Tampilan Pindai-Kode QR. Kamera aktif';

  @override
  String get a11yScanQrCodeViewFlashlightOff => 'Ketuk untuk menyalakan senter.';

  @override
  String get a11yScanQrCodeViewFlashlightOn => 'Ketuk untuk mematikan senter.';

  @override
  String get a11yScanQrCodeViewGallery => 'Buka galeri';

  @override
  String get a11yScanQrCodeViewInactive => 'Tampilan Pindai-Kode QR. Kamera tidak aktif';

  @override
  String get a11ySearchTokensButton => 'Token pencarian';

  @override
  String get a11ySettingsButton => 'Pengaturan';

  @override
  String get accept => 'Terima';

  @override
  String get addANewFolder => 'Membuat folder baru';

  @override
  String get addSystemInfo => 'Menambahkan informasi sistem';

  @override
  String get addToken => 'Tambahkan token';

  @override
  String get additionalErrorMessage => 'Pesan opsional';

  @override
  String get algorithm => 'Algoritma';

  @override
  String algorithmUnsupported(String algorithm) {
    return 'Algoritma $algorithm tidak didukung';
  }

  @override
  String get allTokensSynchronized => 'Semua token disinkronkan.';

  @override
  String get asFile => 'Sebagai file';

  @override
  String get asQrCode => 'Sebagai kode QR';

  @override
  String get askLogSendedDescription => 'Apakah Anda telah mengirim log, dan apakah Anda ingin menghapusnya sekarang?';

  @override
  String get authNotSupportedBody => 'Tindakan ini mengharuskan perangkat diamankan dengan kredensial atau biometrik.';

  @override
  String get authNotSupportedTitle => 'Diperlukan kredensial atau biometrik perangkat';

  @override
  String get authToAcceptPushRequest => 'Lakukan autentikasi untuk menerima permintaan push.';

  @override
  String get authToDeclinePushRequest => 'Lakukan autentikasi untuk menolak permintaan push.';

  @override
  String get authenticateToShowOtp => 'Harap lakukan autentikasi untuk menunjukkan kata sandi sekali pakai.';

  @override
  String get authenticateToUnLockToken => 'Lakukan autentikasi untuk mengubah status kunci token.';

  @override
  String get authentication => 'Otentikasi';

  @override
  String get biometricHint => 'Diperlukan autentikasi';

  @override
  String get biometricNotRecognized => 'Tidak dikenali. Coba lagi.';

  @override
  String get biometricRequiredTitle => 'Biometrik tidak diatur';

  @override
  String get biometricSuccess => 'Otentikasi berhasil';

  @override
  String get butDiscardIt => 'tapi buang saja';

  @override
  String get cancel => 'Batal';

  @override
  String get checkServerCertificate => 'Silakan periksa sertifikat server';

  @override
  String get checkYourNetwork => 'Periksa koneksi jaringan Anda dan coba lagi.';

  @override
  String get clearErrorLog => 'Jelas';

  @override
  String get clipboardEmpty => 'Papan klip kosong';

  @override
  String get confirmDeletion => 'Konfirmasikan penghapusan';

  @override
  String confirmDeletionOf(String name) {
    return 'Apakah Anda yakin ingin menghapus $name?';
  }

  @override
  String get confirmFolderDeletionHint => 'Menghapus folder tidak akan berpengaruh pada token yang ada di dalamnya.\nToken dipindahkan ke daftar utama.';

  @override
  String get confirmPassword => 'Konfirmasi kata sandi';

  @override
  String get confirmTokenDeletionHint => 'Anda mungkin tidak lagi dapat masuk jika Anda menghapus token ini.\nPastikan Anda dapat masuk ke akun terkait tanpa token ini.';

  @override
  String get confirmation => 'Konfirmasi';

  @override
  String get connectionFailed => 'Koneksi gagal.';

  @override
  String get container => 'Kontainer';

  @override
  String get containerAddDialogTitle => 'Tambahkan wadah';

  @override
  String get containerAlreadyExists => 'Wadah sudah ada';

  @override
  String get containerDeleteCorrespondingTokenDialogContent => 'Apakah Anda juga ingin menghapus token yang terkait?';

  @override
  String get containerDetails => 'Detail kontainer';

  @override
  String get containerRolloutSendDeviceInfoDialogContent => 'Apakah Anda ingin memberi tahu penerbit kontainer perangkat mana yang Anda gunakan? Ini mungkin berguna nantinya jika Anda mengalami masalah dengan faktor kedua Anda.';

  @override
  String get containerRolloutSendDeviceInfoDialogTitle => 'Mengirim informasi perangkat';

  @override
  String get containerSerial => 'Serial Kontainer';

  @override
  String get containerSyncUrl => 'Url Sinkronisasi Kontainer';

  @override
  String get containerTransferDeleteTokensButtonText => 'Hapus dari perangkat ini';

  @override
  String get containerTransferDialogContentAborted => 'Transfer kontainer dibatalkan.';

  @override
  String get continueButton => 'Lanjutkan';

  @override
  String get copyOTPToClipboard => 'Salin OTP ke papan klip';

  @override
  String get couldNotConnectToServer => 'Tidak dapat terhubung ke server';

  @override
  String get couldNotSignMessage => 'Tidak dapat menandatangani pesan.';

  @override
  String get counter => 'Penghitung';

  @override
  String get create => 'Membuat';

  @override
  String get createdAt => 'Dibuat pada';

  @override
  String get creator => 'Pencipta';

  @override
  String get dayPasswordValidFor => 'Berlaku untuk';

  @override
  String get dayPasswordValidUntil => 'Berlaku sampai';

  @override
  String get decline => 'Menolak';

  @override
  String get declineIt => 'menolaknya';

  @override
  String get decrypt => 'Dekripsi';

  @override
  String get decryptErrorButtonDelete => 'Menghapus';

  @override
  String get decryptErrorButtonRetry => 'Coba lagi.';

  @override
  String get decryptErrorButtonSendError => 'Kirim kesalahan';

  @override
  String get decryptErrorContent => 'Sayangnya, aplikasi ini tidak dapat mendekripsi token Anda. Hal ini mengindikasikan bahwa kunci enkripsinya rusak. Anda bisa mencoba lagi atau menghapus data aplikasi, yang akan menghapus token di dalam aplikasi.';

  @override
  String get decryptErrorDeleteConfirmationContent => 'Apakah Anda yakin ingin menghapus data aplikasi?';

  @override
  String get decryptErrorTitle => 'Kesalahan dekripsi';

  @override
  String get delete => 'Menghapus';

  @override
  String get deleteAllButtonText => 'Hapus semua';

  @override
  String get deleteContainerDialogContent => 'Jika Anda menghapus kontainer ini, smartphone akan terputus dari server privacyIDEA dan token dari kontainer ini menjadi tidak dapat digunakan. Sebelum menghapus, pastikan bahwa token yang bersangkutan tidak lagi diperlukan!';

  @override
  String deleteContainerDialogTitle(String serial) {
    return 'Menghapus Kontainer $serial';
  }

  @override
  String get deleteLockedToken => 'Lakukan autentikasi untuk menghapus token yang terkunci.';

  @override
  String get deleteOnlyContainerButtonText => 'Hanya kontainer';

  @override
  String get details => 'Detail';

  @override
  String get deviceCredentialsRequiredTitle => 'Kredensial perangkat tidak diatur';

  @override
  String get deviceCredentialsSetupDescription => 'Mengatur kredensial perangkat di pengaturan perangkat';

  @override
  String get digits => 'Digits';

  @override
  String get dismiss => 'Bubarkan';

  @override
  String get done => 'Selesai';

  @override
  String get edit => 'Sunting';

  @override
  String get editLockedToken => 'Harap lakukan autentikasi untuk mengedit token yang terkunci.';

  @override
  String get editToken => 'Edit Token';

  @override
  String get enablePolling => 'Mengaktifkan pemungutan suara';

  @override
  String get encoding => 'Pengkodean';

  @override
  String get enterDetailsForToken => 'Masukkan detail token';

  @override
  String get enterLink => 'Masukkan tautan';

  @override
  String get enterPassphraseDialogHint => 'Kata sandi';

  @override
  String get enterPassphraseDialogTitle => 'Masukkan kata sandi';

  @override
  String get enterPasswordToEncrypt => 'Masukkan kata sandi untuk mengenkripsi token. Kata sandi ini akan diperlukan untuk mengimpor token.';

  @override
  String get errorLogCleared => 'Log kesalahan dihapus.';

  @override
  String get errorLogEmpty => 'Log kesalahan kosong.';

  @override
  String get errorLogTitle => 'Log kesalahan';

  @override
  String get errorMailBody => 'File log kesalahan terlampir.\nAnda dapat mengganti teks ini dengan informasi tambahan tentang kesalahan.';

  @override
  String get errorMissingPrivateKey => 'Kunci pribadi hilang';

  @override
  String errorRollOutFailed(String name) {
    return 'Peluncuran token $name gagal.';
  }

  @override
  String errorRollOutNoConnectionToServer(String name) {
    return 'Peluncuran token $name gagal, server tidak dapat dihubungi.';
  }

  @override
  String get errorRollOutNotPossibleAnymore => 'Peluncuran Token ini sudah tidak memungkinkan lagi.';

  @override
  String get errorRollOutSSLHandshakeFailed => 'Jabat tangan SSL gagal. Peluncuran tidak dapat dilakukan.';

  @override
  String errorRollOutUnknownError(String e) {
    return 'Terjadi kesalahan yang tidak diketahui. Peluncuran tidak dapat dilakukan: $e';
  }

  @override
  String get errorSavingFile => 'Menyimpan ke file gagal';

  @override
  String get errorSynchronizationNoNetworkConnection => 'Sinkronisasi token gagal, server privacyIDEA tidak dapat dihubungi.';

  @override
  String errorTokenExpired(String name) {
    return 'Token $name telah kedaluwarsa.';
  }

  @override
  String errorUnlinkingPushToken(String label) {
    return 'Gagal memutuskan tautan token push $label.';
  }

  @override
  String errorWhenPullingChallenges(String name) {
    return 'Terjadi kesalahan saat melakukan polling untuk tantangan $name';
  }

  @override
  String get exampleUrl => 'Silakan masukkan URL yang valid seperti:';

  @override
  String get expandLockedFolder => 'Lakukan autentikasi untuk membuka folder yang terkunci.';

  @override
  String get export => 'Ekspor';

  @override
  String get exportAllTokens => 'Ekspor semua token';

  @override
  String get exportLockedTokenReason => 'Harap lakukan autentikasi untuk mengekspor token yang terkunci.';

  @override
  String get exportNonPrivacyIDEATokens => 'Ekspor token non-privacyIDEA';

  @override
  String get exportOneMore => 'Satu lagi.';

  @override
  String get exportTokens => 'Ekspor token';

  @override
  String get exportTokensHintDialogTitle => 'Informasi penting';

  @override
  String get exportingTokens => 'Mengekspor token...';

  @override
  String failedToFinalizeContainer(String serial) {
    return 'Gagal menyelesaikan kontainer $serial';
  }

  @override
  String failedToLoad(String name) {
    return 'Gagal memuat: \"$name\"';
  }

  @override
  String failedToSyncContainer(String serial) {
    return 'Gagal menyinkronkan wadah $serial';
  }

  @override
  String get feedback => 'Umpan balik';

  @override
  String get feedbackDescription => 'Jika Anda memiliki pertanyaan, saran, atau masalah, silakan beritahu kami.';

  @override
  String get feedbackHint => 'Email siap pakai akan terbuka, yang dapat Anda kirimkan kepada kami. Jika diinginkan, informasi tentang perangkat Anda dan versi aplikasi akan ditambahkan. Anda dapat memeriksa dan mengedit email sebelum mengirimnya.';

  @override
  String get feedbackPrivacyPolicy1 => 'Dengan mengirimkan umpan balik, Anda menyetujui ketentuan kami ';

  @override
  String get feedbackPrivacyPolicy2 => 'kebijakan privasi';

  @override
  String get feedbackPrivacyPolicy3 => '.';

  @override
  String get feedbackSentDescription => 'Terima kasih banyak atas bantuan Anda dalam membuat aplikasi ini menjadi lebih baik!';

  @override
  String get feedbackSentTitle => 'Umpan balik terkirim';

  @override
  String get feedbackTitle => 'Umpan balik Anda selalu diterima!';

  @override
  String get fileSavedToDownloadsFolder => 'File disimpan ke folder Unduhan';

  @override
  String get finalizationState => 'Status Finalisasi';

  @override
  String get finalizeContainerFailed => 'Menyelesaikan Kontainer Gagal';

  @override
  String get firebaseToken => 'Token Firebase';

  @override
  String get folderName => 'Nama folder';

  @override
  String get generatingPhonePart => 'Menghasilkan bagian telepon';

  @override
  String get gitHubButton => 'Aplikasi ini adalah Open Source\nKunjungi kami di GitHub';

  @override
  String get goToSettingsButton => 'Buka pengaturan';

  @override
  String get goToSettingsDescription => 'Autentikasi dengan kredensial atau biometrik tidak diatur pada perangkat Anda. Silakan atur di pengaturan perangkat.';

  @override
  String get grantCameraPermissionDialogButton => 'Berikan izin';

  @override
  String get grantCameraPermissionDialogContent => 'Mohon berikan izin kepada kamera untuk memindai kode QR.';

  @override
  String get grantCameraPermissionDialogPermanentlyDenied => 'Izin kamera ditolak secara permanen. Harap berikan izin kamera di pengaturan Telepon Anda.';

  @override
  String get grantCameraPermissionDialogTitle => 'Izin kamera tidak diberikan';

  @override
  String get handshakeFailed => 'Jabat tangan gagal';

  @override
  String get hidePushTokens => 'Menyembunyikan token push';

  @override
  String get hidePushTokensDescription => 'Menyembunyikan token push dari daftar token. Ini tidak akan menghapus token dan masih akan terlihat di layar terpisah.';

  @override
  String get imageUrl => 'URL gambar';

  @override
  String importConflictToken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ada konflik dengan token yang ada.\nSilakan pilih token yang ingin Anda simpan.',
      one: 'Ada konflik dengan token yang ada.\nSilakan pilih yang mana yang ingin Anda simpan.',
      zero: 'Tidak ada konflik dengan token yang ada.',
    );
    return '$_temp0';
  }

  @override
  String importExistingToken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count token ditemukan yang sudah ada di aplikasi.',
      one: 'Token ditemukan yang sudah ada di aplikasi.',
      zero: 'Tidak ada token yang ditemukan yang sudah ada di aplikasi.',
    );
    return '$_temp0';
  }

  @override
  String get importExportTokens => 'Impor/Ekspor token';

  @override
  String importFailedToken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gagal mengimpor token $count.',
      one: 'Gagal mengimpor token.',
      zero: 'Tidak ada token yang gagal diimpor.',
    );
    return '$_temp0';
  }

  @override
  String get importHint2FAS => 'Pilih cadangan 2FAS Anda.\nJika Anda tidak memiliki cadangan, buat cadangan di aplikasi 2FAS. Kami sarankan untuk menggunakan kata sandi.';

  @override
  String get importHintAegisBackupFile => 'Pilih ekspor Aegis Anda (.JSON).\nJika Anda tidak memiliki ekspor, buatlah melalui menu pengaturan di aplikasi Aegis. Disarankan untuk menggunakan kata sandi.';

  @override
  String get importHintAegisLink => 'Masukkan tautan yang Anda terima saat mentransfer entri dari Aegis.';

  @override
  String get importHintAegisQrScan => 'Pindai kode QR yang Anda terima saat mentransfer entri dari Aegis.';

  @override
  String get importHintAuthenticatorProFile => 'Untuk membuat cadangan aplikasi Authenticator Pro, buka pengaturan dan ketuk ';

  @override
  String get importHintFreeOtpPlusFile => 'Untuk membuat cadangan aplikasi FreeOTP+, ketuk tiga titik di sudut kanan atas dan pilih ';

  @override
  String get importHintFreeOtpPlusQrScan => 'Pindai kode QR yang Anda terima ketika Anda menekan tiga titik di ubin token dan pilih ';

  @override
  String get importHintGoogleQrFile => 'Pilih file gambar dengan kode QR yang Anda terima saat mengekspor akun Anda dari Google Authenticator.\n!! Perhatikan bahwa tidak aman untuk menyimpan kode QR di perangkat Anda karena token tidak dienkripsi !!';

  @override
  String get importHintGoogleQrScan => 'Pindai kode QR yang Anda terima saat mengekspor akun dari Google Authenticator.';

  @override
  String get importHintPrivacyIdeaFile => 'Untuk membuat cadangan, buka pengaturan dan ketuk ';

  @override
  String get importHintPrivacyIdeaQrScan => 'Untuk membuat kode QR untuk token, buka pengaturan dan ketuk ';

  @override
  String importNTokens(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Impor $count token',
      one: 'Impor satu token',
      zero: 'Impor tanpa token',
    );
    return '$_temp0';
  }

  @override
  String importNewToken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count token baru ditemukan dan dapat diimpor.',
      one: 'Token baru ditemukan dan dapat diimpor.',
      zero: 'Tidak ada token baru yang ditemukan.',
    );
    return '$_temp0';
  }

  @override
  String get importTokens => 'Impor token';

  @override
  String get importedVia => 'Diimpor via';

  @override
  String get increaseCounter => 'Tingkatkan penghitung';

  @override
  String internalServerError(String code) {
    return 'Kesalahan server internal ($code)';
  }

  @override
  String get introAddFolder => 'Anda dapat membuat folder untuk mengatur token Anda.';

  @override
  String get introAddTokenManually => 'Jika Anda tidak ingin memindai kode QR, Anda juga dapat menambahkan token secara manual.';

  @override
  String get introDragToken => 'Atur ulang token Anda dengan menekannya selama beberapa detik lalu seret ke posisi yang diinginkan.';

  @override
  String get introEditToken => 'Di sini Anda dapat mengedit nama token dan melihat beberapa detail.';

  @override
  String get introHidePushTokens => 'Token push Anda sekarang disembunyikan.\nTetapi Anda masih dapat melihatnya di layar push token.';

  @override
  String get introLockToken => 'Untuk lebih meningkatkan keamanan, Anda dapat mengunci token.\nKemudian token hanya dapat digunakan setelah otentikasi.';

  @override
  String get introPollForChallenges => 'Anda dapat memeriksa tantangan baru dengan menyeret daftar token ke bawah.';

  @override
  String get introScanQrCode => 'Anda dapat memindai kode QR untuk menambahkan token.\nKami mendukung semua token Autentikasi Dua Faktor yang umum dan juga token privasiIDEA.';

  @override
  String get introTokenSwipe => 'Geser token ke kiri untuk melihat tindakan yang tersedia.';

  @override
  String invalidBackupFile(String appName) {
    return 'File yang dipilih bukan merupakan cadangan yang valid dari $appName.';
  }

  @override
  String invalidLink(String appName) {
    return 'Tautan yang dimasukkan bukan merupakan token yang valid dari $appName, atau tidak didukung.';
  }

  @override
  String invalidQrFile(String appName) {
    return 'File yang dipilih tidak berisi kode QR yang valid dari $appName.';
  }

  @override
  String invalidQrScan(String appName) {
    return 'Kode QR yang dipindai bukan merupakan cadangan yang valid dari $appName.';
  }

  @override
  String get invalidUrl => 'URL tidak valid';

  @override
  String invalidValue(String parameter, String type, String value) {
    return 'Tipe $type \'$value\' tidak valid untuk \'$parameter\'';
  }

  @override
  String invalidValueIn(String map, String parameter, String type, String value) {
    return 'Tipe $type \'$value\' tidak valid untuk \'$parameter\' di \'$map\'';
  }

  @override
  String get isExpotableQuestion => 'Apakah dapat diekspor?';

  @override
  String get isPiTokenQuestion => 'Ini adalah token privacyIDEA?';

  @override
  String get issuer => 'Penerbit';

  @override
  String issuerLabel(String name) {
    return 'Penerbit: $name';
  }

  @override
  String get language => 'Bahasa';

  @override
  String get legacySigningErrorMessage => 'Token didaftarkan di versi lama aplikasi ini, yang dapat menyebabkan masalah saat menggunakannya.\nDisarankan untuk mendaftarkan token push baru jika masalah terus berlanjut!';

  @override
  String legacySigningErrorTitle(String tokenLabel) {
    return 'Terjadi kesalahan saat menggunakan token lama: $tokenLabel';
  }

  @override
  String get licensesAndVersion => 'Lisensi dan versi';

  @override
  String get linkHomeWidgetViewTitle => 'Tautkan widget beranda';

  @override
  String get linkMustOtpAuth => 'Tautan harus dimulai dengan otpauth://';

  @override
  String get linkedContainer => 'Wadah yang terhubung';

  @override
  String get lock => 'Mengunci';

  @override
  String get lockOut => 'Autentikasi biometrik dinonaktifkan. Silakan kunci dan buka kunci layar Anda untuk mengaktifkannya.';

  @override
  String get logMenu => 'Menu log';

  @override
  String get malformedData => 'Data cacat';

  @override
  String get markQrCode => 'Tandai Kode QR';

  @override
  String missingRequiredParameter(String parameter) {
    return 'Nilai untuk parameter [$parameter] diperlukan, tetapi tidak ada.';
  }

  @override
  String missingRequiredParameterIn(String map, String parameter) {
    return 'Nilai untuk parameter [$parameter] diperlukan, tetapi tidak ada dalam \"$map\".';
  }

  @override
  String mustNotBeEmpty(String field) {
    return '$field tidak boleh kosong';
  }

  @override
  String get name => 'Nama';

  @override
  String get no => 'Tidak.';

  @override
  String get noFbToken => 'Tidak ada token Firebase yang tersedia';

  @override
  String get noMailAppDescription => 'Tidak ada aplikasi email yang diinstal atau diinisialisasi pada perangkat ini, silakan coba lagi saat Anda dapat mengirim pesan email.';

  @override
  String get noMailAppTitle => 'Aplikasi email tidak ditemukan';

  @override
  String get noNetworkConnection => 'Tidak ada koneksi jaringan.';

  @override
  String get noPublicKey => 'Tidak ada kunci publik yang tersedia';

  @override
  String get noResultText1 => 'Ketuk tombol ';

  @override
  String get noResultText2 => 'untuk memulai!';

  @override
  String get noResultTitle => 'Belum ada token yang disimpan.';

  @override
  String get noTokenToExport => 'Tidak ada token yang tersedia untuk ekspor';

  @override
  String get noTokenToImport => 'Tidak ada token yang ditemukan untuk diimpor';

  @override
  String get notAnInteger => 'Nilainya bukan bilangan bulat.';

  @override
  String get notAnNumber => 'Nilainya bukan berupa angka.';

  @override
  String get ok => 'Ok';

  @override
  String get open => 'Buka';

  @override
  String get originApp => 'Aplikasi asal';

  @override
  String get originDetails => 'Rincian asal';

  @override
  String otpValueCopiedMessage(String otpValue) {
    return 'Kata sandi \"$otpValue\" disalin ke papan klip.';
  }

  @override
  String get password => 'Kata sandi';

  @override
  String get passwordCannotBeEmpty => 'Kata sandi tidak boleh kosong';

  @override
  String get passwordCannotContainWhitespace => 'Kata sandi tidak boleh mengandung spasi';

  @override
  String get passwordMustBeAtLeast8Characters => 'Kata sandi minimal harus terdiri dari 8 karakter';

  @override
  String get passwordMustContainLowercaseLetter => 'Kata sandi harus mengandung huruf kecil';

  @override
  String get passwordMustContainNumber => 'Kata sandi harus berisi angka';

  @override
  String get passwordMustContainSpecialCharacter => 'Kata sandi harus mengandung karakter khusus';

  @override
  String get passwordMustContainUppercaseLetter => 'Kata sandi harus mengandung huruf besar';

  @override
  String get passwordsDoNotMatch => 'Kata sandi tidak cocok';

  @override
  String get patchNotesBugFixes => 'Perbaikan bug';

  @override
  String get patchNotesDialogTitle => 'Apa yang baru?';

  @override
  String get patchNotesImprovements => 'Perbaikan';

  @override
  String get patchNotesNewFeatures => 'Fitur baru';

  @override
  String get patchNotesV4_3_0NewFeatures1 => 'Dukungan untuk mengimpor token dari Google, Aegis dan 2FAS Authenticator telah ditambahkan. Lebih banyak sumber impor akan ditambahkan di masa mendatang.';

  @override
  String get patchNotesV4_3_0NewFeatures2 => 'Menambahkan opsi umpan balik ke pengaturan.';

  @override
  String get patchNotesV4_3_0NewFeatures3 => 'Token push sekarang dapat disembunyikan dari daftar token.';

  @override
  String get patchNotesV4_3_0NewFeatures4 => 'Pengantar telah ditambahkan untuk membantu pengguna baru memulai.';

  @override
  String get patchNotesV4_3_0NewFeatures5 => 'Sekarang Anda dapat mencari token dengan mengetuk kaca pembesar di sudut kanan atas.';

  @override
  String get patchNotesV4_3_0NewFeatures6 => 'Menambahkan token HomeWidget untuk Android 12 dan yang lebih baru.';

  @override
  String get patchNotesV4_3_1BugFix1 => 'Memperbaiki masalah di mana nilai otp tidak ditampilkan setelah otentikasi pada beberapa perangkat.';

  @override
  String get patchNotesV4_3_1Improvement1 => 'Meningkatkan pemindai kode qr.';

  @override
  String get patchNotesV4_4_0Improvement1 => 'Sumber impor lebih lanjut telah ditambahkan.';

  @override
  String get patchNotesV4_4_0Improvement2 => 'Peningkatan pengenalan kode QR dari file gambar.';

  @override
  String get patchNotesV4_4_0NewFeatures1 => 'Sekarang dimungkinkan untuk mengekspor token di mana dapat dipastikan bahwa itu bukan token privacyIDEA. Saat ini, tidak dapat dikesampingkan bahwa token yang ditambahkan melalui pemindai kode QR berasal dari privacyIDEA. Diferensiasi akan ditingkatkan di versi mendatang.';

  @override
  String get patchNotesV4_4_0NewFeatures2 => 'Menambahkan dukungan untuk privacyIDEA ';

  @override
  String get patchNotesV4_4_2Improvement1 => 'Menambahkan dukungan senter untuk pemindaian kode QR.';

  @override
  String get patchNotesV4_4_2NewFeatures1 => 'Token sekarang dapat dimasukkan menggunakan salin & tempel.';

  @override
  String get patchNotesV4_4_2NewFeatures2 => 'Menambahkan dukungan galeri untuk pemindaian kode QR.';

  @override
  String get period => 'Periode';

  @override
  String get phonePart => 'Bagian telepon:';

  @override
  String piServerCode(String code) {
    return 'Kode Server PI: $code';
  }

  @override
  String get pleaseEnterANameForThisToken => 'Silakan masukkan nama untuk token ini.';

  @override
  String get pleaseEnterASecretForThisToken => 'Silakan masukkan rahasia untuk token ini.';

  @override
  String get pollingFailed => 'Polling gagal.';

  @override
  String pollingFailedFor(String serial) {
    return 'Pemungutan suara gagal untuk $serial';
  }

  @override
  String get privacyPolicy => 'Kebijakan privasi';

  @override
  String get publicKey => 'Kunci Publik';

  @override
  String get pushEndpointUrl => 'URL titik akhir push';

  @override
  String get pushRequestParseError => 'Push request could not be parsed.';

  @override
  String get pushToken => 'Token Dorong';

  @override
  String get pushTokensViewTitle => 'Token Dorong';

  @override
  String get qrFileDecodeError => 'Tidak dapat memecahkan kode QR dari gambar yang dipilih, silakan gunakan pemindai kode QR sebagai gantinya.';

  @override
  String get qrInFileNotFound => 'Tidak ada kode QR yang ditemukan pada gambar yang dipilih.';

  @override
  String get qrInFileNotFound2 => 'Anda dapat menunjukkan di mana letak kode QR.';

  @override
  String get qrInFileNotFound3 => 'Saya berharap saya akan menemukan kode tersebut jika berada di tengah-tengah area yang ditandai.';

  @override
  String get qrNotFound => 'Kode QR tidak ditemukan!';

  @override
  String get rename => 'Ganti nama';

  @override
  String get renameToken => 'Ganti nama token';

  @override
  String get renameTokenFolder => 'Ganti nama folder';

  @override
  String get renewSecretsButtonText => 'Memperbarui rahasia';

  @override
  String get renewSecretsDialogText => 'Anda dapat memperbarui rahasia token. Hal ini berguna jika Anda mencurigai bahwa rahasia tersebut telah dibobol.';

  @override
  String get renewSecretsDialogTitle => 'Memperbarui Rahasia Token';

  @override
  String get replaceButton => 'Ganti';

  @override
  String requestInfo(String account, String issuer) {
    return 'Dikirim oleh $issuer untuk akun Anda: $account';
  }

  @override
  String get requestPushChallengesPeriodically => 'Meminta tantangan push dari server secara berkala. Aktifkan ini jika tantangan push tidak diterima secara normal.';

  @override
  String get requestTriggerdByUserQuestion => 'Apakah permintaan ini dipicu oleh Anda?';

  @override
  String get retryRolloutButton => 'Mencoba peluncuran ulang';

  @override
  String get rolloutStateCompleted => 'Peluncuran selesai';

  @override
  String get rolloutStateGeneratingKeyPair => 'Menghasilkan pasangan kunci';

  @override
  String get rolloutStateGeneratingKeyPairCompleted => 'Membuat pasangan kunci selesai';

  @override
  String get rolloutStateGeneratingKeyPairFailed => 'Menghasilkan pasangan kunci gagal';

  @override
  String get rolloutStateNotStarted => 'Mulai peluncuran';

  @override
  String get rolloutStateParsingResponse => 'Tanggapan penguraian';

  @override
  String get rolloutStateParsingResponseCompleted => 'Respons penguraian selesai';

  @override
  String get rolloutStateParsingResponseFailed => 'Respons penguraian gagal';

  @override
  String get rolloutStateSendingPublicKey => 'Mengirim kunci publik';

  @override
  String get rolloutStateSendingPublicKeyCompleted => 'Pengiriman kunci publik selesai';

  @override
  String get rolloutStateSendingPublicKeyFailed => 'Mengirim kunci publik gagal';

  @override
  String get saveButton => 'Simpan';

  @override
  String get scanQrCode => 'Pindai Kode QR';

  @override
  String get scanThisQrWithNewDevice => 'Pindai kode QR ini dengan perangkat baru Anda untuk mengimpor token.';

  @override
  String get secondsUntilNextOTP => 'Detik hingga OTP berikutnya';

  @override
  String get secretIsRequired => 'Rahasia diperlukan';

  @override
  String get secretKey => 'Kunci rahasia';

  @override
  String get selectFile => 'Pilih file';

  @override
  String get selectImportSource => 'Pilih sumber impor';

  @override
  String get selectImportType => 'Bagaimana cara mengimpor token?';

  @override
  String selectTokensToExport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pilih token yang akan diekspor',
      one: 'pilih token yang akan diekspor',
    );
    return '$_temp0';
  }

  @override
  String get selectTokensToExportHelpContent1 => 'Jika sebuah token tidak terdaftar, tidak dijamin bahwa token tersebut bukan token privacyIDEA.';

  @override
  String get selectTokensToExportHelpContent2 => 'Saat ini hanya token yang ditambahkan dan diimpor secara manual yang dapat diekspor.';

  @override
  String get selectTokensToExportHelpContent3 => 'Kami sedang mengerjakan solusi untuk membedakan antara token privacyIDEA dan token pribadi.';

  @override
  String get selectTokensToExportHelpContent4 => 'Anda bisa mendapatkan kode QR baru dari layanan tempat Anda menerima token.';

  @override
  String get selectTokensToExportHelpTitle => 'Apakah token Anda tidak terdaftar?';

  @override
  String get send => 'Kirim';

  @override
  String get sendErrorDialogBody => 'Terjadi kesalahan yang tidak terduga dalam aplikasi. Informasi di bawah ini dapat dikirimkan ke pengembang melalui email untuk membantu mencegah kesalahan ini di masa mendatang.';

  @override
  String get sendErrorLogDescription => 'Email yang telah ditentukan sebelumnya akan dibuat.\nEmail ini berisi informasi tentang aplikasi, kesalahan, dan perangkat.\nAnda dapat mengedit email sebelum mengirimnya.\nAnda dapat melihat di sini bagaimana kami menggunakan informasi tersebut:';

  @override
  String get sendPushRequestResponseFailed => 'Gagal mengirim tanggapan.';

  @override
  String get serverNotReachable => 'Server tidak dapat dihubungi.';

  @override
  String get settings => 'Pengaturan';

  @override
  String get settingsGroupGeneral => 'Umum';

  @override
  String get showDetails => 'Tampilkan detail';

  @override
  String get showErrorLog => 'Tampilkan';

  @override
  String get showPrivacyPolicy => 'Tampilkan kebijakan privasi';

  @override
  String get signInTitle => 'Diperlukan autentikasi';

  @override
  String get someTokensDoNotSupportPolling => 'Beberapa token sudah ketinggalan zaman dan tidak mendukung pemungutan suara';

  @override
  String get startTransferButtonText => 'Mulai transfer';

  @override
  String statusCode(int statusCode) {
    return 'Kode status: $statusCode';
  }

  @override
  String get sync => 'Sinkronisasi';

  @override
  String get syncContainerFailed => 'Sinkronisasi kontainer gagal';

  @override
  String get syncFbTokenFailed => 'Sinkronisasi gagal untuk token berikut ini, silakan coba lagi:';

  @override
  String get syncFbTokenManuallyWhenNetworkIsAvailable => 'Harap sinkronkan token push secara manual melalui pengaturan ketika koneksi jaringan tersedia.';

  @override
  String get syncState => 'Status Sinkronisasi';

  @override
  String get syncStateCompletedDescription => 'Sinkronisasi selesai';

  @override
  String get syncStateFailedDescription => 'Sinkronisasi Gagal';

  @override
  String get syncStateNotStartedDescription => 'Sinkronisasi tidak dimulai';

  @override
  String get syncStateSyncingDescription => 'Sedang Menyinkronkan';

  @override
  String get synchronizePushTokens => 'Menyinkronkan token push';

  @override
  String get synchronizesTokensWithServer => 'Menyinkronkan token dengan server privacyIDEA.';

  @override
  String get synchronizingTokens => 'Menyinkronkan token.';

  @override
  String get theSecretDoesNotFitTheCurrentEncoding => 'Rahasia tidak sesuai dengan pengkodean saat ini';

  @override
  String get theme => 'Tema';

  @override
  String get timeOut => 'Waktu habis';

  @override
  String get tokenDataParseError => 'Data token tidak dapat diuraikan';

  @override
  String get tokenDetails => 'Rincian token';

  @override
  String get tokenLinkImport => 'Tautan token';

  @override
  String get tokenSerial => 'Serial token';

  @override
  String get tokensAreEncrypted => 'Tautan tokenToken dienkripsi. Masukkan kata sandi untuk mendekripsi token tersebut.';

  @override
  String get tokensDoNotSupportSynchronization => 'Token berikut ini tidak mendukung sinkronisasi dan harus diluncurkan kembali:';

  @override
  String get tokensSuccessfullyDecrypted => 'Token telah berhasil didekripsi dan sekarang dapat diimpor.';

  @override
  String get transferContainerDialogContent1 => 'Anda bisa mentransfer kontainer ke perangkat lain. Kontainer ditransfer melalui kode QR.';

  @override
  String get transferContainerDialogContent2 => 'Untuk proses ini, diperlukan koneksi internet yang aktif.';

  @override
  String get transferContainerDialogTitle => 'Mentransfer Kontainer';

  @override
  String get transferContainerFailed => 'Gagal memulai transfer.';

  @override
  String get transferContainerScanQrCode => 'Pindai kode QR pada perangkat baru untuk mentransfer kontainer.';

  @override
  String get transferContainerSuccessDialogContent1 => 'Kontainer telah berhasil ditransfer ke perangkat lain.';

  @override
  String get transferContainerSuccessDialogContent2 => 'Apakah Anda ingin menghapus container dan token terkait dari perangkat ini?';

  @override
  String get type => 'Jenis';

  @override
  String get unexpectedError => 'Terjadi kesalahan yang tidak diharapkan.';

  @override
  String get unknown => 'Tidak diketahui';

  @override
  String get unlock => 'Buka kunci';

  @override
  String unsupported(String name, String value) {
    return 'Nama $name [$value] tidak didukung oleh versi aplikasi ini.';
  }

  @override
  String get useDeviceLocaleDescription => 'Gunakan bahasa perangkat jika didukung, jika tidak, default ke bahasa Inggris.';

  @override
  String get useDeviceLocaleTitle => 'Gunakan bahasa perangkat';

  @override
  String valueNotAllowed(String parameter, String type, String value) {
    return 'Ketik $type “$value” bukan nilai yang diizinkan untuk ”$parameter”';
  }

  @override
  String valueNotAllowedIn(String map, String parameter, String type, String value) {
    return 'Ketik $type “$value” bukan merupakan nilai yang valid untuk ‘$parameter’ di ”$map”';
  }

  @override
  String get verboseLogging => 'Penebangan kata demi kata';

  @override
  String get versionTitle => 'Versi';

  @override
  String get wrongPassword => 'Kata sandi salah';

  @override
  String get yes => 'Ya';
}
