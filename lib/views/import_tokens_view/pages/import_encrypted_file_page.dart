import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/tokens/token.dart';
import '../../../processors/token_import_processor/two_fas_file_import_processor.dart';
import 'import_decrypted_file_page.dart';

class ImportEncryptedFilePage extends StatefulWidget {
  final Future<List<Token>> Function({required String password}) importFunction;
  final String appName;

  const ImportEncryptedFilePage({super.key, required this.importFunction, required this.appName});

  @override
  State<ImportEncryptedFilePage> createState() => _ImportEncryptedFilePageState();
}

final asd = <dynamic, dynamic>{
  "masterKey": {
    "mAlgorithm": "PBKDF2withHmacSHA512",
    "mEncryptedKey": {
      "mCipher": "AES/GCM/NoPadding",
      "mCipherText": [
        87,
        -46,
        85,
        120,
        -64,
        -103,
        -104,
        -90,
        -125,
        91,
        -78,
        125,
        -69,
        -79,
        10,
        -75,
        103,
        49,
        -42,
        -6,
        27,
        -22,
        -86,
        46,
        -11,
        -97,
        -28,
        -58,
        -59,
        55,
        20,
        -99,
        -113,
        62,
        -46,
        -128,
        113,
        100,
        -7,
        -60,
        2,
        87,
        -10,
        -14,
        103,
        -37,
        -73,
        -81
      ],
      "mParameters": [48, 17, 4, 12, 122, -53, -107, 28, 30, 7, 72, -112, -74, -91, -29, -65, 2, 1, 16],
      "mToken": "AES"
    },
    "mIterations": 100000,
    "mSalt": [74, 64, 37, -90, -37, 3, -94, 65, -11, 8, 77, 12, 65, -98, 89, 50, 9, 70, -113, 109, -97, 113, 4, 106, -23, 97, 80, 67, -32, 103, -39, -102]
  },
  "35902690-b031-41c3-bdc7-ca7edeb3b4e7": {
    "key":
        "{\"mCipher\":\"AES\/GCM\/NoPadding\",\"mCipherText\":[18,-100,-77,-120,-37,-128,31,-98,-23,62,31,103,2,72,-14,58,-120],\"mParameters\":[48,17,4,12,-90,-88,21,4,-108,51,-122,-109,9,-59,45,-99,2,1,16],\"mToken\":\"HmacSHA256\"}"
  },
  "35902690-b031-41c3-bdc7-ca7edeb3b4e7-token": {
    "algo": "SHA256",
    "counter": 0,
    "digits": 6,
    "issuerExt": "",
    "label": "loooool",
    "period": 30,
    "type": "HOTP"
  },
  "2134ec38-1d21-4754-9c4a-d359d5fc9e6c": {
    "key":
        "{\"mCipher\":\"AES\/GCM\/NoPadding\",\"mCipherText\":[-61,92,108,-81,-5,-2,1,-92,111,45,-13,50,118,92,101,-82,-51,-4,68,-107,-68,-108,79,83,-64,49,69,-109,-16,-11,93,-33,-10,72,-113,40],\"mParameters\":[48,17,4,12,-22,33,-123,-102,4,-26,97,40,-61,-52,-50,-54,2,1,16],\"mToken\":\"HmacSHA1\"}"
  },
  "5d9f2634-c65e-4e79-9469-346f3f247d1f": {
    "key":
        "{\"mCipher\":\"AES\/GCM\/NoPadding\",\"mCipherText\":[-33,-52,-73,76,-29,-27,-75,79,42,24,-36,-12,-15,83,-40,-84,-25,-44,55],\"mParameters\":[48,17,4,12,-108,-91,-124,27,41,-1,-53,-96,14,74,-16,-117,2,1,16],\"mToken\":\"HmacSHA512\"}"
  },
  "5d9f2634-c65e-4e79-9469-346f3f247d1f-token": {"algo": "SHA512", "digits": 8, "issuerExt": "", "label": "aaa", "period": 60, "type": "TOTP"},
  "2134ec38-1d21-4754-9c4a-d359d5fc9e6c-token": {"counter": 1, "digits": 6, "issuerInt": "privacyIDEA", "label": "OATH00039821", "type": "HOTP"}
};

class _ImportEncryptedFilePageState extends State<ImportEncryptedFilePage> {
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool wrongPassword = false;
  Future<void>? future;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.appName),
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.file_present,
                    size: 100,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.fileIsEncrypted,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 80,
                    child: Row(
                      children: [
                        Flexible(
                          flex: 9,
                          child: TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.password,
                              errorText: wrongPassword ? AppLocalizations.of(context)!.wrongPassword : null,
                            ),
                            onChanged: (value) => setState(() {
                              wrongPassword = false;
                            }),
                            obscureText: !isPasswordVisible,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: GestureDetector(
                            child: const SizedBox(
                              height: 200,
                              width: 200,
                              child: Center(
                                child: Icon(
                                  Icons.visibility,
                                  size: 36,
                                ),
                              ),
                            ),
                            onPanDown: (_) => setState(() => isPasswordVisible = true),
                            onPanStart: (_) => setState(() => isPasswordVisible = true),
                            onPanCancel: () => setState(() => isPasswordVisible = false),
                            onPanEnd: (_) => setState(() => isPasswordVisible = false),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  future != null
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: passwordController.text.isEmpty || wrongPassword
                              ? null
                              : () async {
                                  setState(() {
                                    future = Future<void>(
                                      () async {
                                        // Future.delayed(const Duration(seconds: 1)).then((value) => null);
                                        List<Token> tokens;
                                        try {
                                          tokens = await widget.importFunction(password: passwordController.text);
                                        } on BadDecryptionPasswordException catch (_) {
                                          setState(() {
                                            wrongPassword = true;
                                            future = null;
                                          });
                                          return;
                                        }
                                        setState(() {
                                          future = null;
                                        });
                                        _pushAsync(MaterialPageRoute(
                                          builder: (context) => ImportDecryptedFilePage(
                                            importFunction: ({String? password}) => Future(() => tokens),
                                            appName: widget.appName,
                                          ),
                                        ));
                                      },
                                    );
                                  });
                                },
                          child: Text(AppLocalizations.of(context)!.decrypt),
                        ),
                ],
              ),
            ),
          ),
        ),
      );
  void _pushAsync(Route route) async {
    await Navigator.pushReplacement(context, route);
  }
}
