import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
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
  final String appName;

  const OnboardingView({required this.appName, Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Expanded(child: SizedBox()),
            Expanded(
              flex: 3,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Lottie.asset(
                    lottieFiles[_currentIndex].lottieFile,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Flexible(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: lottieFiles.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (_currentIndex == 0) {
                          return OnboardingPage(
                            title: AppLocalizations.of(context)!.onBoardingTitle1(widget.appName),
                            subtitle: AppLocalizations.of(context)!.onBoardingText1,
                          );
                        }
                        if (_currentIndex == 1) {
                          return OnboardingPage(
                            title: AppLocalizations.of(context)!.onBoardingTitle2,
                            subtitle: AppLocalizations.of(context)!.onBoardingText2,
                          );
                        }
                        if (_currentIndex == 2) {
                          return OnboardingPage(
                            title: AppLocalizations.of(context)!.onBoardingTitle3,
                            subtitle: AppLocalizations.of(context)!.onBoardingText3,
                            buttonTitle: 'Github',
                            onPressed: () async {
                              Uri uri = Uri.parse("https://github.com/privacyidea/pi-authenticator");
                              if (!await launchUrl(uri)) {
                                throw Exception('Could not launch $uri');
                              }
                            },
                          );
                        }

                        return Container();
                      },
                      onPageChanged: (value) {
                        setState(() {
                          _currentIndex = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int index = 0; index < lottieFiles.length; index++) DotIndicator(isSelected: index == _currentIndex),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_currentIndex == lottieFiles.length - 1) {
              ref.read(settingsProvider.notifier).setFirstRun(false);
              Navigator.of(context).pushReplacementNamed(MainView.routeName);
              return;
            }
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          },
          backgroundColor: Theme.of(context).colorScheme.background,
          child: Icon(
            Icons.arrow_forward_ios_outlined,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
        ),
      );
}
