import 'package:get/get.dart';

class NavigationController extends GetxController {
  int _index = 0;

  int get index => _index;

  void changeTab(int value) {
    if (_index == value) return;

    _index = value;
    update();
  }
}
