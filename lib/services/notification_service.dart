import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:qlyp_core/constants/qlyp_notification_channels.dart';

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

  /// Override in the client app to [QlypNotificationAppRole.passenger].
  QlypNotificationAppRole get notificationAppRole =>
      QlypNotificationAppRole.driver;

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
      await _createRoleAndroidChannels(androidPlugin);

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

  @visibleForTesting
  ResolvedForegroundNotification resolveForegroundNotification(
    Map<String, dynamic> data,
  ) {
    final type = data['type']?.toString() ?? '';
    final explicitChannel = data['channel']?.toString() ?? '';

    if (notificationAppRole == QlypNotificationAppRole.passenger) {
      final channelId = _passengerChannelForType(type, explicitChannel);
      final soundResource = _passengerSoundForChannel(channelId);
      return ResolvedForegroundNotification(
        channelId: channelId,
        channelName: _passengerChannelName(channelId),
        soundResource: soundResource,
        alarmChannel: false,
      );
    }

    final String channelId;
    if (explicitChannel == dispatchChannelId || type == 'dispatch_direct') {
      channelId = dispatchChannelId;
    } else if (explicitChannel == marketplaceChannelId ||
        type.startsWith('marketplace_')) {
      channelId = marketplaceChannelId;
    } else if (type == 'legal_zone_validated') {
      channelId = legalZoneValidatedChannelId;
    } else if (type == 'legal_zone_refused') {
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
    final alarmChannel = channelId == dispatchChannelId ||
        channelId == marketplaceChannelId ||
        channelId == alertChannelId;
    return ResolvedForegroundNotification(
      channelId: channelId,
      channelName: channelName,
      soundResource: soundResource,
      alarmChannel: alarmChannel,
    );
  }

  Future<void> display(RemoteMessage message) async {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.notification!.body.toString()}');
    try {
      final data = message.data;
      final resolved = resolveForegroundNotification(data);
      final channelId = resolved.channelId;
      final channelName = resolved.channelName;
      final soundResource = resolved.soundResource;
      final bool alarmChannel = resolved.alarmChannel;
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: alarmChannel ? Importance.max : Importance.high,
        priority: alarmChannel ? Priority.max : Priority.high,
        ticker: 'ticker',
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound(soundResource),
        audioAttributesUsage:
            alarmChannel ? AudioAttributesUsage.alarm : AudioAttributesUsage.notification,
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

  Future<void> _createRoleAndroidChannels(
    AndroidFlutterLocalNotificationsPlugin? androidPlugin,
  ) async {
    if (notificationAppRole == QlypNotificationAppRole.passenger) {
      await _createPassengerAndroidChannels(androidPlugin);
    } else {
      await _createDriverAndroidChannels(androidPlugin);
    }
    await _createSharedAndroidChannels(androidPlugin);
  }

  Future<void> _createDriverAndroidChannels(
    AndroidFlutterLocalNotificationsPlugin? androidPlugin,
  ) async {
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        alertChannelId,
        alertChannelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        sound: const RawResourceAndroidNotificationSound(alertSoundResource),
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        dispatchChannelId,
        dispatchChannelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        sound: const RawResourceAndroidNotificationSound(dispatchSoundResource),
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        marketplaceChannelId,
        marketplaceChannelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        sound: const RawResourceAndroidNotificationSound(marketplaceSoundResource),
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
  }

  Future<void> _createPassengerAndroidChannels(
    AndroidFlutterLocalNotificationsPlugin? androidPlugin,
  ) async {
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        QlypNotificationChannels.rideAccepted,
        'Ride accepted',
        description: channelDescription,
        importance: Importance.high,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('ride_accepted'),
      ),
    );
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        QlypNotificationChannels.driverArriving,
        'Driver arriving',
        description: channelDescription,
        importance: Importance.high,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('driver_arriving'),
      ),
    );
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        QlypNotificationChannels.payments,
        'Payments',
        description: channelDescription,
        importance: Importance.defaultImportance,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('payment_success'),
      ),
    );
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        QlypNotificationChannels.rideUpdates,
        'Ride updates',
        description: channelDescription,
        importance: Importance.high,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        QlypNotificationChannels.scheduled,
        'Scheduled rides',
        description: channelDescription,
        importance: Importance.high,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        QlypNotificationChannels.marketplacePassenger,
        'Marketplace offers',
        description: channelDescription,
        importance: Importance.high,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        QlypNotificationChannels.route,
        'Qlyp Route',
        description: channelDescription,
        importance: Importance.high,
      ),
    );
  }

  Future<void> _createSharedAndroidChannels(
    AndroidFlutterLocalNotificationsPlugin? androidPlugin,
  ) async {
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
  }

  String _passengerChannelForType(String type, String explicitChannel) {
    if (explicitChannel.isNotEmpty) return explicitChannel;
    switch (type) {
      case 'ride_accepted':
        return QlypNotificationChannels.rideAccepted;
      case 'driver_arriving':
        return QlypNotificationChannels.driverArriving;
      case 'payment_confirmed':
        return QlypNotificationChannels.payments;
      case 'marketplace_counter':
        return QlypNotificationChannels.marketplacePassenger;
      case 'scheduled_ride_update':
        return QlypNotificationChannels.scheduled;
      case 'route_booking_update':
      case 'route_chat_message':
        return QlypNotificationChannels.route;
      case 'ride_started':
      case 'ride_completed':
      case 'ride_canceled_by_driver':
      case 'no_driver_found':
        return QlypNotificationChannels.rideUpdates;
      default:
        return QlypNotificationChannels.rideUpdates;
    }
  }

  String _passengerSoundForChannel(String channelId) {
    switch (channelId) {
      case QlypNotificationChannels.rideAccepted:
        return 'ride_accepted';
      case QlypNotificationChannels.driverArriving:
        return 'driver_arriving';
      case QlypNotificationChannels.payments:
        return 'payment_success';
      default:
        return alertSoundResource;
    }
  }

  String _passengerChannelName(String channelId) {
    switch (channelId) {
      case QlypNotificationChannels.rideAccepted:
        return 'Ride accepted';
      case QlypNotificationChannels.driverArriving:
        return 'Driver arriving';
      case QlypNotificationChannels.payments:
        return 'Payments';
      case QlypNotificationChannels.scheduled:
        return 'Scheduled rides';
      case QlypNotificationChannels.marketplacePassenger:
        return 'Marketplace offers';
      case QlypNotificationChannels.route:
        return 'Qlyp Route';
      default:
        return 'Ride updates';
    }
  }
}

class ResolvedForegroundNotification {
  const ResolvedForegroundNotification({
    required this.channelId,
    required this.channelName,
    required this.soundResource,
    required this.alarmChannel,
  });

  final String channelId;
  final String channelName;
  final String soundResource;
  final bool alarmChannel;
}
