import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/constants/qlyp_notification_channels.dart';
import 'package:qlyp_core/services/notification_service.dart';

class _PassengerNotificationService extends QlypNotificationService {
  @override
  QlypNotificationAppRole get notificationAppRole =>
      QlypNotificationAppRole.passenger;

  @override
  NotificationTapHandler get onMessageTap => ({required payload}) async {};

  @override
  NotificationTopicSubscriber get subscribeToTopic => () async {};
}

class _DriverNotificationService extends QlypNotificationService {
  @override
  NotificationTapHandler get onMessageTap => ({required payload}) async {};

  @override
  NotificationTopicSubscriber get subscribeToTopic => () async {};
}

void main() {
  test('passenger foreground resolves marketplace counter channel', () {
    final svc = _PassengerNotificationService();
    final resolved = svc.resolveForegroundNotification({
      'type': 'marketplace_counter',
      'orderId': 'o1',
    });
    expect(resolved.channelId, QlypNotificationChannels.marketplacePassenger);
    expect(resolved.alarmChannel, isFalse);
    expect(resolved.soundResource, isNot('incoming_bid'));
  });

  test('driver foreground keeps dispatch alarm channel', () {
    final svc = _DriverNotificationService();
    final resolved = svc.resolveForegroundNotification({
      'type': 'dispatch_direct',
      'orderId': 'o1',
    });
    expect(resolved.channelId, QlypNotificationService.dispatchChannelId);
    expect(resolved.alarmChannel, isTrue);
  });

  test('passenger payment uses payment_success sound resource', () {
    final svc = _PassengerNotificationService();
    final resolved = svc.resolveForegroundNotification({
      'type': 'payment_confirmed',
      'orderId': 'o1',
    });
    expect(resolved.channelId, QlypNotificationChannels.payments);
    expect(resolved.soundResource, 'payment_success');
  });
}
