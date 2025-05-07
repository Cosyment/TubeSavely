import 'package:flutter_test/flutter_test.dart';
import 'package:tubesavely/app/utils/constants.dart';

void main() {
  test('Constants initialization', () {
    expect(Constants.API_BASE_URL, 'https://api.tubesavely.cosyment.com');
    expect(Constants.API_TIMEOUT, 30000);
  });
}
