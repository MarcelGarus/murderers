import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'models.dart';

part 'network_game_parser.dart';

class NetworkError {}
class NoConnectionError extends NetworkError {}
class BadRequestError extends NetworkError {}
class ServerCorruptError extends NetworkError {}
class AuthenticationFailedError extends NetworkError {}
class ResourceNotFoundError extends NetworkError {}

/// A simple get request to the server.
class _Request<T> {
  _Request({
    @required this.functionName,
    @required this.parameters,
    T Function(String body) this.parser,
    void Function(T result) callback
  }) {
    if (callback != null) {
      callbacks.add(callback);
    }
  }

  final String functionName;
  final Map<String, String> parameters;
  final T Function(String body) parser;
  final callbacks = Set<void Function(T result)>();
  Future<T> _executor;

  /// Executes the request.
  Future<T> _execute() async {
    // Build the URL. TODO: encode parameter values
    final url = 'https://us-central1-murderers-e67bb.cloudfunctions.net/'
      + functionName + '?' + parameters.keys
      .map((key) => '$key=${parameters[key]}')
      .reduce((a, b) => '$a&$b');
    
    // Make the request.
    print('Making a request to ' + functionName);
    final res = await http.get(url);
    print('Got response: ${res.body}');

    // Handle errors. TODO: check for no internet & timeout
    switch (res.statusCode) {
      case 200: break;
      case 400: throw BadRequestError();
      case 403: throw AuthenticationFailedError();
      case 404: throw ResourceNotFoundError();
      case 500: throw ServerCorruptError();
      default: throw ServerCorruptError();
    }

    // Parse response.
    try {
      return (parser == null) ? null : parser(res.body);
    } catch (e, stacktrace) {
      print('Seems like the server output is corrupt: $e');
      print(stacktrace);
      throw ServerCorruptError();
    }
  }

  /// Executes the scheduled requests.
  Future<T> _executeScheduled(
    List<_Request> requestsToWaitFor
  ) async {
    // Wait for the given requests.
    print("Before executing the query, let's first await all ${requestsToWaitFor.length} requests: $requestsToWaitFor");
    while (requestsToWaitFor.first != this) {
      try {
        await requestsToWaitFor.first._executeScheduled(requestsToWaitFor);
      } catch (e) {
        // We don't need to actually do anything. The next request will be
        // executed simply because this functions returns and doesn't throw.
      }
    }

    if (_executor == null) {
      _executor = _execute();
    }
    return await _executor;
  }

  bool operator == (Object other) {
    return other is _Request<T>
      && functionName == other.functionName
      && true; // TODO: check for parameters
  }

  String toString() => functionName;
}

DateTime _parseTime(int time) {
  return time == null ? null : DateTime.fromMillisecondsSinceEpoch(time);
}

class Handler {
  final queue = <_Request>[];

  /// Makes a request after all the other requests completed.
  // TODO: merge multiple requests that do effectively the same
  Future<T> _makeRequest<T>(_Request<T> request) async {
    queue.add(request);
    final result = await request._executeScheduled(queue);
    queue.remove(request);
    return result;
  }

  /// Creates a user on the server.
  Future<String> createUser({
    @required String name,
    @required String authToken,
    String messagingToken
  }) => _makeRequest(_Request(
    functionName: 'create_user',
    parameters: {
      'name': name,
      'authToken': authToken,
      'messagingToken': messagingToken,
    },
    parser: (body) => json.decode(body)['id']
  ));

  /// Creates a game on the server.
  Future<Game> createGame({
    @required String id,
    @required String authToken,
    @required String name,
    @required DateTime start,
    @required DateTime end,
  }) => _makeRequest(_Request(
    functionName: 'create_game',
    parameters: {
      'id': id,
      'authToken': authToken,
      'name': name,
      'start': start.millisecondsSinceEpoch.toString(),
      'end': end.millisecondsSinceEpoch.toString(),
    },
    parser: (body) {
      final data = json.decode(body);
      return Game(
        isCreator: true,
        code: data['code'],
        name: data['name'],
        created: _parseTime(data['created']),
        end: _parseTime(data['end']),
      );
    }
  ));

  /// Joins a game on the server.
  Future<void> joinGame({
    @required String id,
    @required String authToken,
    @required String code,
  }) => _makeRequest(_Request(
    functionName: 'join_game',
    parameters: {
      'id': id,
      'authToken': authToken,
      'code': code,
    }
  ));

  /// Gets a game from the server.
  Future<Game> getGame({
    @required String id,
    @required String authToken,
    @required String code,
  }) => _makeRequest(_Request(
    functionName: 'get_game',
    parameters: {
      'id': id,
      'authToken': authToken,
      'code': code,
    },
    parser: (body) => _parseServerGame(
      body: body,
      code: code,
      id: id
    ),
  ));

  /// Starts a game on the server.
  Future<void> startGame({
    @required String id,
    @required String authToken,
    @required String code,
  }) => _makeRequest(_Request(
    functionName: 'start_game',
    parameters: {
      'id': id,
      'authToken': authToken,
      'code': code,
    },
  ));

  /// Kills a player on the server.
  Future<void> killPlayer({
    @required String id,
    @required String authToken,
    @required String code,
  }) => _makeRequest(_Request(
    functionName: 'kill_player',
    parameters: {
      'id': id,
      'authToken': authToken,
      'code': code,
    },
  ));

  /// A player dies on the server.
  Future<void> die({
    @required String id,
    @required String authToken,
    @required String code,
    @required String weapon,
    @required String lastWords,
  }) => _makeRequest(_Request(
    functionName: 'die',
    parameters: {
      'id': id,
      'authToken': authToken,
      'code': code,
      'weapon': weapon,
      'lastWords': lastWords
    },
  ));

  /// Shuffles some victims on the server.
  Future<void> shuffleVictims({
    @required String authToken,
    @required String code,
    @required bool onlyOutsmartedPlayers,
  }) => _makeRequest(_Request(
    functionName: 'shuffle_victims',
    parameters: {
      'authToken': authToken,
      'code': code,
      'onlyOutsmartedPlayers': onlyOutsmartedPlayers ? 'true' : 'false',
    },
  ));
}
