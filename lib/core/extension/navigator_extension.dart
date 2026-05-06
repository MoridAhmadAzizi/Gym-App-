import 'package:flutter/material.dart';

extension NavigatorExt on BuildContext {
  bool navigatorCanPop() => Navigator.canPop(this);

  void navigatorPop<T extends Object?>([T? result]) => Navigator.pop(this, result);

  Future<bool> navigatorMaybePop<T extends Object?>([T? result]) async => Navigator.maybePop(this, result);

  Future<dynamic> navigatorPush<T extends Widget>(
    T screen, {
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool rootNavigator = false,
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();

    return Navigator.of(
      this,
      rootNavigator: rootNavigator,
    ).push(
      MaterialPageRoute(
        builder: (_) => screen,
        settings: settings,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  Future<dynamic> navigatorPushReplacement<T extends Widget>(
    T screen, {
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) async {
    return Navigator.of(this).pushReplacement(
      MaterialPageRoute(
        builder: (_) => screen,
        settings: settings,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  Future<dynamic> navigatorPushAndRemoveUntil<T extends Widget>(
    T screen, {
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool routes = false,
  }) async {
    return Navigator.of(this).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => screen,
        settings: settings,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
      ),
      (Route<dynamic> route) => routes,
    );
  }
}
