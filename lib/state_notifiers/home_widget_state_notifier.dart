// import 'dart:convert';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mutex/mutex.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../utils/logger.dart';

// class HomeWidgetStateNotifier extends StateNotifier<HomeWidgetState> {
//   final Mutex _m = Mutex();
//   final HomeWidgetStateRepository _repo;

//   HomeWidgetStateNotifier({HomeWidgetState? initState, HomeWidgetStateRepository? repo})
//       : _repo = repo ?? PreferencesHomeWidgetStateRepository(),
//         super(initState ?? HomeWidgetState(linkedHomeWidgets: {}));

//   Future<void> saveState(HomeWidgetState state) async {
//     await _m.acquire();
//     try {
//       final success = await _repo.saveHomeWidgetState(state);
//       if (success) {
//         state = state;
//       } else {
//         Logger.warning(
//           'Failed to save HomeWidgetState',
//           name: 'HomeWidgetStateNotifier#saveState',
//           verbose: true,
//         );
//       }
//     } finally {
//       _m.release();
//     }
//   }

//   Future<void> loadState() async {
//     await _m.acquire();
//     try {
//       final newState = await _repo.loadHomeWidgetState();
//       if (newState != null) {
//         state = newState;
//       } else {
//         Logger.warning(
//           'Failed to load HomeWidgetState',
//           name: 'HomeWidgetStateNotifier#loadState',
//           verbose: true,
//         );
//       }
//     } finally {
//       _m.release();
//     }
//   }

//   void linkHomeWidget(String widgetId, String tokenId) {
//     state = HomeWidgetState(linkedHomeWidgets: {...state.linkedHomeWidgets, widgetId: tokenId});
//   }
// }

// class PreferencesHomeWidgetStateRepository extends HomeWidgetStateRepository {
//   static const _prefsKey = 'HOME_WIDGET_STATE';
//   final Future<SharedPreferences> _prefs;

//   PreferencesHomeWidgetStateRepository() : _prefs = SharedPreferences.getInstance();

//   @override
//   Future<bool> saveHomeWidgetState(HomeWidgetState state) async {
//     try {
//       final prefs = await _prefs;
//       final encodedState = jsonEncode(state);
//       return prefs.setString(_prefsKey, encodedState);
//     } catch (e, s) {
//       Logger.warning(
//         'Failed to save HomeWidgetState',
//         name: 'PreferencesHomeWidgetStateRepository#saveHomeWidgetState',
//         error: e,
//         stackTrace: s,
//         verbose: true,
//       );
//       return false;
//     }
//   }

//   @override
//   Future<HomeWidgetState?> loadHomeWidgetState() async {
//     try {
//       final prefs = await _prefs;
//       final jsonString = prefs.getString(_prefsKey);
//       final json = jsonDecode(jsonString!);
//       return HomeWidgetState.fromJson(json);
//     } catch (e, s) {
//       Logger.warning(
//         'Failed to load HomeWidgetState',
//         name: 'PreferencesHomeWidgetStateRepository#loadHomeWidgetState',
//         error: e,
//         stackTrace: s,
//         verbose: true,
//       );
//       return null;
//     }
//   }
// }

// abstract class HomeWidgetStateRepository {
//   Future<bool> saveHomeWidgetState(HomeWidgetState state);
//   Future<HomeWidgetState?> loadHomeWidgetState();
// }

// class HomeWidgetState {
//   Map<String, String> linkedHomeWidgets;

//   HomeWidgetState({required this.linkedHomeWidgets});

//   Map<String, dynamic> toJSon() => {'widgetIdToTokenId': linkedHomeWidgets};
//   factory HomeWidgetState.fromJson(Map<String, dynamic> json) => HomeWidgetState(linkedHomeWidgets: json['widgetIdToTokenId'] as Map<String, String>);
// }
