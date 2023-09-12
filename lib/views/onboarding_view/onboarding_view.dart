import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../utils/app_customizer.dart';
import '../../utils/riverpod_providers.dart';
import '../../widgets/dot_indicator.dart';
import '../main_view/main_view.dart';
import 'onboading_view_widgets/onboarding_page.dart';

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

class OnboardingView extends ConsumerStatefulWidget {
  static const String routeName = '/onboarding';

  const OnboardingView({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  String animation = 'Untitled';

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            child: SizedBox(
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
                        if (_currentIndex == 0) {
                          return OnboardingPage(
                              title: AppLocalizations.of(context)!.onBoardingTitle1(applicationCustomizer.appName),
                              subtitle: AppLocalizations.of(context)!.onBoardingText1);
                        }
                        if (_currentIndex == 1) {
                          // TODO guide removed from here, put the new one here again?
                          return OnboardingPage(title: AppLocalizations.of(context)!.onBoardingTitle2, subtitle: AppLocalizations.of(context)!.onBoardingText2);
                        }
                        if (_currentIndex == 2) {
                          return OnboardingPage(
                            title: AppLocalizations.of(context)!.onBoardingTitle3,
                            subtitle: AppLocalizations.of(context)!.onBoardingText3,
                            buttonTitle: 'Github',
                            onPressed: () async {
                              String url = "https://github.com/privacyidea/pi-authenticator";
                              if (await canLaunchUrlString(url)) {
                                await launchUrlString(url);
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
                      for (int index = 0; index < lottieFiles.length; index++) DotIndicator(isSelected: index == _currentIndex),
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
          switch (_currentIndex) {
            case 2:
              ref.read(settingsProvider.notifier).setFirstRun(false);
              Navigator.of(context).pushReplacementNamed(MainView.routeName);

              break;
            default:
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
          }
        },
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF303030) : Colors.grey[50],
        child: _currentIndex == 2
            ? FlareActor(
                'res/rive/success_check.flr',
                animation: animation,
              )
            : Icon(
                CupertinoIcons.right_chevron,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
      ),
    );
  }
}
