// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'death.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Death _$DeathFromJson(Map<String, dynamic> json) {
  return Death(
      murderer: json['murderer'] == null
          ? null
          : Player.fromJson(json['murderer'] as Map<String, dynamic>),
      weapon: json['weapon'] as String,
      lastWords: json['lastWords'] as String);
}

Map<String, dynamic> _$DeathToJson(Death instance) => <String, dynamic>{
      'murderer': instance.murderer,
      'weapon': instance.weapon,
      'lastWords': instance.lastWords
    };
