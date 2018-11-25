// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) {
  return Game(
      myRole: _$enumDecodeNullable(_$UserRoleEnumMap, json['myRole']),
      code: json['code'] as String,
      name: json['name'] as String,
      state: _$enumDecodeNullable(_$GameStateEnumMap, json['state']),
      created: json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
      end: json['end'] == null ? null : DateTime.parse(json['end'] as String),
      players: (json['players'] as List)
          ?.map((e) =>
              e == null ? null : Player.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      me: json['me'] == null
          ? null
          : Player.fromJson(json['me'] as Map<String, dynamic>),
      victim: json['victim'] == null
          ? null
          : Player.fromJson(json['victim'] as Map<String, dynamic>));
}

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
      'myRole': _$UserRoleEnumMap[instance.myRole],
      'code': instance.code,
      'name': instance.name,
      'state': _$GameStateEnumMap[instance.state],
      'created': instance.created?.toIso8601String(),
      'end': instance.end?.toIso8601String(),
      'players': instance.players,
      'me': instance.me,
      'victim': instance.victim
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$UserRoleEnumMap = <UserRole, dynamic>{
  UserRole.player: 'player',
  UserRole.watcher: 'watcher',
  UserRole.creator: 'creator'
};

const _$GameStateEnumMap = <GameState, dynamic>{
  GameState.notStartedYet: 'notStartedYet',
  GameState.running: 'running',
  GameState.paused: 'paused',
  GameState.over: 'over'
};
