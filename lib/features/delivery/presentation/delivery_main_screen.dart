import '../../../../app/localization/lang.dart';
import 'package:flutter/material.dart';
import 'delivery_home_screen.dart';
import 'delivery_history_screen.dart';
import 'delivery_profile_screen.dart';
import 'delivery_earnings_screen.dart';
import '../../../core/design_system/components/app_icon.dart';

class DeliveryMainScreen extends StatefulWidget {
  const DeliveryMainScreen({super.key});
  @override
  State<DeliveryMainScreen> createState() => _DeliveryMainScreenState();
}

class _DeliveryMainScreenState extends State<DeliveryMainScreen> {
  int _index = 0;

  final _screens = [
    DeliveryHomeScreen(),
    DeliveryHistoryScreen(),
    DeliveryEarningsScreen(),
    DeliveryProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: AppIcon(Icons.home_outlined, size: AppIconSize.medium),
            label: lang.t('home'),
          ),
          BottomNavigationBarItem(
            icon: AppIcon(Icons.history_outlined, size: AppIconSize.medium),
            label: lang.t('history'),
          ),
          BottomNavigationBarItem(
            icon: AppIcon(Icons.attach_money, size: AppIconSize.medium),
            label: lang.t('my_earnings'),
          ),
          BottomNavigationBarItem(
            icon: AppIcon(Icons.person_outline, size: AppIconSize.medium),
            label: lang.t('profile'),
          ),
        ],
      ),
    );
  }
}
