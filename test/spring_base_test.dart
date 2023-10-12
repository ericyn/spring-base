import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spring_base/spring_base.dart';

void main() {
  test('the widget', () {
    expect(SpringBase(function: () {}, child: const Center(child: Text('test'),),), isA<Widget>());
  });
}
