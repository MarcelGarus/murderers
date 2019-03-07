import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:pedantic/pedantic.dart';

enum AnalyticsEvent {
  app_open,
  intro_begin,
  intro_step,
  intro_completed,
  sign_in_attempt,
  sign_in_success,
  sign_in_failure,
  name_entered,
  signed_up,
  join_game_begin,
  join_game_enter_code,
  join_game_preview,
  join_game_completed,
  watch_game_begin,
  watch_game_enter_code,
  watch_game_preview,
  watch_game_completed,
  create_game_begin,
  create_game_enter_details,
  create_game_preview,
  create_game_completed,
  game_loaded,
  dashboard_idle,
  dashboard_active,
  dashboard_waiting_for_victim,
  dashboard_dying,
  dashboard_dead,
  leaderboard,
  deaths,
}

String _stringifyEvent(AnalyticsEvent event) {
  switch (event) {
    case AnalyticsEvent.app_open: return 'app_open';
    case AnalyticsEvent.intro_begin: return 'tutorial_begin';
    case AnalyticsEvent.intro_step: return 'tutorial_step';
    case AnalyticsEvent.intro_completed: return 'tutorial_completed';
    default: return 'unknown_event';
  }
}

class Handler {
  FirebaseAnalytics _analytics;
  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(
    analytics: _analytics
  );

  /// Initializes the analytics handler.
  Future<void> initialize() async {
    // TODO: only do this if the user opted in
    _analytics = FirebaseAnalytics();
    unawaited(logEvent(AnalyticsEvent.app_open));
  }

  /// Logs the given event.
  Future<void> logEvent(
    AnalyticsEvent event, [
    Map<String, dynamic> parameters
  ]) async {
    await _analytics?.logEvent(
      name: _stringifyEvent(event),
      parameters: parameters
    );
  }
}
