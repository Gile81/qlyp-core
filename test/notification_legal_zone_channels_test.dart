import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/services/notification_service.dart';

class _TestNotificationService extends QlypNotificationService {
  @override
  NotificationTapHandler get onMessageTap => ({required payload}) async {};

  @override
  NotificationTopicSubscriber get subscribeToTopic => () async {};
}

void main() {
  test('legal zone notification channel ids are stable', () {
    expect(
      QlypNotificationService.legalZoneValidatedChannelId,
      'qlyp_legal_zone_validated',
    );
    expect(
      QlypNotificationService.legalZoneRefusedChannelId,
      'qlyp_legal_zone_refused',
    );
  });

  test('legal zone channel labels include FR and EN', () {
    expect(QlypNotificationService.legalZoneValidatedChannelNameFr, isNotEmpty);
    expect(QlypNotificationService.legalZoneValidatedChannelNameEn, isNotEmpty);
    expect(QlypNotificationService.legalZoneRefusedChannelNameFr, isNotEmpty);
    expect(QlypNotificationService.legalZoneRefusedChannelNameEn, isNotEmpty);
    expect(_TestNotificationService().channelDescription, isNotEmpty);
  });
}
