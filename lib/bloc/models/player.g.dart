// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) {
  return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      death: json['death'] == null
          ? null
          : Death.fromJson(json['death'] as Map<String, dynamic>));
}

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'death': instance.death
    };
