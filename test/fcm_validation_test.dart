import 'package:flutter_test/flutter_test.dart';
import 'package:my_product_app/services/fcm_service.dart';

void main() {
  test('valid promo payload accepted', () {
    final event = validateCourierMessage(
      handler: 'onMessage',
      messageId: 'm1',
      data: {'action': 'update_ui', 'asset': 'promo'},
    );
    expect(event.asset, 'promo');
    expect(event.diagnostic, isNull);
  });
  test('valid default payload accepted', () {
    final event = validateCourierMessage(
      handler: 'onMessage',
      messageId: 'm2',
      data: {'action': 'update_ui', 'asset': 'default'},
    );
    expect(event.asset, 'default');
  });
  test('unknown asset rejected', () {
    final event = validateCourierMessage(
      handler: 'onMessage',
      messageId: 'm3',
      data: {'action': 'update_ui', 'asset': 'unknown'},
    );
    expect(event.asset, isNull);
    expect(event.diagnostic, contains('asset'));
  });
  test('missing asset rejected', () {
    final event = validateCourierMessage(
      handler: 'onMessage',
      messageId: 'm4',
      data: {'action': 'update_ui'},
    );
    expect(event.asset, isNull);
    expect(event.diagnostic, contains('asset'));
  });
  test('unsupported action rejected', () {
    final event = validateCourierMessage(
      handler: 'onMessage',
      messageId: 'm5',
      data: {'action': 'delete_ui', 'asset': 'promo'},
    );
    expect(event.asset, isNull);
    expect(event.diagnostic, contains('action'));
  });
}
