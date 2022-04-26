import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
import 'package:privacyidea_authenticator/screens/main_screen.dart';
import 'package:privacyidea_authenticator/screens/settings_screen.dart';
import 'package:privacyidea_authenticator/widgets/dot_indicator.dart';
import 'package:privacyidea_authenticator/widgets/onboarding_screens/onboarding_button_page.dart';
import 'package:privacyidea_authenticator/widgets/onboarding_screens/onboarding_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/customizations.dart';
import 'guide_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  String animation = 'Untitled';

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SizedBox(
            height: screenSize.height / 1.4,
            width: screenSize.width,
          ),
          Positioned(
            top: 120,
            right: 5,
            left: 5,
            child: Container(
              width: screenSize.width * 0.4,
              height: screenSize.height * 0.4,
              child: Lottie.asset(
                lottieFiles[_currentIndex].lottieFile,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 270,
              child: Column(
                children: [
                  Flexible(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: lottieFiles.length,
                      itemBuilder: (BuildContext context, int index) {
                        LottieFiles tab = lottieFiles[index];
                        if (_currentIndex == 0) {
                          return OnboardingPage(
                              title: AppLocalizations.of(context)!
                                  .onBoardingTitle1,
                              subtitle: AppLocalizations.of(context)!
                                  .onBoardingText1);
                        }
                        if (_currentIndex == 1) {
                          return OnboardingButtonPage(
                              title: AppLocalizations.of(context)!
                                  .onBoardingTitle2,
                              subtitle:
                                  AppLocalizations.of(context)!.onBoardingText2,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GuideScreen()),
                                );
                              },
                              buttonTitle: 'Guide');
                        }
                        if (_currentIndex == 2) {
                          return OnboardingButtonPage(
                            title:
                                AppLocalizations.of(context)!.onBoardingTitle3,
                            subtitle:
                                AppLocalizations.of(context)!.onBoardingText3,
                            buttonTitle: 'Github',
                            onPressed: () async {
                              String url =
                                  'https://github.com/privacyidea/pi-authenticator';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                          );
                        }
                        return Container();
                      },
                      onPageChanged: (value) {
                        _currentIndex = value;
                        setState(() {});
                      },
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int index = 0; index < lottieFiles.length; index++)
                        DotIndicator(isSelected: index == _currentIndex),
                    ],
                  ),
                  const SizedBox(height: 75)
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final settings = AppSettings.of(context);

          if (_currentIndex == 2) {
            settings.isFirstRun = false;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MainScreen(title: applicationName)),
            );
          } else {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          }
        },
        child: _currentIndex == 2
            ? FlareActor(
                'res/rive/success_check.flr',
                animation: animation,
              )
            : Icon(
                CupertinoIcons.right_chevron,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Color(0xFF303030)
            : Colors.grey[50],
        elevation: 0,
      ),
    );
  }
}

class LottieFiles {
  final String lottieFile;

  LottieFiles(this.lottieFile);
}

List<LottieFiles> lottieFiles = [
  LottieFiles(
    'res/lottie/onboarding_secure_animation.json',
  ),
  LottieFiles(
    'res/lottie/lock_shield.json',
  ),
  LottieFiles(
    'res/lottie/github-logo.json',
  ),
];
