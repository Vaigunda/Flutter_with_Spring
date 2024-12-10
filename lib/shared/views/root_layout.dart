import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart' as go;
import 'package:universal_platform/universal_platform.dart';
import '../../navigation/router.dart' as router;
import 'adaptive_navigation.dart';
import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';

class RootLayout extends StatelessWidget {
  const RootLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  final Widget child;
  final int currentIndex;
  static const _switcherKey = ValueKey('switcherKey');
  static const _navigationRailKey = ValueKey('navigationRailKey');

  @override
  Widget build(BuildContext context) {

    var provider = context.read<UserDataProvider>();
    String userId = provider.userid;
    
    return LayoutBuilder(builder: (context, dimens) {
      void onSelected(int index) {
        final destination = router.destinations[index];
        go.GoRouter.of(context).go(destination.route);
      }
      if (userId.isEmpty) {
        return AdaptiveNavigation(
        key: _navigationRailKey,
        destinations: router.beforeDestinations
            .map((e) => NavigationDestination(
                  icon: e.icon,
                  label: e.label,
                ))
            .toList(),
        selectedIndex: currentIndex,
        onDestinationSelected: onSelected,
        child: Column(
          children: [
            Expanded(
              child: _Switcher(
                key: _switcherKey,
                child: child,
              ),
            )
          ],
        ),
      );
      } else {
        return AdaptiveNavigation(
        key: _navigationRailKey,
        destinations: router.destinations
            .map((e) => NavigationDestination(
                  icon: e.icon,
                  label: e.label,
                ))
            .toList(),
        selectedIndex: currentIndex,
        onDestinationSelected: onSelected,
        child: Column(
          children: [
            Expanded(
              child: _Switcher(
                key: _switcherKey,
                child: child,
              ),
            )
          ],
        ),
      );
      }
    });
  }
}

class _Switcher extends StatelessWidget {
  final Widget child;

  const _Switcher({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalPlatform.isDesktop
        ? child
        : AnimatedSwitcher(
            key: key,
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: child,
          );
  }
}
