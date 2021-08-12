import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class DocumentSignState extends Equatable {
  final String username;
  const DocumentSignState({@required this.username});

  @override
  List<Object> get props => [username];
}

class DocumentSignUninitialized extends DocumentSignState {}

class DocumentSignInitializedSM extends DocumentSignState {
  const DocumentSignInitializedSM(String username) : assert(username != null);

  @override
  String toString() => 'Initiated by { username: $username }';
}

class DocumentSignMining extends DocumentSignState {
  const DocumentSignMining(String username) : assert(username != null);

  @override
  String toString() => 'Mining by { username: $username }';
}

class DocumentSignConfirmed extends DocumentSignState {
  const DocumentSignConfirmed(String username) : assert(username != null);

  @override
  List<Object> get props => [username];

  @override
  String toString() => 'Confirmed by { username: $username }';
}

class DocumentSignLoading extends DocumentSignState {}
