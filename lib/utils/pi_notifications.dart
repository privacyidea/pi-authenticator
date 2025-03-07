/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PiNotifications {
  static PiNotifications? _instance;
  int id = 0;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  late NotificationDetails notificationDetails;

  PiNotifications._();

  static Future<int> show(String title, String body) async => (await _getInstance)._show(title, body);

  static Future<PiNotifications> get _getInstance async {
    if (_instance == null) {
      _instance = PiNotifications._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher'); // <- default icon name is @mipmap/ic_launcher
    // var initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
      'PiNotifications',
      'PiNotifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    notificationDetails = NotificationDetails(android: androidNotificationDetails);
  }

  Future<int> _show(String title, String body) async {
    final id = this.id++;
    await flutterLocalNotificationsPlugin.show(id, title, body, notificationDetails);
    return id;
  }
}
