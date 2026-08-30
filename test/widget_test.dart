import 'package:flutter_test/flutter_test.dart';
import 'package:bhm_supermarket/features/navigation/controllers/navigation_controller.dart';

void main() {
  test('NavigationController changes tab state', () {
    final controller = NavigationController();

    expect(controller.index, 0);

    controller.changeTab(2);

    expect(controller.index, 2);

    controller.onClose();
  });
}
