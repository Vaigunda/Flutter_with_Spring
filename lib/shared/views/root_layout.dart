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
    String userType = provider.usertype;
    
    return LayoutBuilder(builder: (context, dimens) {
      void onSelected(int index) {
        if (userId.isEmpty) {
          if (index >= 0 && index < router.beforeDestinations.length) {
            final dest = router.beforeDestinations[index];
            go.GoRouter.of(context).go(dest.route);
          }
        } else if (userType == "Admin") {
          if (index >= 0 && index < router.adminDestinations.length) {
            final dest = router.adminDestinations[index];
            go.GoRouter.of(context).go(dest.route);
          }
        } else {
          if (index >= 0 && index < router.userDestinations.length) {
            final dest = router.userDestinations[index];
            go.GoRouter.of(context).go(dest.route);
          }
        }
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
        selectedIndex: (currentIndex >= 0 && currentIndex < router.beforeDestinations.length)
                        ? currentIndex
                        : 0,
        onDestinationSelected: onSelected,
        child: Column(
          children: [
            Expanded(
              child: _Switcher(
                key: _switcherKey,
                child: child,
              ),
            )],
          ),
        );
      } else if (userType == "Admin") {
        return AdaptiveNavigation(
        key: _navigationRailKey,
        destinations: router.adminDestinations
            .map((e) => NavigationDestination(
                  icon: e.icon,
                  label: e.label,
                ))
            .toList(),
        selectedIndex: (currentIndex >= 0 && currentIndex < router.beforeDestinations.length)
                        ? currentIndex
                        : 0,
        onDestinationSelected: onSelected,
        child: Column(
          children: [
            Expanded(
              child: _Switcher(
                key: _switcherKey,
                child: child,
              ),
            )],
         ),
        );
      } else {
      return AdaptiveNavigation(
        key: _navigationRailKey,
        destinations: router.userDestinations
            .map((e) => NavigationDestination(
                  icon: e.icon,
                  label: e.label,
                ))
            .toList(),
        selectedIndex: (currentIndex >= 0 && currentIndex < router.beforeDestinations.length)
                        ? currentIndex
                        : 0,
        onDestinationSelected: onSelected,
        child: Column(
          children: [
            Expanded(
              child: _Switcher(
                key: _switcherKey,
                child: child,
              ),
            )],
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
