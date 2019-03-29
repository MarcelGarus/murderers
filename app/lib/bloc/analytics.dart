import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:pedantic/pedantic.dart';

import 'persistence.dart';

enum AnalyticsEvent {
  app_open,
  sign_in_attempt,
  sign_in_success,
  sign_in_failure,
  name_entered,
  signed_up,
  join_game_begin,
  join_game_enter_code,
  join_game_completed,
  watch_game_begin,
  watch_game_enter_code,
  watch_game_completed,
  game_preview,
  create_game_begin,
  create_game_enter_details,
  create_game_completed,
  game_loaded,
  dashboard_not_started_yet,
  dashboard_active,
  dashboard_waiting_for_victim,
  dashboard_dying,
  dashboard_dead,
  leaderboard,
  deaths,
}

String _stringifyEvent(AnalyticsEvent event) {
  switch (event) {
    case AnalyticsEvent.app_open:
      return 'app_open';
    default:
      return 'unknown_event';
  }
}

class Handler {
  FirebaseAnalytics _analytics;
  bool get isEnabled => _analytics != null;
  FirebaseAnalyticsObserver _observer;

  RouteObserverProxy get observer => RouteObserverProxy._(
        onDidPush: (route, previousRoute) =>
            _observer?.didPush(route, previousRoute),
        onDidPop: (route, previousRoute) =>
            _observer?.didPop(route, previousRoute),
      );

  /// Initializes the analytics handler.
  Future<void> initialize() async {
    var isEnabled = await loadAnalyticsEnabled();
    if (isEnabled) {
      enable();
      unawaited(logEvent(AnalyticsEvent.app_open));
    }
  }

  /// Enables analytics.
  void enable() {
    _analytics = FirebaseAnalytics();
    _observer = FirebaseAnalyticsObserver(analytics: _analytics);
    saveAnalyticsEnabled(true);
  }

  /// Disables analytics.
  void disable() {
    _analytics = null;
    _observer = null;
    saveAnalyticsEnabled(false);
  }

  /// Logs the given event.
  Future<void> logEvent(AnalyticsEvent event,
      [Map<String, dynamic> parameters]) async {
    assert(event != null);

    await _analytics?.logEvent(
      name: _stringifyEvent(event),
      parameters: parameters,
    );
  }
}

/// This is a [RouteObserver] that just forwards the [onDidPush] and [onDidPop]
/// events to the given callbacks.
class RouteObserverProxy extends RouteObserver<PageRoute<dynamic>> {
  RouteObserverProxy._({
    @required this.onDidPush,
    @required this.onDidPop,
  })  : assert(onDidPush != null),
        assert(onDidPop != null);

  final void Function(Route route, Route previousRoute) onDidPush, onDidPop;

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPush(route, previousRoute);
    onDidPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPop(route, previousRoute);
    onDidPop(route, previousRoute);
  }
}
