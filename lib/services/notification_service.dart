import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// App-specific navigation when a notification is tapped.
typedef NotificationTapHandler = Future<void> Function({
  required dynamic payload,
});

/// App-specific FCM topic subscription (e.g. qlyp_customer vs qlyp_driver).
typedef NotificationTopicSubscriber = Future<void> Function();

/// Background message handler — call from app entry point.
Future<void> qlypFirebaseMessageBackgroundHandle(RemoteMessage message) async {
  log('BackGround Message :: ${message.messageId}');
  if (message.notification != null) {
    log(message.notification.toString());
  }
}

/// Bilingual notification copy helpers — identical in both apps.
class NotificationCopy {
  static const String defaultLang = 'fr';

  static String normalize(String? code) {
    if (code == null || code.trim().isEmpty) return defaultLang;
    final lang = code.trim().toLowerCase().split(RegExp(r'[_-]')).first;
    return lang == 'en' ? 'en' : 'fr';
  }

  static String frEn(String? lang, {required String fr, required String en}) {
    return normalize(lang) == 'en' ? en : fr;
  }
}

/// Shared FCM / local notification setup.
/// Apps extend and provide [onMessageTap] + [subscribeToTopic].
abstract class QlypNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String alertChannelId = 'qlyp_bid_alerts';
  static const String alertChannelName = 'Qlyp Alerts';
  static const String alertSoundResource = 'bid_beep';

  /// Direct dispatch overlay (server FCM) — separate from bid/marketplace alerts.
  static const String dispatchChannelId = 'qlyp_dispatch_channel';
  static const String dispatchChannelName = 'Qlyp Dispatch';
  static const String dispatchSoundResource = 'dispatch_alarm';

  static const String marketplaceChannelId = 'qlyp_marketplace_channel';
  static const String marketplaceChannelName = 'Qlyp Marketplace';
  static const String marketplaceSoundResource = 'incoming_bid';

  static const String legalZoneValidatedChannelId =
      'qlyp_legal_zone_validated';
  static const String legalZoneValidatedChannelNameFr =
      'Zones de travail validées';
  static const String legalZoneValidatedChannelNameEn =
      'Validated work zones';

  static const String legalZoneRefusedChannelId = 'qlyp_legal_zone_refused';
  static const String legalZoneRefusedChannelNameFr = 'Zones de travail refusées';
  static const String legalZoneRefusedChannelNameEn = 'Refused work zones';

  String get channelDescription => 'Qlyp alerts';

  NotificationTapHandler get onMessageTap;

  NotificationTopicSubscriber get subscribeToTopic;

  Future<void> initInfo() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    final request = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (request.authorizationStatus == AuthorizationStatus.authorized ||
        request.authorizationStatus == AuthorizationStatus.provisional) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInitializationSettings = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: iosInitializationSettings,
      );
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (_) {},
      );

      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        AndroidNotificationChannel(
          alertChannelId,
          alertChannelName,
          description: channelDescription,
          importance: Importance.max,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound(alertSoundResource),
        ),
      );
      await androidPlugin?.createNotificationChannel(
        AndroidNotificationChannel(
          dispatchChannelId,
          dispatchChannelName,
          description: channelDescription,
          importance: Importance.max,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound(dispatchSoundResource),
        ),
      );
      await androidPlugin?.createNotificationChannel(
        AndroidNotificationChannel(
          marketplaceChannelId,
          marketplaceChannelName,
          description: channelDescription,
          importance: Importance.defaultImportance,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound(marketplaceSoundResource),
        ),
      );
      await androidPlugin?.createNotificationChannel(
        AndroidNotificationChannel(
          legalZoneValidatedChannelId,
          '$legalZoneValidatedChannelNameFr / $legalZoneValidatedChannelNameEn',
          description: channelDescription,
          importance: Importance.high,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound(alertSoundResource),
        ),
      );
      await androidPlugin?.createNotificationChannel(
        AndroidNotificationChannel(
          legalZoneRefusedChannelId,
          '$legalZoneRefusedChannelNameFr / $legalZoneRefusedChannelNameEn',
          description: channelDescription,
          importance: Importance.high,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound(alertSoundResource),
        ),
      );

      await setupInteractedMessage();
    }
  }

  Future<void> setupInteractedMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      FirebaseMessaging.onBackgroundMessage(
        qlypFirebaseMessageBackgroundHandle,
      );
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('::::::::::::onMessage:::::::::::::::::');
      if (message.notification != null) {
        display(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      log('::::::::::::onMessageOpenedApp:::::::::::::::::');
      await onMessageTap(payload: message.data);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      log('::::::::::::getInitialMessage:::::::::::::::::');
      if (message?.data != null) {
        await onMessageTap(payload: message?.data);
      }
    });

    await subscribeToTopic();
  }

  static Future<String> getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    return token!;
  }

  Future<void> display(RemoteMessage message) async {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.notification!.body.toString()}');
    try {
      final data = message.data;
      final String channelId;
      if (data['channel'] == dispatchChannelId || data['type'] == 'dispatch_direct') {
        channelId = dispatchChannelId;
      } else if (data['channel'] == marketplaceChannelId ||
          (data['type']?.toString().startsWith('marketplace_') ?? false)) {
        channelId = marketplaceChannelId;
      } else if (data['type'] == 'legal_zone_validated') {
        channelId = legalZoneValidatedChannelId;
      } else if (data['type'] == 'legal_zone_refused') {
        channelId = legalZoneRefusedChannelId;
      } else {
        channelId = alertChannelId;
      }
      final channelName = switch (channelId) {
        dispatchChannelId => dispatchChannelName,
        marketplaceChannelId => marketplaceChannelName,
        legalZoneValidatedChannelId =>
          '$legalZoneValidatedChannelNameFr / $legalZoneValidatedChannelNameEn',
        legalZoneRefusedChannelId =>
          '$legalZoneRefusedChannelNameFr / $legalZoneRefusedChannelNameEn',
        _ => alertChannelName,
      };
      final soundResource = switch (channelId) {
        dispatchChannelId => dispatchSoundResource,
        marketplaceChannelId => marketplaceSoundResource,
        _ => alertSoundResource,
      };

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
        sound: RawResourceAndroidNotificationSound(soundResource),
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: '$soundResource.wav',
      );

      await flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title,
        message.notification!.body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: jsonEncode(message.data),
      );
    } on Exception catch (e) {
      log(e.toString());
    }
  }
}
