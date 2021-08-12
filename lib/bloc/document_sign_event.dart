import 'package:equatable/equatable.dart';

abstract class DocumentSignEvent extends Equatable {
  const DocumentSignEvent();

  @override
  List<Object> get props => [];
}

class InitalizedSM extends DocumentSignEvent {}

class Mining extends DocumentSignEvent {}

class Confirmed extends DocumentSignEvent {}
